#!/bin/bash


sales_dir=~/salesdb
path_to_repo=~/HadoopBucketers
hdfs_dir=/salesdb
counter=0
option=$1

display_help() {
    echo "Usage: deploy.sh [option...] " >&2
    echo
    echo "  -h, --help                                      display help contents"
    echo "  -g, --get_data                                  get data from Amazon S3 bucket url, deliverable 2 step 1.1"
    echo "  -l, --load                                      load data to hdfs, deliverable 2 step 1.2"
    echo "  -cr, --create_sales_raw                         create database and tables for deliverable 2 step 1.3-1.4"
    echo "  -cs, --create_sales_tables                      create database and tables for deliverable 2 step 2.2-2.3"
    echo "  -cv, --create_sales_views                       create views for deliverable 2 step 2.4"
    echo "  -cps, --create_product_sales_partition          create table for deliverable 3 step 1"
    echo "  -cvp, --create_view_partition                   create view for deliverable 3 step 2"
    echo "  -cpr, --create_product_region_sales_partition   create table for deliverable 3 step 3"
    echo "  -ca, --create_all                               does the whole deployment (-g, -l, -cr, -cs, -cv, -cps, -cvp, -cpr)"
    echo "  -dr, --drop_raw_cascade                         drop raw sales database cascade, deliverable 3 step 4"
    echo "  -ds, --drop_sales_cascade                       drop sales database cascade, deliverable 3 step 4"
    echo "  -dv, --drop_sales_views                         drop sales views, deliverable 3 step 4"
    echo "  -dh, --delete-hdfs                              delete all sales data in hdfs, deliverable 3 step 4"
    echo "  -da, --delete-all                               deletes hdfs data as well as databases and views, deliverable 3 step 4"
    exit 1
}

get_data() {
    # fake wget for security reasons, so this won't work if downloaded
    echo "Getting data from amazonaws.com/sales-data/salesdata.tar.gz"
    wget amazonaws.com/sales-data/salesdata.tar.gz
    echo "Unzipping sales data"
    tar -xvzf salesdata.tar.gz
    rm salesdata.tar.gz
}

