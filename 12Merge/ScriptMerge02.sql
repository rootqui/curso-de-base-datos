CREATE TABLE CLIENTE (CODIGO INT PRIMARY KEY, NOMBRE_COMPLETO VARCHAR(200), TERRITORIO VARCHAR(200))
GO

--1. Implementar un SP que sincronice la tabla Cliente con el contenido de la union de las tables Person y Customer 
-- de la base AdventureWorks

SELECT C.CUSTOMERID, P.FirstName + ' ' + COALESCE(P.MiddleName , '') + ' ' + P.LastName AS FullName,
	T.Name AS Name_Territory
FROM SALES.CUSTOMER C
	INNER JOIN PERSON.PERSON P ON P.BusinessEntityID = C.PERSONID
	LEFT JOIN SALES.SalesTerritory T ON T.TerritoryID = C.TerritoryID

CREATE PROC uP_Sincronizar_Cliente
AS
BEGIN
	MERGE
		INTO CLIENTE AS T -- tabla destino
		USING
			( 
				SELECT C.CUSTOMERID, P.FirstName + ' ' + COALESCE(P.MiddleName , '') + ' ' + P.LastName AS FullName,
					T.Name AS Name_Territory
				FROM SALES.CUSTOMER C
					INNER JOIN PERSON.PERSON P ON P.BusinessEntityID = C.PERSONID
					LEFT JOIN SALES.SalesTerritory T ON T.TerritoryID = C.TerritoryID
			)
		AS S --tabla/select 
		ON T.CODIGO = S.CUSTOMERID

		WHEN NOT MATCHED --INSERTAR 
			THEN 
				INSERT (CODIGO, NOMBRE_COMPLETO, TERRITORIO)
				VALUES (S.CUSTOMERID, S.FullName, S.Name_Territory)

		WHEN MATCHED --ACTUALIZAR
			AND (NOMBRE_COMPLETO <> S.FullName OR TERRITORIO <> S.Name_Territory)
			THEN 
				UPDATE 
				SET 
					NOMBRE_COMPLETO = S.FullName,
					TERRITORIO = S.Name_Territory

		WHEN NOT MATCHED BY SOURCE --ELIMINAR
			THEN 
				DELETE
				
		OUTPUT $ACTION, INSERTED.*, DELETED.*
	;
END
GO

EXEC uP_Sincronizar_Cliente

SELECT * FROM CLIENTE

--2. Implementar un SP que sincronice la tabla Cliente con el contenido de la union de las tables Person y Customer 
-- de la base AdventureWorks (USAR TABLAS TEMPORALES LOCALES COMO ESTRUCTURA ORIGEN)
	
TRUNCATE TABLE CLIENTE

CREATE PROC uP_Sincronizar_Cliente_Tabla_Temporal_Local
AS
BEGIN
	SELECT C.CUSTOMERID, P.FirstName + ' ' + COALESCE(P.MiddleName , '') + ' ' + P.LastName AS FullName,
		T.Name AS Name_Territory
	INTO #CLIENTE
	FROM SALES.CUSTOMER C
		INNER JOIN PERSON.PERSON P ON P.BusinessEntityID = C.PERSONID
		LEFT JOIN SALES.SalesTerritory T ON T.TerritoryID = C.TerritoryID
		
	MERGE
		INTO CLIENTE AS T -- tabla destino
		USING #CLIENTE AS S --tabla/select 
		ON T.CODIGO = S.CUSTOMERID

		WHEN NOT MATCHED --INSERTAR 
			THEN 
				INSERT (CODIGO, NOMBRE_COMPLETO, TERRITORIO)
				VALUES (S.CUSTOMERID, S.FullName, S.Name_Territory)

		WHEN MATCHED --ACTUALIZAR
			AND (NOMBRE_COMPLETO <> S.FullName OR TERRITORIO <> S.Name_Territory)
			THEN 
				UPDATE 
				SET 
					NOMBRE_COMPLETO = S.FullName,
					TERRITORIO = S.Name_Territory

		WHEN NOT MATCHED BY SOURCE --ELIMINAR
			THEN 
				DELETE
				
		OUTPUT $ACTION, INSERTED.*, DELETED.*
	;
END
GO

--3. Implementar un SP que sincronice la tabla Cliente con el contenido de la union de las tables Person y Customer 
-- de la base AdventureWorks (USAR CTEs COMO ESTRUCTURA ORIGEN)  el SP debe recibir 2 parametros para el rango de fecha
-- de modificacion en la tabla Customer (ModifiedDate)



CREATE PROC uP_Sincronizar_Cliente_CTE
	@Fecha_Ini DATE,
	@Fecha_Fin DATE = NULL
AS
BEGIN
	WITH
	CTE_CLIENTES
	AS
	(
		SELECT C.CUSTOMERID, P.FirstName + ' ' + COALESCE(P.MiddleName , '') + ' ' + P.LastName AS FullName,
			T.Name AS Name_Territory
		FROM SALES.CUSTOMER C
			INNER JOIN PERSON.PERSON P ON P.BusinessEntityID = C.PERSONID
			LEFT JOIN SALES.SalesTerritory T ON T.TerritoryID = C.TerritoryID
		WHERE C.ModifiedDate BETWEEN @Fecha_Ini AND COALESCE(@Fecha_Fin, C.ModifiedDate)
	)
	MERGE
		INTO CLIENTE AS T -- tabla destino
		USING CTE_CLIENTES AS S --tabla/select 
		ON T.CODIGO = S.CUSTOMERID

		WHEN NOT MATCHED --INSERTAR 
			THEN 
				INSERT (CODIGO, NOMBRE_COMPLETO, TERRITORIO)
				VALUES (S.CUSTOMERID, S.FullName, S.Name_Territory)

		WHEN MATCHED --ACTUALIZAR
			AND (NOMBRE_COMPLETO <> S.FullName OR TERRITORIO <> S.Name_Territory)
			THEN 
				UPDATE 
				SET 
					NOMBRE_COMPLETO = S.FullName,
					TERRITORIO = S.Name_Territory

		WHEN NOT MATCHED BY SOURCE --ELIMINAR
			THEN 
				DELETE
				
		OUTPUT $ACTION, INSERTED.*, DELETED.*
	;
END
GO

 
TRUNCATE TABLE CLIENTE 
EXEC uP_Sincronizar_Cliente_CTE '20070101'
