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

DESCRIBE Sales;

delimiter ;
-- print SP
call sp_LithiaReports();

-- See a list of procedures in database spring19
SHOW PROCEDURE STATUS WHERE DB = 'LithiaMotors';

# See how the procedure is created. 
SHOW CREATE PROCEDURE sp_LithiaReports;

# Delete Existing procedure
DROP PROCEDURE p2;

-- Creating transactions

-- Example 1: The use of transaction with rollback ------
START TRANSACTION;

UPDATE feedback SET CustomerFeedback = 'Very Good' WHERE CustomerID = '49999-598';

-- It has been updated in the displayed output. 
SELECT * FROM Feedback;

-- We don't like it, rollback.
-- 'Undo' previous operation
ROLLBACK;

-- After rolling back, the original data is still there. No update has been made. 
SELECT * FROM feedback;

-- Example 2: The use of transction with commit (execute it) ------
START TRANSACTION;

UPDATE feedback SET CustomerFeedback = 'Very Good' WHERE CustomerID = '49999-598';

-- It has been updated in the displayed output. 
SELECT * FROM feedback;

-- It looks ok. We can now commit it to make the actual change. 
-- After "commit", the change cannot be "rollback". 
COMMIT;

SELECT * FROM feedback; # Now the data is changed permanently.
ROLLBACK; # Rollback will not make any effect now.

-- Create the first trigger to check the value before inserting into the table. 
-- If the total value is wrong, we will modify the inserted value. 

-- Create a column profit on sales table
alter table Sales
add column Profit double;

-- The transaction
DELIMITER $
CREATE TRIGGER transacttion1 BEFORE INSERT ON Sales
FOR EACH ROW
BEGIN
	IF NEW.Profit != NEW.Sales.SalesAmountAfterDis - NEW.Product.CarPrice THEN
		SET NEW.Profit = NEW.Sales.SalesAmountAfterDis - NEW.Product.CarPrice;
	END IF;
END; $
DELIMITER ;


# Here, we create the second trigger used to capture the total inserted value. 
# This trigger use a SQL variable @totalinsert. 
# It is run after the INSERT operation, so it will capture the actual value being inserted into the table. 
CREATE TRIGGER transacttion2 AFTER INSERT ON Sales
FOR EACH ROW
SET @totalinsert = @totalinsert + NEW.Profit;


-- See a list of available triggers and how they were defined.
SHOW triggers;

-- Since the second trigger is using a variable, we will need to initial one first. 
SET @totalinsert = 0;

-- demo
# Now if we insert a record with wrong total value, it will be "corrected". 
INSERT INTO Sales VALUES(1.2,10,11);
SELECT * FROM Sales;

# The totalinsert will capture the "corrected" value. 
SELECT @totalinsert;

# If we insert multiple "wrong" value. All will be "corrected".
INSERT INTO Sales VALUES(1.2,10,11), (1.3,10,11);
SELECT * FROM Sales;


-- remove a trigger.
-- DROP TRIGGER t1;
-- DROP TRIGGER t2;

-- simple Example of Evants
-- A query to see all available processes. 
SHOW PROCESSLIST;
-- Turn on event scheduler, before using event
SET GLOBAL event_scheduler = ON;
-- Turn off event scheduler
SET GLOBAL event_scheduler = OFF;

SHOW EVENTS;


-- wait 20 sec and the result will be updated. 
SELECT * FROM evettable;


-- It will disappear after executing. But you can always drop the event before it executes.
DROP EVENT e1;


-- Alternative way I. Run at specific time
CREATE EVENT e1
ON SCHEDULE 
AT '2020-10-03 12:00:00'
DO 
UPDATE evettable SET a = a + 1;


SHOW EVENTS;
DROP EVENT e1;

-- Run recursively
-- DAY can be replaced by HOUR, MONTH, WEEK, MINUTE
CREATE EVENT e1
ON SCHEDULE 
EVERY 1 MINUTE
DO 
UPDATE evettable SET a = a + 1;

SHOW EVENTS;
DROP EVENT e1;

-- Run recursively with ending time
-- DAY can be replaced by HOUR, MONTH, WEEK, MINUTE
CREATE EVENT e1
ON SCHEDULE 
EVERY 1 HOUR STARTS '2020-10-03 13:00:00' ENDS '2020-10-03 14:00:00'
DO 
UPDATE evettable SET a = a + 1;

SHOW EVENTS;
DROP EVENT e1;

-- Query Optimization #######
-- See a list of tables with more details. 
SHOW TABLE STATUS;

-- If you have too many tables, you can display selected table details. 
SHOW TABLE STATUS LIKE 'Sales';

select * from Sales;
-- Create temporary table - is just like regular table. 
CREATE TEMPORARY TABLE test AS (SELECT * FROM Sales WHERE OrderID = '42043-251');

-- We can use it to run queries
SELECT * FROM test;

# But we cannot see the table name in the list, and it will be removed after the session ends. 
SHOW FULL TABLES;
































