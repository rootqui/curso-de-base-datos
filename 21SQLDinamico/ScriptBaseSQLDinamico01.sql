SELECT * FROM Sales.SalesOrderHeader 

--1. Consulta de ventas por año

SELECT Year(OrderDate) AS OrderDate_Year, SUM(TotalDue) AS TotalDue
FROM Sales.SalesOrderHeader 
GROUP BY Year(OrderDate)
UNION ALL
SELECT 2015, 100


SELECT *
FROM 
	(
		SELECT Year(OrderDate) AS OrderDate_Year, SUM(TotalDue) AS TotalDue
		FROM Sales.SalesOrderHeader 
		GROUP BY Year(OrderDate)
		UNION ALL
		SELECT 2015, 100
	) B
	PIVOT 
	(
		SUM(TotalDue) FOR OrderDate_Year IN ([2011],[2012],[2013],[2014],[2015])
	) P