--*************************************
--CREATE Views on Sales Data
--*************************************

SET VAR:database_name=hadoopbucketers_sales;

--View: customer_monthly_sales_2019_view
--Customer id, customer last name, customer first name,
--year, month, aggregate total amount
--of all products purchased by month for 2019.
CREATE VIEW IF NOT EXISTS ${var:database_name}.customer_monthly_sales_2019_view AS
select c.CustomerID, c.LastName, c.FirstName, date_part('year', s.PurchaseDate) as Year, 
	date_part('month', s.PurchaseDate) as Month, sum(s.Quantity * p.Price) as TotalSalesAmountInDollars
from ${var:database_name}.Customers c
join ${var:database_name}.Sales s on (c.CustomerID = s.CustomerID)
join ${var:database_name}.Products p on (s.ProductID = p.ProductID)
where date_part('year', s.PurchaseDate) = 2019
group by c.CustomerID, c.LastName, c.FirstName, Year, Month;

--View: top_ten_customers_amount_view
--Customer id, customer last name,
--customer first name, total lifetime purchased amount
--only returns top 10 customers
CREATE VIEW IF NOT EXISTS ${var:database_name}.top_ten_customers_amount_view AS
select c.CustomerID, c.LastName, c.FirstName, sum(s.Quantity * p.Price) as LifetimeSalesAmountInDollars
from ${var:database_name}.Customers c
join ${var:database_name}.Sales s on (c.CustomerID = s.CustomerID)
join ${var:database_name}.Products p on (s.ProductID = p.ProductID)
group by c.CustomerID, c.LastName, c.FirstName
order by LifetimeSalesAmountInDollars desc 
limit 10;
