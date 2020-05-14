# HadoopBucketers

This was an introductory project to Hadoop using dummy sales data. The following readme would show how to use the scripts to create a database in HDFS using Cloudera Manager. The script won't work by itself as there is a dummy wget to an Amazon S3 bucket that needs a valid address, but was kept out for privacy.

What does it do/What is in the repo? Scripts to get HDFS running on Cloudera Manager and SQL statements to create a database with tables, partitions, and views. 

What technologies are used? Learning Hadoop was the main goal of the project. Python, bash scripts and sql was used.

What is the stage of the project? The project is done for the goal of having working code for the purpose of learning Hadoop.


## Contents

- The Deployment Runbook section contains information that shows how the code should be run on the production environment.
- The User Documentation section contains helpful information about the database, including a Data Dictionary.
- The Raw Data Issues section covers problems in the raw data found (and fixed) during Quality Analysis.
- The Partition Performance section outlines the benefits of partitioning in the 2019 customer sales view.

## Deployment RunBook

The bash script, `deploy.sh` is utilized throughout the deployment process. It contains logic to deploy all necessary resources, along with functionality to completely roll back the deployment.

**`deploy.sh` must be run from the cloudera home directory (`/home/cloudera/​`)**

```
Usage: deploy.sh [option...]

  -h, --help                                      display help contents
  -g, --get_data                                  get data from Amazon S3 bucket url, deliverable 2 step 1.1
  -l, --load                                      load data to hdfs, deliverable 2 step 1.2
  -cr, --create_sales_raw                         create database and tables for deliverable 2 step 1.3-1.4
  -cs, --create_sales_tables                      create database and tables for deliverable 2 step 2.2-2.3
  -cv, --create_sales_views                       create views for deliverable 2 step 2.4
  -cps, --create_product_sales_partition          create table for deliverable 3 step 1
  -cvp, --create_view_partition	                  create view for deliverable 3 step 2
  -cpr, --create_product_region_sales_partition	  create table for deliverable 3 step 3
  -ca, --create_all                               Does the whole deployment (-g, -l, -cr, -cs, -cv, -cps, -cvp, -cpr)
  -dr, --drop_raw_cascade                         drop raw sales database cascade, deliverable 3 step 4
  -ds, --drop_sales_cascade                       drop sales database cascade, deliverable 3 step 4
  -dv, --drop_sales_views                         drop sales views, deliverable 3 step 4
  -dh, --delete-hdfs                              delete all sales data in hdfs, deliverable 3 step 4
  -da, --delete-all                               deletes hdfs data as well as databases and views, deliverable 3 step 4
```

### Deployment

Run the following command to fully deploy:

```bash
./HadoopBucketers/bin/deploy.sh --create-all
```

If you would like to deploy one component at a time, use the command line arguments specified in the usage information in the following order. **The script only supports one command line argument at a time**.

1. `./HadoopBucketers/bin/deploy.sh -g`
2. `./HadoopBucketers/bin/deploy.sh -l`
3. `./HadoopBucketers/bin/deploy.sh -cr`
4. `./HadoopBucketers/bin/deploy.sh -cs`
5. `./HadoopBucketers/bin/deploy.sh -cv`
6. `./HadoopBucketers/bin/deploy.sh -cps`
7. `./HadoopBucketers/bin/deploy.sh -cvp`
8. `./HadoopBucketers/bin/deploy.sh -cpr`

### Rollback

Run the following command to roll back all changes made to production:

```bash
./HadoopBucketers/bin/deploy.sh --delete-all
```

## User Documentation

### Database Schema: `hadoopbucketers_sales`

#### Base Tables
These four tables correspond to the four text files we started with, after performing some quality analysis to ensure there were no duplicates in the tables (see Raw Data Issues section below).

#### Sales

| Column Name       | Data Type     |
|---------------	|-----------	|
| `OrderID`       	| `int`       	|
| `SalesPersonID` 	| `int`       	|
| `CustomerID`    	| `int`       	|
| `ProductID`     	| `int`       	|
| `Quantity`      	| `int`       	|
| `PurchaseDate` 	| `Timestamp` 	|

#### Employees

| Column Name       | Data Type     |
|---------------	|-----------	|
| `EmployeeID `     | `int`         |
| `FirstName`       | `varchar`     |
| `MiddleInitial`   | `varchar`     |
| `LastName`        | `varchar`     |
| `Region`          | `varchar`     |

#### Customers

| Column Name       | Data Type     |
|---------------	|-----------	|
| `CustomerID`      | `int`         |
| `FirstName`       | `varchar`     |
| `MiddleInitial`   | `varchar`     |
| `LastName`        | `varchar`     |

#### Products

| Column Name       | Data Type      |
|---------------	|-----------	 |
| `ProductID`       | `int`          |
| `Name`            | `varchar`      |
| `Price`           | `decimal(8,4)` |

#### Partitioned Tables
These two tables combine sales records with additional information about the product sold and the amount of the sale in dollars. They are partitioned by year/month and region/year/month, respectively (see Partition Performance section below).

#### Product_Sales_Partition

