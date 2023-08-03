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
--TE: 

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
--TE: 

-- b. Determinar TE despues de la implementación de indices

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Implementar indices para optimizar la consulta en la BD adventureworks2019_2
-- a. Determinar TE antes de la implementación de indices
select h.*
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID
where D.ProductID = 999 
--TE: 

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID
where D.ProductID = 999 
--TE: 

-- b. Determinar TE despues de la implementación de indices


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3.Implementar indices para optimizar la consulta en la BD adventureworks2019_2
-- a. Determinar TE antes de la implementación de indices
select h.*
from adventureworks2019.sales.salesorderheader H
	INNER JOIN adventureworks2019.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
where D.ProductID = 999 AND D.SpecialOfferID = 2
--TE: 

select h.*
from adventureworks2019_2.sales.salesorderheader H
	INNER JOIN adventureworks2019_2.sales.salesorderdetail D ON H.SalesOrderID = D.SalesOrderID 
where D.ProductID = 999 AND D.SpecialOfferID = 2 
--TE: 

-- b. Determinar TE antes de la implementación de indices
