-- Create new database for Lithia Motors
drop database if exists LithiaMotors;
create database LithiaMotors;
use LithiaMotors;

create table CarSCM like car_supplychainmanagementdataset;
insert into CarSCM (select * from car_supplychainmanagementdataset);

-- Create table for suppliers
create table Suppliers
( 	SupplierID int(20) unique not null,
	SupplierAddress text(200) not null, 
	SupplierName text(50) not null,  
	SupplierContactDetails numeric(20) not null,
	ProductID int(20)not null unique,
	constraint supplier_pk primary key (SupplierID),
	constraint productid_fk foreign key (ProductID) references Products(ProductID)
);
alter table Suppliers
modify column SupplierContactDetails text;

create table Products
(	ProductID int(20) not null unique,
	CarMaker text(50) not null,
    CarModel text(50) not null,
	CarColor text(50) not null,
	CarModelYear int (20) not null,
	CarPrice double (50,2) not null,
    CustomerID nvarchar(200) not null,
	constraint productid_pk primary key (ProductID),
	constraint customer_fk foreign key (CustomerID) references Customers(CustomerID)
);

/* This code was used to create new columns and modification
alter table Products
add productidd INT(20) not null unique auto_increment;

alter table Products AUTO_INCREMENT = 1002;

alter table car_supplychainmanagementdataset
drop column productidd;

alter table Products
drop primary key;

alter table Products
modify column ProductID int(20);

alter table Products
rename column ProductID to Prod;

alter table Products
add primary key(productidd);

alter table Products
rename column productidd to ProductID;
*/

create table Customers 
( 	CustomerID nvarchar(200) unique not null,
	CustomerName text(50) not null,
    Gender text(20) ,
    JobTitle text(50),
    PhoneNumber text(50),
    EmailAddress text(50),
    City text(50),
	Country text(50),
	CountryCode text (10),
	State text (50),
	CustomerAddress text (200),
    constraint customer_pk primary key (CustomerID)
);

-- print out duplicate rows in products table
select ProductID, count(ProductID) as count
	from car_supplychainmanagementdataset
	group by ProductID 
	having count(*) >1 
    order by count desc;

-- print out duplicate ProductID that are have different Car maker and dieeferent model
select ProductID, CarMaker, CarModel
	from car_supplychainmanagementdataset
    where ProductID in ( select ProductID
	from car_supplychainmanagementdataset
	group by ProductID 
	having count(*) >1) 
    order by ProductID, CarMaker desc;

-- Create new column
alter table car_supplychainmanagementdataset
add column productidd int(20);
-- add unique constriant to existing column
alter table car_supplychainmanagementdataset
add unique (ProductID);

select * from Products;
alter table car_supplychainmanagementdataset
drop constraint productidd;

select productidd, count(productidd) as count
	from car_supplychainmanagementdataset
	group by productidd
	having count(*) >1 
    order by count desc;

select productidd,  count(productidd) as num
	from car_supplychainmanagementdataset
    where productidd in ( select productidd
	from car_supplychainmanagementdataset
	group by productidd 
	having count(*) >1) 
    order by productidd desc;

/*update car_supplychainmanagementdataset
set productidd = ProductID;
update car_supplychainmanagementdataset
set productidd = ProductID + SupplierID - 3; */

update car_supplychainmanagementdataset
set productidd = productidd  + 100 -1 
where car_supplychainmanagementdataset.productidd in (select * from( select max(f.productidd)
	from car_supplychainmanagementdataset f
	group by productidd 
	having count(*) > 1) temp);



select * from car_supplychainmanagementdataset;
-- Product table
select * from car_supplychainmanagementdataset where ProductID = 69499;
select * from car_supplychainmanagementdataset where ProductID = 9043;
select * from car_supplychainmanagementdataset where ProductID = 4531;
select * from car_supplychainmanagementdataset where ProductID = 5712;

-- data modification
update car_supplychainmanagementdataset
set ProductID = 88540
where SupplierID = 8;

update car_supplychainmanagementdataset
set ProductID = 90430
where SupplierID = 9;

update car_supplychainmanagementdataset
set ProductID = 45310
where SupplierID = 15;



-- print out duplicate rows in customer table
select CustomerID
	from car_supplychainmanagementdataset
	group by CustomerID
	having count(*) >1;

-- Customer table modification
select * from car_supplychainmanagementdataset where CustomerID = "43269-780";
select * from car_supplychainmanagementdataset where CustomerID = "53603-1006";
select * from car_supplychainmanagementdataset where CustomerID = "76237-153";
select * from car_supplychainmanagementdataset where CustomerID = "49693-1801";
select * from car_supplychainmanagementdataset where CustomerID = "36987-3061";
select * from car_supplychainmanagementdataset where CustomerID =  "47593-359";


-- Creating update to Customer id to make it unique
update car_supplychainmanagementdataset
set CustomerID = "47593-358"
where SupplierID = 264;

update car_supplychainmanagementdataset
set CustomerID = "36987-3062"
where SupplierID = 576;

update car_supplychainmanagementdataset
set CustomerID = "49693-1802"
where SupplierID = 21;

update car_supplychainmanagementdataset
set CustomerID = "53603-1005"
where SupplierID = 176;

update car_supplychainmanagementdataset
set CustomerID = "76237-152"
where SupplierID = 240;

-- print out duplicate rows
select CustomerID
from car_supplychainmanagementdataset
group by CustomerID
having count(*) >1;


