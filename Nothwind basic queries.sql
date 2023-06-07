show tables;

select * from orders;

# 1) How many unique order id are there

select count(distinct OrderID) from orders;

# 2) How many unique ShipVia are there

select count(distinct ShipVia) from orders;

# 3) Total shipping city count
select ShipCity, count(*)
from orders
group by 1
order by 2 desc;

# 4) Shipping Region count
select ShipRegion, count(*)
from orders
group by 1
order by 2 desc;

# 5) Bottom 5 Ship country by number of orders wise

select ShipCountry, count(*)
from orders
group by 1
order by 2 asc
limit 5;

# 6) Desriptive Statistics of Freight - {Count, Min, Max, Mean, Std}


select 
	count(Freight) as `Count`,
	min(Freight) as `Min Freight`, 
	round(max(Freight),2) as `Max Freight`, 
	round(avg(Freight),2) as `Average Freight`,
	round(stddev(Freight),2) as `Std Freight`
from orders;

# 7) Create a new variable called OrderDays based on Required & Shipped Date

alter table orders
add column OrderDays bigint;

update orders
set OrderDays = datediff(ShippedDate,RequiredDate);

select 
	count(OrderDays) as `Total Counts`,
	min(OrderDays) as `Min Days`,
	max(OrderDays) as `Max Days`,
	round(avg(OrderDays),2) as `Avg Days`,
	round(std(OrderDays),2) as `Std Days`
from orders;

# 8) Create a new variable on devliery status based on OrderDays on-time(0), Early(<0) and delay(>0)

alter table orders
add column DeliveryStatus varchar(10);

update orders
set DeliveryStatus = 
case when OrderDays = 0 then 'on-time'
when OrderDays <0 then 'Early'
else 'Delay'
end;

select DeliveryStatus,count(*)
from orders
group by 1;

# 9) create a column sales in order details table using the formula 
# Sales = UnitPrice * Quantity * (1-Discount)
select * from `order details`;

alter table `order details`
add column Sales float;

update `order details`
set Sales = UnitPrice * Quantity * (1-Discount);

select 
	count(Sales) as 'count',
	min(Sales) as 'min',
	max(Sales) as 'Max',
	round(avg(Sales),2) as 'Avg',
	round(std(Sales),2) as 'STD'
from `order details`;
-------------------------------------------------------------------------------------
# 2 Types of joins
# 1) Natural Join - No need to specify Common column
# 2) Join using (Specify common column)

# 10) Customer Countrywise total sales

select 
	Country, 
    round(sum(Sales),2) as TotalSales
from `order details`
	natural join orders
	natural join customers
	group by 1
	order by 2 desc;
    
# 11) Customer Countrywise Average Sales

select 
	Country, 
    round(avg(Sales),2) as AverageSale
from `order details`
	natural join orders
	natural join customers
	group by 1
	order by 2 desc;

# 12) Customer Citywise Total Sales
select 
	City, 
    round(sum(Sales),2) as TotalSales
from `order details`
	natural join orders
	natural join customers
	group by 1
	order by 2 desc;

# 13) Customer Citywise Average sales

select 
	City, 
    round(avg(Sales)) as 'Average Sales'
from `order details`
	natural join orders
	natural join customers
	group by 1
	order by 2 desc;

# 14) Top 20 Customer CompanyName wise Total Sales

select 
	CompanyName, 
    round(sum(Sales)) as 'Total Sales'
from `order details`
	natural join orders
	natural join customers
	group by 1
	order by 2 desc
	limit 20;

# 15) Bottom 20 Customer Companyname wise Total Sales

select 
	CompanyName, 
    round(sum(Sales)) as 'Total Sales'
from `order details`
	natural join orders
	natural join customers
	group by 1
	order by 2 asc
	limit 20;

# 16) Employee wise Total Sales, concat(Firstname, LastName)
select 
	concat(FirstName,LastName) as 'Full Name', 
    round(sum(Sales)) as 'Total Sales'
from `order details`
	natural join employees
	natural join orders
	group by 1
	order by 2 desc;


# 17) Employee wise Country wise total sales

select 
	concat(FirstName,LastName) as 'Full Name', 
    Country,
    round(sum(Sales)) as 'Total Sales'
from `order details`
	natural join employees
	natural join orders
	group by 1,2
	order by 2 desc;
    
# 2nd query

select 
concat(e.FirstName,e.LastName) as 'Full Name', 
c.Country as 'Customer Country', 
round(sum(od.Sales))
from orders o
left join employees e 
on o.EmployeeID = e. EmployeeID
left join customers c
on o.CustomerID = c.CustomerID
left join `order details` od 
on o.OrderID = od.OrderID
group by 1,2
order by 3 desc;