| Column Name       | Data Type      |
|---------------	|-----------	  |
| `OrderID`         | `int`          |
| `SalesPersonID`   | `int`          |
| `CustomerID`      | `int`          |
| `ProductID`       | `int`          |
| `ProductName`     | `varchar`      |
| `ProductPrice`    | `decimal(8,4)` |
| `Quantity`        | `int`          |
| `ThisSaleAmount`  | `decimal(8,4)` |
| `OrderDate`       | `Timestamp`    |
| `Year`            | `int`          |
| `Month`           | `int`          |

#### Product_Region_Sales_Partition

| Column Name       | Data Type      |
|---------------	|-----------	  |
| `OrderID`         | `int`          |
| `SalesPersonID`   | `int`          |
| `CustomerID`      | `int`          |
| `ProductID`       | `int`          |
| `ProductName`     | `varchar`      |
| `ProductPrice`    | `decimal(8,4)` |
| `Quantity`        | `int`          |
| `ThisSaleAmount`  | `decimal(8,4)` |
| `OrderDate`       | `Timestamp`    |
| `Region`          | `varchar`      |
| `Year`            | `int`          |
| `Month`           | `int`          |

#### Views
The first view listed here contains information about the all-time top ten customers, measured by the total sales amount in dollars. The other two views contain information about monthly sales by customer. Their information is identical, but one of these views was created from a partitioned table and the other one was not. (See Partition Performance section below for a detailed discussion of when to use one view versus the other.)

#### Top_Ten_Customers_Amount_View

| Column Name       | Data Type     |
|---------------	    |-----------      |
| `CustomerID`          | `int`          |
| `FirstName`           | `varchar`      |
| `LastName`            | `varchar`      |
| `LifetimeSalesAmount` | `decimal(8,4)` |

#### Customer_Monthly_Sales_2019_View

| Column Name       | Data Type     |
|---------------	    |-----------     |
| `CustomerID`          | `int`          |
| `FirstName`           | `varchar`      |
| `LastName`            | `varchar`      |
| `Year`                | `int`          |
| `Month`               | `int`          |
| `TotalSalesAmount`    | `decimal(8,4)` |

#### Customer_Monthly_Sales_2019_Partitioned_View

| Column Name       | Data Type     |
|---------------	    |-----------     |
| `CustomerID`          | `int`          |
| `FirstName`           | `varchar`      |
| `LastName`            | `varchar`      |
| `Year`                | `int`          |
| `Month`               | `int`          |
| `TotalSalesAmount`    | `decimal(8,4)` |

#### Other Information

####  Primary Key-Foreign Key Relationships
The following primary key-foreign key relationships may be helpful for computing joins.

| Primary Key            | Foreign Key           |
|---------------	     |-----------	         |
| `Employees.EmployeeID` | `Sales.SalesPersonID` |
| `Customers.CustomerID` | `Sales.CustomerID`    |
| `Products.ProductID`   | `Sales.ProductID`     |

*Note: The `hadoopbucketers_sales_raw` database exists, **but should be avoided if possible** as this data has not passed Quality Analysis.*

## Raw Data Issues

Quality Analysis revealed that there was a repeated customer in the `Customer` database (`17829 Stefanie Smith`). To fix repeated data issues in the `hadoopbucketers_sales` database, only distinct values were taken from the `hadoopbucketers_sales_raw` database. Further, to ensure correct join functionality from `Sales`, only foreign key values within the range of the corresponding primary key were accepted.

There are a few other issues with the raw data that we noticed, but decided not to change since we do not know how the data was collected. Several items in `Products.csv` have listed prices of $0.00 or prices that otherwise do not make sense. For instance, Flat Washer 1 and Flat Washer 2 are listed at $0.00, while Flat Washer 3 is listed at $415.20. Also, many records in `Sales2.csv` have improbably high quantities. As one example, the sale with `OrderID = 4` has `ProductID = 358` and `Quantity = 358`. It seems unlikely that anyone would buy exactly 358 pairs of Women's Tights. Another potential issue is that blank values were just an empty string rather than null, but also decided not to change this as it doesn't change the functionality of the databases.

## Partition Performance

Queries against `customer_monthly_sales_2019_partitioned_view` (based on the partitioned sales data) ran faster in general than queries against `customer_monthly_sales_2019_view` (based on non-partitioned sales data). Queries which specify year *and* month were much faster on the partitioned view than on the non-partitioned view. This is due to the volume of data the query has to scan -- the partitioned view only opens and scans necessary data files, whereas the non-partitioned view has to scan all of a larger data file. The runtime we got for the partitioned view on a query with selecting two months had an average of 2.832 seconds over ten trials and the traditional view had an average of 7.708 seconds.

The performance gains in queries on these views were not as dramatic in queries which did not specify a month. Both views performed similarly in these cases -- this is due to the number of files opened in each query. The partitioned query has to open 12 separate files (one for each month), whereas the non-partitioned query opens just one file. This overhead slows the partitioned query, and results in a similar runtime. The partitioned view had a runtime of  6.382 seconds vs 7.562 seconds for the traditional view.

In business use cases where visualization is paramount, partitioning data is recommended. Queries on the data will run faster and the user will experience less latency when fetching results. It is important, however, to partition based on the queries that will be run most frequently and avoid opening too many small files. In this case, it is worth making a partition by month, but the gains from making a partition just by year would be minimal.
