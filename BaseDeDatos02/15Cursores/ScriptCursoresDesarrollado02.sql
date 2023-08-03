CREATE TABLE CALENDARIO (ID INT PRIMARY KEY, FECHA DATE)
GO

;WITH
CTE
AS
(
	SELECT CONVERT(DATE, '20230101') AS FECHA
	UNION ALL
	SELECT DATEADD(D, 1, FECHA) AS FECHA
	FROM CTE
	WHERE FECHA < '20230131'
)
INSERT INTO CALENDARIO
SELECT ROW_NUMBER() OVER (ORDER BY FECHA ASC), FECHA
FROM CTE

SELECT * FROM CALENDARIO

-- 1. PLANTILLA
DECLARE <NOMBRE> CURSOR
	FOR
		<CONSULTA>
OPEN <NOMBRE>
WHILE @@FETCH_STATUS = 0
BEGIN
	FETCH NEXT FROM <NOMBRE>
END 
CLOSE <NOMBRE>
DEALLOCATE <NOMBRE>

-- 2. Implementar cursor para recorrer los dias del mes de enero 2023
DECLARE Registros_Enero CURSOR
	FOR
		SELECT FECHA FROM CALENDARIO WHERE FECHA BETWEEN '20230101' AND '20230131'
OPEN Registros_Enero
FETCH NEXT FROM Registros_Enero
CLOSE Registros_Enero
DEALLOCATE Registros_Enero

-- 3. Implementar cursor para recorrer los dias del mes de enero 2023
DECLARE Registros_Enero CURSOR
	FOR
		SELECT FECHA FROM CALENDARIO WHERE FECHA BETWEEN '20230101' AND '20230115'
OPEN Registros_Enero
FETCH NEXT FROM Registros_Enero
WHILE @@FETCH_STATUS = 0
BEGIN
	FETCH NEXT FROM Registros_Enero
END 
CLOSE Registros_Enero
DEALLOCATE Registros_Enero

-- 4. Implementar cursor para recorrer los dias del mes de enero 2023
DECLARE @FECHA DATE, @MES TINYINT

DECLARE Registros_Enero CURSOR
	FOR
		SELECT FECHA 
		FROM CALENDARIO WHERE FECHA BETWEEN '20230101' AND '20230115'
OPEN Registros_Enero
FETCH NEXT FROM Registros_Enero
INTO @FECHA
WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @FECHA, YEAR(@FECHA), MONTH(@FECHA)

	FETCH NEXT FROM Registros_Enero
	INTO @FECHA
END 
CLOSE Registros_Enero
DEALLOCATE Registros_Enero

------
DECLARE @FECHA DATE, @MES TINYINT

;WITH
CTE
AS
(
	SELECT FECHA 
	FROM CALENDARIO WHERE FECHA BETWEEN '20230101' AND '20230115'
)
SELECT * INTO #TEMP FROM CTE

DECLARE Registros_Enero CURSOR
	FOR 
		SELECT * FROM #TEMP
OPEN Registros_Enero
FETCH NEXT FROM Registros_Enero
INTO @FECHA
WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @FECHA, YEAR(@FECHA), MONTH(@FECHA)

	FETCH NEXT FROM Registros_Enero
	INTO @FECHA
END 
CLOSE Registros_Enero
DEALLOCATE Registros_Enero


-- 5. TIPOS DE CURSORES
-- A) STANDARD: SOLO AVANCE
-- B) SCROLL

DECLARE Registros_Enero CURSOR SCROLL
	FOR
		SELECT FECHA FROM CALENDARIO WHERE FECHA BETWEEN '20230101' AND '20230115'
OPEN Registros_Enero
FETCH NEXT FROM Registros_Enero --2023-01-01 -- RETORNAR EL SIGUIENTE
FETCH NEXT FROM Registros_Enero --2023-01-02
FETCH PRIOR FROM Registros_Enero --2023-01-01 -- RETORNAR EL ANTERIOR
FETCH LAST FROM Registros_Enero --2023-01-15 --RETORNAR EL ULTIMO
FETCH FIRST FROM Registros_Enero --2023-01-01 --RETORNAR EL PRIMERO
FETCH ABSOLUTE 1 FROM Registros_Enero --2023-01-01 --RETORNAR LA POSICION ABSOLUTA
FETCH ABSOLUTE 0 FROM Registros_Enero --
FETCH ABSOLUTE 10 FROM Registros_Enero --
FETCH RELATIVE 0 FROM Registros_Enero -- 2023-01-10
FETCH RELATIVE 2 FROM Registros_Enero -- 2023-01-12
FETCH RELATIVE -3 FROM Registros_Enero -- 2023-01-09