select * from customers;

# 18) Employee wise city wise Toatl Sales

select 
	concat(FirstName,LastName) as 'Full Name', 
    customers.City,
    round(sum(Sales)) as 'Total Sales'
from `order details`
	natural join employees
	natural join orders
    join customers using(CustomerID)
	group by 1
	order by 3 desc;
    
    
# 19) Top 10 Customer CompanyName based on TotalSales

select 
	CompanyName, 
	round(sum(Sales)) as 'Total Sales'
from orders
	natural join `order details`
	natural join customers
	group by 1
	order by 2 desc
	limit 10;


# 20) Top 5 Customer companyname in USA based on TotalSales

select 
	companyname, 
    round(sum(Sales)) as 'Total Sales'
from orders
	natural join `order details`
	natural join customers
	where Country = 'USA'
	group by 1
	order by 2
	limit 5;


# 21) Year wise TotalSales (use ShippedDate from orders table)

select 
	year(ShippedDate) as 'Year', 
    round(sum(Sales)) as 'Total Sales'
from orders
	natural join `order details`
	group by 1
	order by 2 desc;

# 22) Year, Quarter, Month wise TotalSales

select 
	year(ShippedDate) as 'Year Wise', 
	quarter(ShippedDate) as 'Quarter Wise', 
	month(ShippedDate) as 'Month Wise', 
	round(sum(Sales)) as 'Total Sales' 
from orders
	natural join `order details`
	group by 1,2,3
	order by 1 desc;

# 23) Calculate New Variable Purchases = (UnitsinStock+UnitsonOder)*UnitPrice in products table

alter table products
add column Purchases float;

update products
set Purchases = (UnitsInStock + UnitsOnOrder) * UnitPrice;

select 
	count(Purchases) as 'Count',
	min(Purchases) as 'Min',
	max(Purchases) as 'Max',
	round(avg(Purchases)) as 'Avg',
	round(std(Purchases)) as 'Std'
from products;


# 24) Country Wise Purchases

select 
	Country,
    round(sum(Purchases)) as 'Total Purchase'
from  products
	natural join suppliers
	group by 1
	order by 2 desc;


# 25) Top 10 Purchase Company from France

select 
	CompanyName,
    round(sum(Purchases)) as 'Total Purchase'
from  products
	natural join suppliers
    where Country = 'France'
    group by 1
	order by 2 desc
    limit 10;
    
# 26) Discountinued=1 means product discontinued. Identify productname
# that are discontinued and unitsinstock & unitsonorder

select 
    ProductName,
    UnitsInStock,
    UnitsOnOrder,
    Discontinued
from products 
	where Discontinued = 1;

# 27) Costliest and Cheapest unitprice

select 
	round(min(UnitPrice),2) as 'Cheapest Price',
    round(max(UnitPrice),2) as 'Costliest Price'
from products;

# 28) Costliest and Cheapest productname from Purchases

select 
	UnitPrice,
    ProductName
from products 
	where UnitPrice in 
		(select max(UnitPrice) from products 
         union all
         select min(UnitPrice) from products
         );

# 29) Costliest and Cheapest productname sold to Customers

SELECT productname, MAX(unitprice) as MaxPrice, MIN(unitprice) as MinPrice
FROM
(
    SELECT productname, unitprice
    FROM `order details` natural join products
    UNION ALL
    SELECT productname, unitprice
    FROM `order details` natural join products
) as subQuery
GROUP BY productname
order by Maxprice,minprice desc;


# 30) Create a report showing all customers from Germany, Mexico & Spain
# containing ContactName, City,Address.

select 
	ContactName,
    City,
    Country
from customers
	where Country in ('Germany','Mexico','Spain');

# 31) Create a report showing all cities starting with F or M or L 
# contain contactname, city, address. Like F%

select 
	ContactName,
    City,
    PostalCode,
    Country
from customers
	where City like 'F%' or
    City like 'M%' or
    City like '%L';

# 32) Create a report OrderId, Requireddate,Shippeddate where shippeddate
# is greater than requireddate.

# 33) Create a report from employees table showing yearswithcompany as
# on 1996 containing conactenation of First & Last name, hireddate

# 34) Create a report of all orders in Q3 of 1995 containing orderid, shippeddate, Freight.

# 35) Create a report of Top 10 Freight with Orderid, shippeddate, country, companyname from customers

# 36) Create a report of Top 20 customer companyname based on totalfreight

# 37) Create a Report of Top 5 companyname and country that ordered categoryname Confections

# 38) Create a Report of Top 5 companyname and country that supplied categoryname Confections

# 39) Create a report where Categorynamewise number of products with unit price greather 20.


