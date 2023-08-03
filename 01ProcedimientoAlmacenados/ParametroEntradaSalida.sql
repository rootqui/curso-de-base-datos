-- Parametros de entreda y salida
select * from production.product

--1. Implementar un SP para concultar la tabla product, debe recibir 2 parametros: uno obligatorio para filtrar por el nombre del producto con busqueda aproximada
--, el segundo de tipo opcional para filtrar por color 

ALTER PROC uP_Product_Consulta
	@Name VARCHAR(100), -- Obligatorio
	@Color VARCHAR(30) = NULL -- Opcional
AS
BEGIN
	SELECT * 
	FROM PRODUCTION.PRODUCT P
	WHERE P.NAME LIKE '%' + @Name + '%'
		AND COALESCE(P.COLOR, '') = COALESCE(@Color, COALESCE(P.COLOR, ''))
END
GO

EXEC uP_Product_Consulta 'a' 

--2. Implementar un SP basado en el SP previo, que retorne el numero de registros de la consulta

ALTER PROC uP_Product_Consulta_ParametroSalida
	@Name VARCHAR(100), -- Obligatorio / Entrada
	@Color VARCHAR(30) = NULL, -- Opcional / Entrada
	@Registros INT = 0 OUTPUT -- Opcional / Entrada y Salida
AS
BEGIN
	DECLARE @X INT

	--SET @X = 
	--(
	--SELECT COUNT(1) 
	--FROM PRODUCTION.PRODUCT P
	--WHERE P.NAME LIKE '%' + @Name + '%'
	--	AND COALESCE(P.COLOR, '') = COALESCE(@Color, COALESCE(P.COLOR, ''))
	--)

	--SELECT @X = COUNT(1)
	--FROM PRODUCTION.PRODUCT P
	--WHERE P.NAME LIKE '%' + @Name + '%'
	--	AND COALESCE(P.COLOR, '') = COALESCE(@Color, COALESCE(P.COLOR, ''))

	--SELECT @X

	SELECT * 
	FROM PRODUCTION.PRODUCT P
	WHERE P.NAME LIKE '%' + @Name + '%'
		AND COALESCE(P.COLOR, '') = COALESCE(@Color, COALESCE(P.COLOR, ''))

	SET @Registros = @@ROWCOUNT 
END
GO

EXEC uP_Product_Consulta_ParametroSalida 'a' 

DECLARE @N INT = 9
EXEC uP_Product_Consulta_ParametroSalida @Name = 'a',  @Registros = @N --OUTPUT
SELECT @N

DECLARE @N INT = 9
EXEC uP_Product_Consulta_ParametroSalida @Name = 'a',  @Registros = @N OUTPUT
SELECT @N


--3. Implementar SP que retorne el importe total de venta de la tabla SalesOrderHeader (TotalDue), utilizar parametro de salida

CREATE PROC uP_SalesOrderHeader_TotalVentas
	@TotalDue MONEY OUTPUT -- Entrada
AS
BEGIN
	SELECT @TotalDue = SUM(H.TotalDue)
	FROM Sales.SalesOrderHeader H
END

DECLARE @ImporteTotal MONEY
EXEC uP_SalesOrderHeader_TotalVentas @ImporteTotal OUTPUT
SELECT @ImporteTotal

-- 4.Implementar SP, basado en el SP previo, que permita especificar un rango de fechas de consulta (OrderDate), 
-- si no se especifica la fecha final, se debe asumir la fecha de hoy


CREATE PROC uP_SalesOrderHeader_TotalVentas_Rango
	@FechaInicial DATE, 
	@FechaFinal DATE = NULL,
	@TotalDue MONEY OUTPUT -- Entrada
AS
BEGIN
	SELECT @TotalDue = SUM(H.TotalDue)
	FROM Sales.SalesOrderHeader H
	WHERE H.OrderDate BETWEEN @FechaInicial AND COALESCE(@FechaFinal, GETDATE())
END
GO

DECLARE @ImporteTotal MONEY
EXEC uP_SalesOrderHeader_TotalVentas_Rango '20110101', '20111231', @ImporteTotal OUTPUT
SELECT @ImporteTotal

SELECT MAX(OrderDate), MIN(OrderDate) 
FROM Sales.SalesOrderHeader

--5. Implementar SP que retorne las fechas maximas y minimas de la columna (OrderDate)  de la tabla SalesOrderHeader

CREATE PROC uP_SalesOrderHeader_FechasMaxMin
	@fecha_max DATE OUTPUT,
	@fecha_min DATE OUTPUT
AS
BEGIN
	SELECT @fecha_max = MAX(H.OrderDate), @fecha_min = MIN(H.OrderDate)
	FROM Sales.SalesOrderHeader H
END
GO

DECLARE @MAX DATE, @MIN DATE 
EXEC uP_SalesOrderHeader_FechasMaxMin @MAX OUTPUT, @MIN OUTPUT
SELECT @MAX, @MIN