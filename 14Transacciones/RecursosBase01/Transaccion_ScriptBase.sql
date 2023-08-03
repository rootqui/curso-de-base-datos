CREATE PROC uP_Insertar_Ordenes
	@XML XML	
AS
BEGIN
	--Leer e insertar Clientes
	;WITH
	CTE_XML
	AS
	(
		SELECT 
			CODIGO = T.Item.value('@CustomerID', 'varchar(4)'),
			NOMBRE = T.Item.value('@CustomerName', 'varchar(1000)'),
			DIRECCION = T.Item.value('(Address)[1]', 'varchar(2000)')
		FROM @XML.nodes('/ROOT/Customers/Customer') AS T(Item)
	)
	MERGE 
		INTO CUSTOMER AS T
		USING CTE_XML AS S
		ON S.CODIGO = T.CODE

		WHEN NOT MATCHED
			THEN
				INSERT (CODE, NAME, ADDRESS)
				VALUES (S.CODIGO, S.NOMBRE, S.DIRECCION)
	;
	
	--Leer e insertar Productos
	;WITH
	CTE_XML
	AS
	(
		SELECT DISTINCT 
			CODIGO = T.Item.value('@ProductID', 'int')
		FROM @XML.nodes('/ROOT/Customers/Customer/Orders/Order/OrderDetail') AS T(Item)
	)
	MERGE 
		INTO PRODUCT AS T
		USING CTE_XML AS S
		ON S.CODIGO = T.ID

		WHEN NOT MATCHED
			THEN
				INSERT (ID, NAME)
				VALUES (S.CODIGO, 'PRODUCT ' + CONVERT(VARCHAR, S.CODIGO))
	;

	--Leer e insertar cabecera de orden
	;WITH
	CTE
	AS
	(
		SELECT 
			CODIGO = T.Item.value('@OrderID', 'int'),
			FECHA = T.Item.value('@OrderDate', 'date'),
			IDCLIENTE = T.Item.value('../../@CustomerID','varchar(4)')
		FROM @XML.nodes('/ROOT/Customers/Customer/Orders/Order') AS T(Item)
	)
	INSERT INTO [ORDER] (CODE, DATE, ID_CUSTOMER)
	SELECT T.CODIGO, T.FECHA, C.ID
	FROM CTE T
		INNER JOIN CUSTOMER C ON T.IDCLIENTE = C.CODE

	--Leer e insertar detalles de orden
	;WITH
	CTE
	AS
	(
		SELECT 
			CODIGO_ORDEN = T.Item.value('../@OrderID','int'),
			CANTIDAD = T.Item.value('@Quantity','decimal(18, 2)'),
			CODIGO_PRODUCTO = T.Item.value('@ProductID','int')
		FROM @XML.nodes('/ROOT/Customers/Customer/Orders/Order/OrderDetail') AS T(Item)
	)
	INSERT INTO ORDER_DETAIL (ID_ORDER, ID, QUANTITY, ID_PRODUCT)
	SELECT O.ID, --T.CODIGO_ORDEN,
		ROW_NUMBER() OVER (PARTITION BY T.CODIGO_ORDEN ORDER BY T.CODIGO_PRODUCTO) AS CODIGO_DETALLE,
		T.CANTIDAD,
		T.CODIGO_PRODUCTO
	FROM CTE T
		INNER JOIN [ORDER] O ON O.CODE = T.CODIGO_ORDEN 
END
GO

DECLARE @XML XML
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla

EXEC uP_Insertar_Ordenes @XML

SELECT * FROM PRODUCT
SELECT * FROM CUSTOMER
SELECT * FROM [ORDER]
SELECT * FROM ORDER_DETAIL

-- TRANSACCIONES

CREATE PROC uP_Insertar_Orden
	@XML XML	
AS
BEGIN
	--Leer e insertar cabecera de orden
	;WITH
	CTE
	AS
	(
		SELECT 
			CODIGO = T.Item.value('@OrderID', 'int'),
			FECHA = T.Item.value('@OrderDate', 'date'),
			IDCLIENTE = T.Item.value('../../@CustomerID','varchar(4)')
		FROM @XML.nodes('/ROOT/Customers/Customer/Orders/Order') AS T(Item)
	)
	INSERT INTO [ORDER] (CODE, DATE, ID_CUSTOMER)
	SELECT T.CODIGO, T.FECHA, C.ID
	FROM CTE T
		INNER JOIN CUSTOMER C ON T.IDCLIENTE = C.CODE

	--Leer e insertar detalles de orden
	;WITH
	CTE
	AS
	(
		SELECT 
			CODIGO_ORDEN = T.Item.value('../@OrderID','int'),
			CANTIDAD = T.Item.value('@Quantity','decimal(18, 2)'),
			CODIGO_PRODUCTO = T.Item.value('@ProductID','int')
		FROM @XML.nodes('/ROOT/Customers/Customer/Orders/Order/OrderDetail') AS T(Item)
	)
	INSERT INTO ORDER_DETAIL (ID_ORDER, ID, QUANTITY, ID_PRODUCT)
	SELECT O.ID, --T.CODIGO_ORDEN,
		ROW_NUMBER() OVER (PARTITION BY T.CODIGO_ORDEN ORDER BY T.CODIGO_PRODUCTO) AS CODIGO_DETALLE,
		T.CANTIDAD,
		T.CODIGO_PRODUCTO
	FROM CTE T
		INNER JOIN [ORDER] O ON O.CODE = T.CODIGO_ORDEN 
END
GO

DELETE ORDER_DETAIL
DELETE [ORDER]

SELECT * FROM [ORDER]
SELECT * FROM ORDER_DETAIL

DECLARE @XML XML
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\OrdersBad.xml', SINGLE_CLOB) MiTabla

EXEC uP_Insertar_Orden @XML

SELECT * FROM [ORDER]
SELECT * FROM ORDER_DETAIL

-- 1: TRANSACCIONES con @@ERROR

-- 2: TRANSACCIONES con TRY CATCH

-- 3: TRANSACCIONES con SET XACT_ABORT ON