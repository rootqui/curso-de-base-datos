set statistics time off 
set statistics io off

select *
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
where d.ProductID = 776

select h.*
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
where d.ProductID = 776

select h.SalesOrderID, h.OrderDate 
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
where d.ProductID = 776

select h.CustomerID, d.ProductID, sum(d.OrderQty) as OrderQty
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
group by h.CustomerID, d.ProductID


CREATE TABLE CALENDARIO (PK INT IDENTITY (1,1) PRIMARY KEY, FECHA DATE)

;WITH
CTE
AS
(
	SELECT CONVERT(DATE, '20230701') AS FECHA
	UNION ALL
	SELECT DATEADD(D, 1, FECHA) 
	FROM CTE
	WHERE FECHA < '20230731'
)
SELECT * FROM CTE

SET XACT_ABORT ON 
BEGIN TRANSACTION
;WITH
CTE
AS
(
	SELECT CONVERT(DATE, '20230701') AS FECHA
	UNION ALL
	SELECT DATEADD(D, 1, FECHA) 
	FROM CTE
	WHERE FECHA < '20230731'
)
INSERT INTO CALENDARIO 
SELECT FECHA FROM CTE
COMMIT TRANSACTION



;WITH
CTE
AS
(
	SELECT CONVERT(DATE, '20230101') AS FECHA
	UNION ALL
	SELECT DATEADD(D, 1, FECHA) 
	FROM CTE
	WHERE FECHA < '20230131'
)
SELECT FECHA INTO #TEMP FROM CTE

DECLARE @FECHA DATE

DECLARE CALENDAR CURSOR
	FOR
		SELECT FECHA FROM #TEMP
OPEN CALENDAR
FETCH NEXT FROM CALENDAR
INTO @FECHA
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO CALENDARIO VALUES (@FECHA)
	FETCH NEXT FROM CALENDAR
	INTO @FECHA
END 
CLOSE CALENDAR
DEALLOCATE CALENDAR

-----

SET STATISTICS XML OFF

select *
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
where d.ProductID = 776


----
SET SHOWPLAN_XML OFF

select *
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
where d.ProductID = 776

---
SET SHOWPLAN_TEXT OFF

select *
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
where d.ProductID = 776

---

SET SHOWPLAN_ALL OFF

select *
from sales.SalesOrderHeader h
	inner join sales.SalesOrderdetail d on h.SalesOrderID = d.SalesOrderID
where d.ProductID = 776


------------ pROFILER

SET XACT_ABORT ON 
BEGIN TRANSACTION
;WITH
CTE
AS
(
	SELECT CONVERT(DATE, '20230301') AS FECHA
	UNION ALL
	SELECT DATEADD(D, 1, FECHA) 
	FROM CTE
	WHERE FECHA < '20230331'
)
INSERT INTO CALENDARIO 
SELECT FECHA FROM CTE
COMMIT TRANSACTION
