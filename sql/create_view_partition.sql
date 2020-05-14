--*************************************************
--CREATE View on Sales Data from Partitioned Table
--*************************************************

SET VAR:database_name=hadoopbucketers_sales;

--View: customer_monthly_sales_2019_partitioned_view
--Customer id, customer last name, customer first name,
--year, month, aggregate total amount
--of all products purchased by month for 2019.
CREATE VIEW IF NOT EXISTS ${var:database_name}.customer_monthly_sales_2019_partitioned_view AS
select ps.CustomerID, c.LastName, c.FirstName, ps.Year, ps.Month, 
	sum(ps.ThisSaleAmountInDollars) as TotalSalesAmountInDollars
from ${var:database_name}.product_sales_partition ps
join ${var:database_name}.customers c on (ps.CustomerID = c.CustomerID)
where Year = 2019
group by ps.CustomerID, c.LastName, c.FirstName, ps.Year, ps.Month;
