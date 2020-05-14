--*********************************************************************************
--CREATE Product/Region/Sales Materialized Table, partitioned by Region/Year/Month
--*********************************************************************************

SET VAR:database_name=hadoopbucketers_sales;

--Table: product_region_sales_partition
--OrderID, SalesPersonID, CustomerID, ProductID, 
--ProductName, ProductPrice, Quantity, TotalSalesAmount, 
--OrderDate, Region, Year, Month
CREATE TABLE IF NOT EXISTS ${var:database_name}.product_region_sales_partition 
PARTITIONED BY (region, year, month)
STORED AS Parquet 
AS select s.OrderID, s.SalesPersonID, s.CustomerID, p.ProductID, p.Name as ProductName, 
	p.Price as ProductPrice, s.Quantity, sum(s.Quantity * p.Price) as ThisSaleAmountInDollars, 
	s.PurchaseDate, e.Region as region, date_part('year', s.PurchaseDate) as year, 
	date_part('month', s.PurchaseDate) as month
from ${var:database_name}.Products p
join ${var:database_name}.Sales s on (p.ProductID = s.ProductID)
join ${var:database_name}.Employees e on (s.SalesPersonID = e.EmployeeID)
group by s.OrderID, s.SalesPersonID, s.CustomerID, p.ProductID, ProductName, 
	ProductPrice, s.Quantity, s.PurchaseDate, e.Region, year, month;
