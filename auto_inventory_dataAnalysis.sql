Use LithiaMotors;
select * from feedback;
select * from Customers;
select * from orders;
select * from paymentType;
select * from Products;
select * from Sales;
select * from Shipment;
select * from Suppliers;

alter table Sales
add column SalesAmountBefore double(200,2);
-- calculate initial payment of the Car before discount

update Sales
set SalesAmountBefore = (SalesAmountAfterDis * Discount) + SalesAmountAfterDis;

-- Aggregate the Number of Car Bought in each state 
Select State , count(Quantity) as Sales_Figure from (
	select c.State, s.Quantity
	from  Sales as s
	inner join Customers as c
	on s.CustomerID = c.CustomerID
	join Products as p
	on p.CustomerID = c.CustomerID
	) as t
    group by t.State
	order by Sales_Figure desc;

-- Calculate Profit for each Year
select * from  Orders;

-- Convert the column to date
update Orders
set OrderDate = str_to_date(OrderDate, "%m/%d/%y");

-- Create a new column to take the new date format and extract the year from the date
alter table Orders
add column OrderDatee date;
update Orders
set OrderDatee = cast(OrderDate as date);

-- Using the year function to extract year from the date
alter table Orders
add column `Year` int (10);
update Orders
set `Year` = year(OrderDate);

-- Sales Quantity by year and total Sales and Profit for the year
select `Year`, Sum(SalesAmountAfterDis) as TotalSale, count(Quantity) as QuantitySold,
	sum(CarPrice) as PruchasedPrice, (Sum(SalesAmountAfterDis) - sum(CarPrice)) as "Profit By Year"
	from(
	select o.`Year`, s.SalesAmountAfterDis , s.Quantity, p.CarPrice
	from Orders o
	inner join Sales s
	on o.OrderID = s.OrderID
	join Customers c
	on c.CustomerID = s.CustomerID
    join Products p
    on p.CustomerID = o.CustomerID
    ) as t
    group by `Year`
    order by TotalSale desc;

-- Query to find highest sales price of an of a Car?
select s.SalesAmountAfterDis as Highest, c.State, c.CustomerName
from Sales s
inner join Customers c
on c.CustomerID = s.CustomerID
where SalesAmountAfterDis in (select max(SalesAmountAfterDis) from Sales);

-- Query to find 2nd highest sales price of an of a Car?
select max(t.SalesAmountAfterDis) as `Second Highest`, t.State, t.CustomerName
from(
select s.SalesAmountAfterDis, c.State, c.CustomerName
from Sales s
join Customers c
on c.CustomerID = s.CustomerID
WHERE SalesAmountAfterDis in (select max(SalesAmountAfterDis) from Sales)) t;



-- SPlit First and last name from full name
select CustomerName from Customers;

-- substring first name and last name
ALTER TABLE Customers
add column First_name varchar(50);

update Customers
set First_name = substring(CustomerName, 1, instr(CustomerName, " "));

-- add lastname
ALTER TABLE Customers
add column Last_name varchar(50);
update Customers
set Last_name = reverse(substring(reverse(CustomerName), 1, instr(reverse(CustomerName), " ")));

select * from Customers;

create table reports select p.ProductID, p.CarMaker, p.CarModel, p.CarColor, p.CarModelYear, 
	p.CarPrice, c.City, c.State, c.Country, o.OrderDate, o.OrderID, 
    sh.ShipDate, sh.Shipping, s.PostalCode, sh.ShipMode, s.SalesAmountAfterDis, s.SalesAmountBefore,
	s.Quantity, s.Discount, CustomerFeedback, o.`Year`
	from 
	Products p
	inner join Customers c
	on c.CustomerID = p.CustomerID
	join Orders o
	on o.CustomerID = c.CustomerID
	join Shipment sh
	on sh.CustomerID = c.CustomerID
	join Sales s
	on s.ProductID = p.ProductID
    join feedback f
    on f.CustomerID=c.CustomerID ;
    
select * from reports; 
    
-- VIEW 
CREATE or replace view Vsales as select p.ProductID, p.CarMaker, p.CarModel, p.CarColor, p.CarModelYear, 
	p.CarPrice, c.City, c.State, c.Country, o.OrderDate, o.OrderID, 
    sh.ShipDate, sh.Shipping, s.PostalCode, sh.ShipMode, s.SalesAmountAfterDis, s.SalesAmountBefore,
	s.Quantity, s.Discount, CustomerFeedback, o.`Year`
	from 
	Products p
	inner join Customers c
	on c.CustomerID = p.CustomerID
	join Orders o
	on o.CustomerID = c.CustomerID
	join Shipment sh
	on sh.CustomerID = c.CustomerID
	join Sales s
	on s.ProductID = p.ProductID
    join feedback f
    on f.CustomerID=c.Customer;

-- CREATE STORED PROCEDURE
delimiter //

create procedure sp_LithiaReports()

begin 
	select p.ProductID, p.CarMaker, p.CarModel, p.CarColor, p.CarModelYear, 
	p.CarPrice, c.City, c.State, c.Country, o.OrderDate, o.OrderID, 
    sh.ShipDate, sh.Shipping, s.PostalCode, sh.ShipMode, s.SalesAmountAfterDis, s.SalesAmountBefore,
	s.Quantity, s.Discount, CustomerFeedback, o.`Year`
	from 
	Products p
	inner join Customers c
	on c.CustomerID = p.CustomerID
	join Orders o
	on o.CustomerID = c.CustomerID
	join Shipment sh
	on sh.CustomerID = c.CustomerID
	join Sales s
	on s.ProductID = p.ProductID
    join feedback f
    on f.CustomerID = c.CustomerID;
    
end //

delimiter ;
-- print SP
call sp_LithiaReports();






















































