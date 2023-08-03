DECLARE 
	@OrderDateYear SMALLINT = 2014,
	@OrderDateMonthIni TINYINT = 1,
	@OrderDateMonthFin TINYINT = 2,
	@ProductID INT = 999

SELECT D.ProductID, P.NAME, DATENAME(month, H.OrderDate) /*MONTH(H.OrderDate)*/ AS OrderDateMonth, SUM(D.OrderQty) AS OrderQty
FROM SALES.SalesOrderHeader H
	INNER JOIN SALES.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
	INNER JOIN SALES.SpecialOfferProduct O ON O.SpecialOfferID = D.SpecialOfferID AND O.ProductID = D.ProductID
	INNER JOIN Production.Product P ON P.ProductID = O.ProductID
WHERE YEAR(H.OrderDate) = @OrderDateYear
	AND MONTH(H.OrderDate) BETWEEN @OrderDateMonthIni AND COALESCE(@OrderDateMonthFin, MONTH(H.OrderDate))
	AND D.ProductID = COALESCE(@ProductID, D.ProductID)
GROUP BY D.ProductID, P.NAME, DATENAME(month, H.OrderDate) --MONTH(H.OrderDate)

ALTER PROC uP_AnalisisVentaAnioRangoMeses
	@OrderDateYear SMALLINT,
	@OrderDateMonthIni TINYINT,
	@OrderDateMonthFin TINYINT = NULL,
	@ProductID INT = NULL
AS
BEGIN
	SELECT D.ProductID, P.NAME, DATENAME(month, H.OrderDate) /*MONTH(H.OrderDate)*/ AS OrderDateMonth, SUM(D.OrderQty) AS OrderQty
	FROM SALES.SalesOrderHeader H
		INNER JOIN SALES.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
		INNER JOIN SALES.SpecialOfferProduct O ON O.SpecialOfferID = D.SpecialOfferID AND O.ProductID = D.ProductID
		INNER JOIN Production.Product P ON P.ProductID = O.ProductID
	WHERE YEAR(H.OrderDate) = @OrderDateYear
		AND MONTH(H.OrderDate) BETWEEN @OrderDateMonthIni AND COALESCE(@OrderDateMonthFin, MONTH(H.OrderDate))
		AND D.ProductID = COALESCE(@ProductID, D.ProductID)
	GROUP BY D.ProductID, P.NAME, MONTH(H.OrderDate), DATENAME(month, H.OrderDate) --MONTH(H.OrderDate)
	ORDER BY D.ProductID, MONTH(H.OrderDate)
END
GO

EXEC uP_AnalisisVentaAnioRangoMeses 2014, 2, NULL, 707
EXEC uP_AnalisisVentaAnioRangoMeses 2014, 2, NULL

----------
DROP TABLE #TEMP

DECLARE 
	@OrderDateYear SMALLINT = 2014,
	@OrderDateMonthIni TINYINT = 1,
	@OrderDateMonthFin TINYINT = 2,
	@ProductID INT = 999

CREATE TABLE #TEMP (ProductID INT, NAME VARCHAR(200), OrderDateMonth TINYINT, OrderQty INT, OrderQtyAcum INT, Orden INT)

INSERT INTO #TEMP
SELECT D.ProductID, P.NAME, MONTH(H.OrderDate) AS OrderDateMonth, SUM(D.OrderQty) AS OrderQty, 0,
	ROW_NUMBER() OVER (ORDER BY D.ProductID, MONTH(H.OrderDate)) AS Orden
FROM SALES.SalesOrderHeader H
	INNER JOIN SALES.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
	INNER JOIN SALES.SpecialOfferProduct O ON O.SpecialOfferID = D.SpecialOfferID AND O.ProductID = D.ProductID
	INNER JOIN Production.Product P ON P.ProductID = O.ProductID
WHERE YEAR(H.OrderDate) = @OrderDateYear
	AND MONTH(H.OrderDate) BETWEEN @OrderDateMonthIni AND COALESCE(@OrderDateMonthFin, MONTH(H.OrderDate))
	AND D.ProductID = COALESCE(@ProductID, D.ProductID)
GROUP BY D.ProductID, P.NAME, MONTH(H.OrderDate)

SELECT * FROM #TEMP

DECLARE @REG_MAX INT = (SELECT MAX(ORDEN) FROM #TEMP), @REG INT = 1 

WHILE @REG <= @REG_MAX
BEGIN
	--SELECT * FROM #TEMP WHERE ORDEN = @REG
	UPDATE #TEMP
	SET OrderQtyAcum = 
	FROM 

	SET @REG = @REG + 1
END