create table Orders 
(	OrderDate text,
	OrderID nvarchar(200) not null,
	CustomerID nvarchar(200) not null,
    constraint productid_pk primary key (OrderID),
	constraint order_fk foreign key (CustomerID) references Customers(CustomerID)
);

create table Shipment 
(	ShipDate text,
	ShipMode text,
	Shipping text,
    ProductID int(20) not null unique,
    CustomerID nvarchar(200) not null unique,
    OrderID nvarchar(200) not null,
    constraint order_fk1 foreign key (OrderID) references Orders(OrderID),
    constraint custome_fk foreign key (CustomerID) references Customers(CustomerID),
	constraint products_fk foreign key (ProductID) references Products(ProductID)
);

create table Sales 
(	PostalCode int(20),
	SalesAmountBefore double(200,2),
	Quantity int(2),
	Discount double(30, 2),
    ProductID int(20) not null unique,
    CustomerID nvarchar(200) not null unique,
    OrderID nvarchar(200) not null,
	constraint order_fk2 foreign key (OrderID) references Orders(OrderID),
    constraint custome_fk2 foreign key (CustomerID) references Customers(CustomerID),
	constraint products_fk2 foreign key (ProductID) references Products(ProductID)
);


create table paymentType 
(	CreditCardType text not null,
	CreditCard double(50,2) not null,
    CustomerID nvarchar(200) not null unique,
	constraint custome_fk3 foreign key (CustomerID) references Customers(CustomerID)
);

create table feedback 
(	CustomerFeedback text,
	CustomerID nvarchar(200) not null unique,
	constraint custome_fk4 foreign key (CustomerID) references Customers(CustomerID)
);


select * from car_supplychainmanagementdataset;
-- Change the data type for OrderID
alter table car_supplychainmanagementdataset
modify column OrderID nvarchar(200);
-- Change the data type for CustomerID
alter table car_supplychainmanagementdataset
modify column CustomerID nvarchar(200);


-- insert into tables
-- supplier table
insert into Suppliers
( 	select SupplierID, SupplierAddress, SupplierName, SupplierContactDetails, ProdID  
	from car_supplychainmanagementdataset
);

-- Product table
insert into Products (CarMaker, CarModel, CarColor,CarModelYear, CarPrice,
		CustomerID, ProductID) (select CarMaker, CarModel, CarColor, CarModelYear, CarPrice, CustomerID, ProdID
		from  car_supplychainmanagementdataset);
select * from Products;

-- create new columns
alter table Products
rename column ProductID to prods;

alter table Products
rename column Prod to ProductID;

update Products
set Prod = ProductID;

alter table Products
modify column ProductID int(200) not null primary key;

alter table Products
drop primary key;

alter table Products
drop Prod;

-- Customers
insert into Customers (select CustomerID, CustomerName, Gender, JobTitle, PhoneNumber, EmailAddress, City ,
	Country, CountryCode, State, CustomerAddress
    from car_supplychainmanagementdataset);
select * from Customers;

-- data modification 
alter table car_supplychainmanagementdataset
modify column ProdID int(20) not null;

update car_supplychainmanagementdataset
set ProdID = ProdID * 10;

alter table car_supplychainmanagementdataset
add column ProdID2 int(20) primary key not null auto_increment;


insert into Orders (OrderDate, OrderID, CustomerID)(select OrderDate, OrderID, CustomerID
													from  car_supplychainmanagementdataset);
											
select * from Orders;

select * from car_supplychainmanagementdataset where OrderID = 0363-0459;

-- Verify if order number is the same thing with customer name and order date
-- if not change the order id .
select OrderID, CustomerName, OrderDate
	from car_supplychainmanagementdataset
    where OrderID in ( select OrderID
	from car_supplychainmanagementdataset
	group by OrderID
	having count(*) >1) 
    ;

update car_supplychainmanagementdataset
set OrderID = concat( '45802-283', "1")
where SupplierID = 10;

select * from car_supplychainmanagementdataset where OrderID = '45802-283';

-- insert into sales table
insert into Sales (PostalCode, SalesAmountBefore,Quantity, Discount, ProductID,CustomerID,
                    OrderID)(select PostalCode, Sales,Quantity, Discount, 
                    ProdID,CustomerID,OrderID
					from  car_supplychainmanagementdataset);
select * from Sales;

-- insert into shipment table
insert into Shipment (ShipDate,ShipMode,Shipping,ProductID,CustomerID,OrderID)
					(select ShipDate,ShipMode,Shipping,ProdID,CustomerID,OrderID
					from  car_supplychainmanagementdataset);
select * from Shipment;

-- insert into paymentType table
insert into paymentType (CreditCardType,CreditCard,CustomerID)
					(select CreditCardType,CreditCard,CustomerID
					from  car_supplychainmanagementdataset);
select * from paymentType;

-- insert into feedback table
insert into feedback (CustomerFeedback,CustomerID)
					(select CustomerFeedback,CustomerID
					from  car_supplychainmanagementdataset);
select * from feedback;
select * from Customers;
select * from orders;
select * from paymentType;
select * from Products;
select * from Sales;
select * from Shipment;
select * from Suppliers;

alter table Sales
rename column SalesAmountBefore to SalesAmountAfterDis;

alter table sales
add column SalesAmountBefore double(200,2);
-- insert into the column created
update Sales
set SalesAmountBefore = (SalesAmountAfterDis * Discount) + SalesAmountAfterDis;

















































































































































































































































