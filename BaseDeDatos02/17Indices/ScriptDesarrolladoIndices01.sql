-- Indices
CREATE <TIPO INDICE> INDEX <NOMBRE> ON <TABLA> (<COLUMNA(s)>)
GO

<TIPO INDICE>: 
	CLUSTERED: Guia Telefonica , solo permite uno por tabla, mas costoso, fisico I/O
	NONCLUSTERED: Indices de libros, n indices por tabla, menos costoso

USE AdventureWorks2019 
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
DBCC FREESYSTEMCACHE('ALL') WITH NO_INFOMSGS

USE AdventureWorks2019_2
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
DBCC FREESYSTEMCACHE('ALL') WITH NO_INFOMSGS

SELECT * FROM AdventureWorks2019.Sales.SalesOrderHeader   
SELECT * FROM AdventureWorks2019_2.Sales.SalesOrderHeader   

USE AdventureWorks2019 
GO

sp_helpindex 'Sales.SalesOrderHeader'
sp_help 'Sales.SalesOrderHeader'

USE AdventureWorks2019_2
GO

sp_helpindex 'Sales.SalesOrderHeader'
sp_help 'Sales.SalesOrderHeader'

-----------------------------

SELECT * 
FROM AdventureWorks2019.Sales.SalesOrderHeader H  
	inner join AdventureWorks2019.Sales.SalesOrderDetail D on H.SalesOrderID = D.SalesOrderID

SELECT * 
FROM AdventureWorks2019_2.Sales.SalesOrderHeader H  
	inner join AdventureWorks2019_2.Sales.SalesOrderDetail D on H.SalesOrderID = D.SalesOrderID

SP_HELPINDEX 'Sales.SalesOrderHeader'


-----------

USE AdventureWorks2019 
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
DBCC FREESYSTEMCACHE('ALL') WITH NO_INFOMSGS

USE AdventureWorks2019_2
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
DBCC FREESYSTEMCACHE('ALL') WITH NO_INFOMSGS


SELECT * FROM AdventureWorks2019.Sales.SalesOrderHeader where CustomerID = 29747 -- 3%
SELECT * FROM AdventureWorks2019_2.Sales.SalesOrderHeader where CustomerID = 29747 -- 97%

USE AdventureWorks2019_2
GO

CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_CustomerID ON Sales.SalesOrderHeader (CustomerID)

USE AdventureWorks2019 
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
DBCC FREESYSTEMCACHE('ALL') WITH NO_INFOMSGS

USE AdventureWorks2019_2
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
DBCC FREESYSTEMCACHE('ALL') WITH NO_INFOMSGS

SELECT * FROM AdventureWorks2019.Sales.SalesOrderHeader where CustomerID = 29747 --50%
SELECT * FROM AdventureWorks2019_2.Sales.SalesOrderHeader where CustomerID = 29747 --50%

USE AdventureWorks2019 
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
DBCC FREESYSTEMCACHE('ALL') WITH NO_INFOMSGS

USE AdventureWorks2019_2
GO

DBCC FREEPROCCACHE WITH NO_INFOMSGS
DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS
DBCC FREESYSTEMCACHE('ALL') WITH NO_INFOMSGS

SELECT * FROM AdventureWorks2019.Sales.SalesOrderHeader where OrderDate between '20110101' and '20111231'
SELECT * FROM AdventureWorks2019_2.Sales.SalesOrderHeader where OrderDate between '20110101' and '20111231'

SELECT * FROM AdventureWorks2019.Sales.SalesOrderHeader where month(OrderDate) = 12
SELECT * FROM AdventureWorks2019_2.Sales.SalesOrderHeader where month(OrderDate) = 12

DROP INDEX IX_SalesOrderHeader_CustomerID ON Sales.SalesOrderHeader
GO

SP_HELPINDEX 'Sales.SalesOrderHeader'


SELECT * FROM AdventureWorks2019.Sales.SalesOrderHeader where CustomerID = 29747 -- 3%
SELECT * FROM AdventureWorks2019_2.Sales.SalesOrderHeader where CustomerID = 29747 -- 97%

CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_CustomerID ON Sales.SalesOrderHeader (CustomerID)


