SET VAR:source_database=hadoopbucketers_sales_raw;
SET VAR:database_name=hadoopbucketers_sales;

CREATE DATABASE IF NOT EXISTS ${var:database_name}
COMMENT 'Parquet sales data imported from raw sales database';

--Create Parquet Sales table
CREATE TABLE IF NOT EXISTS ${var:database_name}.Sales
COMMENT 'Parquet Sales table'
STORED AS Parquet
AS SELECT DISTINCT OrderID, SalesPersonID,CustomerID,ProductID,Quantity,PurchaseDate FROM ${var:source_database}.Sales
WHERE (SalesPersonID BETWEEN 1 AND 23) AND (CustomerID BETWEEN 1 AND 19759) AND (ProductID BETWEEN 1 AND 504);

--Create Parquet Employees table
-- NEED TO SELECT REGION AS Upper(region)
CREATE TABLE IF NOT EXISTS ${var:database_name}.Employees
COMMENT 'Parquet Employees table'
STORED AS Parquet
AS SELECT DISTINCT EmployeeID, UPPER(FirstName) AS FirstName, UPPER(MiddleInitial) AS MiddleInitial, UPPER(LastName) AS LastName, UPPER(Region) as Region
FROM ${var:source_database}.Employees;

--Create Parquet Customers table
CREATE TABLE IF NOT EXISTS ${var:database_name}.Customers
COMMENT 'Parquet Customers table'
STORED AS Parquet
AS SELECT DISTINCT CustomerID, UPPER(FirstName) AS FirstName, UPPER(MiddleInitial) AS MiddleInitial, UPPER(LastName) AS LastName FROM ${var:source_database}.Customers;

--Create Parquet Products table
CREATE TABLE IF NOT EXISTS ${var:database_name}.Products
COMMENT 'Parquet Products table'
STORED AS Parquet
AS SELECT DISTINCT ProductID, UPPER(NAME) AS Name, Price FROM ${var:source_database}.Products;

invalidate metadata;
compute stats ${var:database_name}.sales;
compute stats ${var:database_name}.employees;
compute stats ${var:database_name}.customers;
compute stats ${var:database_name}.products;
