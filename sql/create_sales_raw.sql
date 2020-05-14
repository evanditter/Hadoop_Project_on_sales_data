SET VAR:database_name=hadoopbucketers_sales_raw;
SET VAR:source_directory=/salesdb;

CREATE Database IF NOT EXISTS ${var:database_name}
COMMENT 'Raw Sales data imported from the SalesDB';

CREATE EXTERNAL TABLE IF NOT EXISTS ${var:database_name}.Sales(
  OrderID int,
  SalesPersonID int,
  CustomerID int,
  ProductID int,
  Quantity int,
  PurchaseDate Timestamp
) COMMENT "Sales table"
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${var:source_directory}/Sales2/'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE IF NOT EXISTS ${var:database_name}.Employees(
  EmployeeID int,
  FirstName varchar,
  MiddleInitial varchar,
  LastName varchar,
  Region varchar
) COMMENT "Employees table"
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '${var:source_directory}/Employees2/'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE IF NOT EXISTS ${var:database_name}.Customers(
  CustomerID int,
  FirstName varchar,
  MiddleInitial varchar,
  LastName varchar
) COMMENT "Customers table"
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${var:source_directory}/Customers2/'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE IF NOT EXISTS ${var:database_name}.Products(
  ProductID int,
  Name varchar,
  Price decimal(8,4)
) COMMENT "Products table"
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION '${var:source_directory}/Products/'
TBLPROPERTIES ("skip.header.line.count"="1");

invalidate metadata;
compute stats ${var:database_name}.sales;
compute stats ${var:database_name}.employees;
compute stats ${var:database_name}.customers;
compute stats ${var:database_name}.products;
