--***********************************************************************
--CREATE Product and Sales Materialized Table, partitioned by Year/Month
--***********************************************************************

SET VAR:database_name=hadoopbucketers_sales;

--Table: product_sales_partition
--OrderID, SalesPersonID, CustomerID, ProductID, 
--ProductName, ProductPrice, Quantity, TotalSalesAmount, 
--OrderDate, Year, Month
CREATE TABLE IF NOT EXISTS ${var:database_name}.product_sales_partition 
PARTITIONED BY (year, month)
STORED AS Parquet 
AS select s.OrderID, s.SalesPersonID, s.CustomerID, p.ProductID, p.Name as ProductName, 
	p.Price as ProductPrice, s.Quantity, sum(s.Quantity * p.Price) as ThisSaleAmountInDollars, 
	s.PurchaseDate, date_part('year', s.PurchaseDate) as year, 
	date_part('month', s.PurchaseDate) as month
from ${var:database_name}.Products p
join ${var:database_name}.Sales s on (p.ProductID = s.ProductID)
group by s.OrderID, s.SalesPersonID, s.CustomerID, p.ProductID, ProductName, 
	ProductPrice, s.Quantity, s.PurchaseDate, year, month;
