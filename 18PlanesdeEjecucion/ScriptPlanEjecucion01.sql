select * from sales.SalesOrderDetail where ProductID = 776
select * from sales.SalesOrderDetail with (index=0) where ProductID = 776

sp_helpindex 'sales.SalesOrderDetail'


select * from sales.SalesOrderDetail where ProductID = 776
select * from AdventureWorks2019_2.Sales.SalesOrderDetail where ProductID = 776

select * from sales.SalesOrderDetail where ProductID = 776
select * from sales.SalesOrderDetail where ProductID = 776 order by OrderQty 
select sum(OrderQty) from sales.SalesOrderDetail where ProductID = 776
select SpecialOfferID, count(1) from sales.SalesOrderDetail where ProductID = 776 group by SpecialOfferID 

select *
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID

select h.*
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID

select h.SalesOrderID, h.OrderDate, h.Status, h.CustomerID  
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID

select h.SalesOrderID, h.OrderDate, h.Status, h.CustomerID  
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
where d.ProductID = 776