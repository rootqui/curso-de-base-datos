-- tvf inline
CREATE FUNCTION <Nombre>
(
	<Parametros ... n>
)
RETURNS TABLE
AS
RETURN
(
	<UNA CONSULTA SIMPLE O COMPLEJA>
)

-- 1. Implementar tvf inline que retorne los 10 principales clientes, analizado por importe de importe de venta

ALTER FUNCTION uTF_TopTen_Clientes
(
)
RETURNS TABLE 
AS
RETURN
(
	SELECT TOP 10  
		H.CustomerID,
		P.FirstName + ' ' + COALESCE(P.MiddleName, '') + ' ' + P.LastName AS [FullNameCustomer], 
		SUM(TotalDue) AS TotalDue
	FROM SALES.SalesOrderHeader H
		--INNER JOIN SALES.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID 
		INNER JOIN Sales.Customer C ON C.CustomerID = H.CustomerID
		LEFT JOIN Person.Person P on P.BusinessEntityID = C.PersonID
	GROUP BY 
		H.CustomerID,
		P.FirstName + ' ' + COALESCE(P.MiddleName, '') + ' ' + P.LastName
	ORDER BY SUM(TotalDue) DESC
)
GO

SELECT * FROM uTF_TopTen_Clientes()

ALTER PROC uP_TopTen_Clientes
AS
BEGIN
	SELECT TT.FullNameCustomer, TT.TotalDue 
	FROM uTF_TopTen_Clientes() TT
END

EXEC uP_TopTen_Clientes

ALTER PROC uP_TopTen_Clientes_Territorio
AS
BEGIN
	SELECT TT.FullNameCustomer, T.Name, TT.TotalDue 
	FROM uTF_TopTen_Clientes() TT
		INNER JOIN Sales.Customer C ON C.CustomerID = TT.CustomerID
		LEFT JOIN Sales.SalesTerritory T ON T.TerritoryID = C.TerritoryID 
END

EXEC uP_TopTen_Clientes_Territorio


EXEC uP_TopTen_Clientes
EXEC uP_TopTen_Clientes_Territorio


--2. Implementar tvf inline, recibir parametro para la pk de la cabecera de venta, retornar los detalles de venta
CREATE FUNCTION uIF_Detalles_Ventas
(
	@SalesOrderId INT
)
RETURNS TABLE 
AS
RETURN
(
	SELECT D.* FROM SALES.SalesOrderDetail D
	WHERE D.SalesOrderID = @SalesOrderId
)
GO

SELECT * FROM uIF_Detalles_Ventas(43659)

--3. Implementar tvf inline, top 10 de productos por rango de fecha por importe de venta (SalesOrderDetail.LineTotal)

--4. Implementar tvf inline, reciba un año y un mes y retorne el calendario de ese periodo

ALTER FUNCTION uIF_Calendario_Anio_Mes
(
	@YEAR SMALLINT,
	@MONTH TINYINT
)
RETURNS TABLE 
AS
RETURN
(
	WITH
	CTE
	AS
	(
		SELECT DATEFROMPARTS(@YEAR,@MONTH,1) AS FECHA
		UNION ALL
		SELECT DATEADD(D,1, FECHA) AS FECHA
		FROM CTE
		WHERE FECHA < EOMONTH(DATEFROMPARTS(@YEAR,@MONTH,1))
	)
	SELECT * FROM CTE
)
GO

SELECT * from uIF_Calendario_Anio_Mes(2023, 4)

SELECT EOMONTH('20230401')