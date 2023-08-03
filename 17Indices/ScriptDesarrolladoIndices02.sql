use AdventureWorks2019_2
go

dbcc freeproccache with no_infomsgs -- limpiar cache
go
dbcc dropcleanbuffers with no_infomsgs -- 
go
dbcc freesystemcache('all') with no_infomsgs
go

-- 1. Implementar indices para optimizar la consulta en la BD adventureworks2019_2

-- a. Determinar TE antes de la implementación de indices
select h.* 
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 42%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 58%

-- b. Determinar TE despues de la implementación de indices

sp_helpindex 'sales.salesorderdetail'

CREATE CLUSTERED INDEX PK_salesorderdetail_SalesOrderID_SalesOrderDetailID ON sales.salesorderdetail (SalesOrderID, SalesOrderDetailID)
GO

select h.* 
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 42%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 58%

sp_helpindex 'sales.salesorderdetail'

CREATE CLUSTERED INDEX PK_SalesOrderHeader_SalesOrderID ON Sales.SalesOrderHeader (SalesOrderID)
GO

select h.* 
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 41%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 59%

ALTER TABLE sales.salesorderheader ADD PRIMARY KEY (SalesOrderID)
GO

select h.* 
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 50%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 50%

--Se implemento la PK de la tabla SalesOrderDetail y se agrego la relación

select h.* 
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 62%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 38%

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Implementar indices para optimizar la consulta en la BD adventureworks2019_2
-- a. Determinar TE antes de la implementación de indices
select h.*
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID
where D.ProductID = 999 
--TE: 26%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID
where D.ProductID = 999 
--TE: 74%

-- b. Determinar TE despues de la implementación de indices

CREATE NONCLUSTERED INDEX IX_salesorderdetail_ProductID ON sales.salesorderdetail (ProductID)
GO

select h.*
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID
where D.ProductID = 999 
--TE: 50%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID
where D.ProductID = 999 
--TE: 50%

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3.Implementar indices para optimizar la consulta en la BD adventureworks2019_2

-- a. Determinar TE antes de la implementación de indices
select h.*
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
where D.ProductID = 999 AND D.SpecialOfferID = 2
--TE: 50%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
where D.ProductID = 999 AND D.SpecialOfferID = 2 
--TE: 50%

-- b. Determinar TE antes de la implementación de indices

CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_ProductID_SpecialOfferID ON [Sales].[SalesOrderDetail] ([ProductID],[SpecialOfferID])
GO

select h.*
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
where D.ProductID = 999 AND D.SpecialOfferID = 2
--TE: 70%

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
where D.ProductID = 999 AND D.SpecialOfferID = 2 
--TE: 30%

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--4.

select H.CustomerID, D.ProductID, SUM(OrderQty) AS OrderQty
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
GROUP BY H.CustomerID, D.ProductID

--TE: 44%

select H.CustomerID, D.ProductID, SUM(OrderQty) AS OrderQty
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
GROUP BY H.CustomerID, D.ProductID
--TE: 56%

--b: Con Indices

CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_CustomerID ON Sales.SalesOrderHeader (CustomerID)

select H.CustomerID, D.ProductID, SUM(OrderQty) AS OrderQty
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
GROUP BY H.CustomerID, D.ProductID
--TE: 50%

select H.CustomerID, D.ProductID, SUM(OrderQty) AS OrderQty
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
GROUP BY H.CustomerID, D.ProductID
--TE: 50%

CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_OrderQty ON Sales.SalesOrderDetail (OrderQty)
go

select H.CustomerID, D.ProductID, SUM(OrderQty) AS OrderQty
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
WHERE D.OrderQty = 1
GROUP BY H.CustomerID, D.ProductID
--TE: 49%

select H.CustomerID, D.ProductID, SUM(OrderQty) AS OrderQty
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
WHERE D.OrderQty = 1
GROUP BY H.CustomerID, D.ProductID
--TE: 51%

CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_OrderQty_ProductID ON [Sales].[SalesOrderDetail] ([OrderQty]) INCLUDE ([ProductID]) --???

select H.CustomerID, D.ProductID, SUM(OrderQty) AS OrderQty
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
WHERE D.OrderQty = 1
GROUP BY H.CustomerID, D.ProductID
--TE: 55%

select H.CustomerID, D.ProductID, SUM(OrderQty) AS OrderQty
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
WHERE D.OrderQty = 1
GROUP BY H.CustomerID, D.ProductID
--TE: 45%

DROP INDEX IX_SalesOrderDetail_OrderQty_ProductID ON [Sales].[SalesOrderDetail]

select h.*
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
where D.ProductID = 999 AND D.SpecialOfferID = 2 -- 20 SPs
	AND H.TerritoryID = 5 -- 2 SPs

CREATE NONCLUSTERED INDEX IX_SalesOrderDetail_OrderQty_ProductID ON [Sales].[SalesOrderDetail] (ProductID, SpecialOfferID) INCLUDE ([UnitPriceDiscount])
GO

--------------------
SELECT * FROM Sales.SalesOrderDetail 
ORDER BY UnitPriceDiscount

SELECT * FROM Sales.SalesOrderDetail 


SP_HELPINDEX 'Sales.SalesOrderHeader'

drop index IX_SalesOrderHeader_CustomerID on Sales.SalesOrderHeader

SELECT CustomerID FROM adventureworks2019.Sales.SalesOrderHeader
-- TE: 3%
SELECT CustomerID FROM adventureworks2019_2.Sales.SalesOrderHeader order by CustomerID
-- TE: 97%

create nonclustered index IX_SalesOrderHeader_CustomerID on Sales.SalesOrderHeader (CustomerID)

SELECT CustomerID FROM adventureworks2019.Sales.SalesOrderHeader
-- TE: 
SELECT CustomerID FROM adventureworks2019_2.Sales.SalesOrderHeader --order by CustomerID
-- TE: 