do_hdfs() {
  sudo -u hdfs hdfs dfsadmin -safemode leave

  echo Creating hdfs directory $hdfs_dir
  sudo -u hdfs hdfs dfs -mkdir $hdfs_dir

  for file in "$sales_dir"/*
     do
     echo Processing "$file"
     filename=$(basename -- "$file")
     echo Creating hdfs directory: $hdfs_dir/"${filename%.*}"
     sudo -u hdfs hdfs dfs -mkdir $hdfs_dir/"${filename%.*}"
     echo Puting file $sales_dir/$filename to hdfs directory: $hdfs_dir/"${filename%.*}"
     sudo -u hdfs hdfs dfs -put $sales_dir/$filename $hdfs_dir/"${filename%.*}"/
     done

   echo Saving all datasets to raw_data folder
   sudo -u hdfs hdfs dfs -mkdir $hdfs_dir/raw_data
   sudo -u hdfs hdfs dfs -cp $hdfs_dir/Employees2/Employees2.csv $hdfs_dir/raw_data/Employees2_orig.csv
   sudo -u hdfs hdfs dfs -cp $hdfs_dir/Customers2/Customers2.csv $hdfs_dir/raw_data/Customers2_orig.csv
   sudo -u hdfs hdfs dfs -cp $hdfs_dir/Sales2/Sales2.csv $hdfs_dir/raw_data/Sales2_orig.csv
   sudo -u hdfs hdfs dfs -cp $hdfs_dir/Products/Products.csv $hdfs_dir/raw_data/Products_orig.csv

   echo Changing owner of hdfs directory to hive
   sudo -u hdfs hdfs dfs -chown -R hive:hive $hdfs_dir
   sudo -u hdfs hdfs dfsadmin -safemode enter
}

create_sales_raw() {
   sudo -u hdfs hdfs dfsadmin -safemode leave
   echo Creating raw sales external tables from csv files
   impala-shell -f "$path_to_repo"/sql/create_sales_raw.sql
   sudo -u hdfs hdfs dfsadmin -safemode enter
}

create_sales() {
   sudo -u hdfs hdfs dfsadmin -safemode leave
   echo Creating sales parquet tables from csv files
   impala-shell -f "$path_to_repo"/sql/create_sales.sql
   sudo -u hdfs hdfs dfsadmin -safemode enter
}

create_sales_views() {
   echo Creating sales views on parquet tables
   sudo -u hdfs hdfs dfsadmin -safemode leave
   impala-shell -f "$path_to_repo"/sql/create_sales_views.sql
   sudo -u hdfs hdfs dfsadmin -safemode enter
}

create_product_sales_partition() {
   echo Creating product/sales table, partitioned by year/month
   sudo -u hdfs hdfs dfsadmin -safemode leave
   impala-shell -f "$path_to_repo"/sql/create_product_sales_partition.sql
   sudo -u hdfs hdfs dfsadmin -safemode enter
}

create_view_partition() {
   echo Creating view from partitioned table
   sudo -u hdfs hdfs dfsadmin -safemode leave
   impala-shell -f "$path_to_repo"/sql/create_view_partition.sql
   sudo -u hdfs hdfs dfsadmin -safemode enter
}

create_product_region_sales_partition() {
   echo Creating product/region/sales table, partitioned by region/year/month
   sudo -u hdfs hdfs dfsadmin -safemode leave
   impala-shell -f "$path_to_repo"/sql/create_product_region_sales_partition.sql
   sudo -u hdfs hdfs dfsadmin -safemode enter
}

drop_raw_database() {
   echo Dropping database, cascade
   sudo -u hdfs hdfs dfsadmin -safemode leave
   impala-shell -q "DROP DATABASE IF EXISTS hadoopbucketers_sales_raw CASCADE;"
   sudo -u hdfs hdfs dfsadmin -safemode enter
}


drop_sales_database() {
   echo Dropping database, cascade
   sudo -u hdfs hdfs dfsadmin -safemode leave
   impala-shell -q "DROP DATABASE IF EXISTS hadoopbucketers_sales CASCADE;"
   sudo -u hdfs hdfs dfsadmin -safemode enter

}

drop_sales_views() {
    echo Removing all sales views
    sudo -u hdfs hdfs dfsadmin -safemode leave
    impala-shell -q "DROP VIEW IF EXISTS hadoopbucketers_sales.customer_monthly_sales_2019_view;"
    impala-shell -q "DROP VIEW IF EXISTS hadoopbucketers_sales.top_ten_customers_amount_view;"
    impala-shell -q "DROP VIEW IF EXISTS hadoopbucketers_sales.customer_monthly_sales_2019_partitioned_view;"
    sudo -u hdfs hdfs dfsadmin -safemode enter
}

delete_hdfs() {
    sudo -u hdfs hdfs dfsadmin -safemode leave
    echo Removing raw sales data from HDFS
    sudo -u hdfs hdfs dfs -rm -r $hdfs_dir
    sudo -u hdfs hdfs dfsadmin -safemode enter
}

delete_sales_data() {
  rm -rf $sales_dir
}

########################################################
# Run Time Commands
########################################################

while [ $counter -eq 0 ]; do
    counter=$(( counter + 1 ))

    case $option in
      -h | --help)
          display_help
          ;;

      -g | --get_data)
          get_data
          ;;

      -l | --load)
          do_hdfs
          ;;

      -cr | --create_sales_raw_tables)
          create_sales_raw
          ;;

      -cs | --create_sales_tables)
          create_sales
          ;;

      -cv | --create_sales_views)
          create_sales_views
          ;;

      -cps | --create_product_sales_partition)
          create_product_sales_partition
          ;;

      -cvp | --create_view_partition)
          create_view_partition
          ;;

      -cpr | --create_product_region_sales_partition)
          create_product_region_sales_partition
          ;;

      -ca  | --create_all)
          echo "Getting data, creating hdfs directory, raw sales database, sales database, views, and partitions"
          get_data
          do_hdfs
          create_sales_raw
          create_sales
          create_sales_views
          create_product_sales_partition
          create_view_partition
          create_product_region_sales_partition
          ;;

      -dr | --drop_raw_cascade)
          drop_raw_database
          ;;

      -ds | --drop_sales_cascade)
          drop_sales_database
          ;;

      -dv | --drop_sales_views)
          drop_sales_views
          ;;

      -dh | --delete_hdfs)
          delete_hdfs
          ;;

      -da | --delete_all)
          echo "Removing data from HDFS, deleting databases, and views"
          drop_sales_views
          drop_sales_database
          drop_raw_database
          delete_hdfs
          delete_sales_data
          ;;

      --) # End of all options
          shift
          break
          ;;

      -*)
          echo "Error: Unknown option: $1" >&2
          ## or call function display_help
          exit 1
          ;;

      *)  # No more options
          break
          ;;

    esac
done