DECLARE @POS INT = 2
FETCH RELATIVE @POS FROM Registros_Enero -- 2023-01-09

CLOSE Registros_Enero
DEALLOCATE Registros_Enero

-----------------------------

-- A) Implementar procedimiento almacenado que reciba una fecha de onomastico, notifica a cada trabajador un mensaje de saludo por su cumpleaños

ALTER PROC uP_NotificarOnomastico
	@Fecha DATE
AS
BEGIN
	DECLARE @FullName VARCHAR(200), @BirthDate DATE, @EmailAddress VARCHAR(50)

	DECLARE Onomastico CURSOR 
		FOR 
			SELECT P.FirstName + ' ' + COALESCE(P.MiddleName, '') + ' ' + P.LastName AS FullName, E.BirthDate, C.EmailAddress
			FROM Person.Person P
				INNER JOIN HumanResources.Employee E ON P.BusinessEntityID = E.BusinessEntityID 
				INNER JOIN Person.EmailAddress C ON C.BusinessEntityID = P.BusinessEntityID
			WHERE MONTH(E.BirthDate) = MONTH(@Fecha)
				AND DAY(E.BirthDate) = DAY(@Fecha)
	OPEN Onomastico
	FETCH NEXT FROM Onomastico
	INTO @FullName, @BirthDate, @EmailAddress
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC uP_NotificarOnomastico_Personal @FullName, @EmailAddress

		FETCH NEXT FROM Onomastico
		INTO @FullName, @BirthDate, @EmailAddress
	END
	CLOSE Onomastico
	DEALLOCATE Onomastico
END
GO

ALTER PROC uP_NotificarOnomastico_Personal
	@FullName VARCHAR(200),
	@EmailAddress VARCHAR(50)
AS
BEGIN
	SELECT 'Estimado :' + @FullName + ' el ISur te saluda por tu cumple.'
END 
GO

EXEC uP_NotificarOnomastico '20231225'

-- B) (Cursores Anidados) Implementar SP que notifique en formato XML a cada cliente sus ventas mensuales el Sp tiene que revivir un rango de fechas

DECLARE @OrderDate_Ini DATE = '20140101', @OrderDate_Fin DATE = '20140630'

EXEC uP_NotificarVentas_Rango '20140101', '20140331'

ALTER PROC uP_NotificarVentas_Rango
	@OrderDate_Ini DATE, 
	@OrderDate_Fin DATE
AS
BEGIN
	DECLARE @CustomerID int, @TotalDue money, @mes tinyint

	SELECT H.CustomerID, P.FirstName + ' ' + COALESCE(P.MiddleName, '') + ' ' + P.LastName AS FullName, E.EmailAddress, H.OrderDate, H.TotalDue 
	INTO #TEMP
	FROM Sales.SalesOrderHeader H
		INNER JOIN Sales.Customer C ON H.CustomerID = C.CustomerID 
		INNER JOIN Person.Person P ON P.BusinessEntityID = C.PersonID
		INNER JOIN Person.EmailAddress E ON E.BusinessEntityID = P.BusinessEntityID
	WHERE H.OrderDate BETWEEN @OrderDate_Ini AND @OrderDate_Fin

	DECLARE Clientes CURSOR
		FOR
			SELECT CustomerID
			FROM #TEMP
			GROUP BY CustomerID
	OPEN Clientes 
	FETCH NEXT FROM Clientes 
	INTO @CustomerID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE Ventas CURSOR
			FOR
				SELECT MONTH(OrderDate) AS MES, SUM(TotalDue) AS TotalDue
				FROM #TEMP
				WHERE CustomerID = @CustomerID
				GROUP BY MONTH(OrderDate)
		OPEN Ventas
		FETCH NEXT FROM Ventas
		INTO @MES, @TotalDue
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC uP_NotificarVentas_Mensual @MES, @TotalDue

			FETCH NEXT FROM Ventas
			INTO @MES, @TotalDue
		END
		
		FETCH NEXT FROM Clientes 
		INTO @CustomerID
	END
	CLOSE Clientes 
	DEALLOCATE Clientes 
END
GO