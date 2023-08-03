SELECT * FROM Sales.SalesOrderHeader 

--1. Consulta de ventas por año

SELECT Year(OrderDate) AS OrderDate_Year, SUM(TotalDue) AS TotalDue
FROM Sales.SalesOrderHeader 
GROUP BY Year(OrderDate)
UNION ALL
SELECT 2015, 1000

SELECT *
FROM 
	(
		SELECT Year(OrderDate) AS OrderDate_Year, SUM(TotalDue) AS TotalDue
		FROM Sales.SalesOrderHeader 
		GROUP BY Year(OrderDate)
		UNION ALL
		SELECT 2015, 1000
	) B
	PIVOT 
	(
		SUM(TotalDue) FOR OrderDate_Year IN ([2011],[2012],[2013],[2014],[2015])
	) P


DECLARE @EJERCICIOS VARCHAR(MAX) = '[2011],[2012],[2013],[2014],[2015]'

sELECT *
FROM 
	(
		SELECT Year(OrderDate) AS OrderDate_Year, SUM(TotalDue) AS TotalDue
		FROM Sales.SalesOrderHeader 
		GROUP BY Year(OrderDate)
		UNION ALL
		SELECT 2015, 1000
	) B
	PIVOT 
	(
		SUM(TotalDue) FOR OrderDate_Year IN (@EJERCICIOS)
	) P


DECLARE @SQL VARCHAR(MAX) = 
'
sELECT *
FROM 
	(
		SELECT Year(OrderDate) AS OrderDate_Year, SUM(TotalDue) AS TotalDue
		FROM Sales.SalesOrderHeader 
		GROUP BY Year(OrderDate)
		UNION ALL
		SELECT 2015, 1000
	) B
	PIVOT 
	(
		SUM(TotalDue) FOR OrderDate_Year IN ([2011],[2012],[2013],[2014],[2015])
	) P
'

EXEC (@SQL)

-----
--2. Consulta de ventas por año dinámico

ALTER PROC uSP_AnalisisPorRangoAnual
	@Year_Ini smallint,
	@Year_Fin smallint
AS
BEGIN
	DECLARE @EJERCICIOS VARCHAR(MAX) = ''

	SELECT Year(OrderDate) AS OrderDate_Year, SUM(TotalDue) AS TotalDue
	INTO #TEMP
	FROM Sales.SalesOrderHeader 
	WHERE Year(OrderDate) BETWEEN @Year_Ini AND @Year_Fin
	GROUP BY Year(OrderDate)

	SELECT @EJERCICIOS = @EJERCICIOS + '[' + CONVERT(VARCHAR, OrderDate_Year) + '],'
	FROM #TEMP
	ORDER BY OrderDate_Year

	SET @EJERCICIOS = LEFT(@EJERCICIOS, LEN(@EJERCICIOS) - 1)

	DECLARE @SQL VARCHAR(MAX) = 
	'
	SELECT *
	FROM 
		(
			SELECT OrderDate_Year, TotalDue
			FROM #TEMP
		) B
		PIVOT 
		(
			SUM(TotalDue) FOR OrderDate_Year IN (' + @EJERCICIOS + ')
		) P
	'

	EXEC (@SQL)


END
GO

EXEC uSP_AnalisisPorRangoAnual 2011, 2015




