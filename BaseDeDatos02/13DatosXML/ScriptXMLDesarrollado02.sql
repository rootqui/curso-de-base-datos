DECLARE @STRING VARCHAR(MAX) = 
'
<ROOT>
	<Customers>
		<Customer CustomerName="Arshad Ali" CustomerID="C001">
			<Orders>
				<Order OrderDate="2012-07-04T00:00:00" OrderID="10248">
					<OrderDetail Quantity="5" ProductID="10"/>
					<OrderDetail Quantity="12" ProductID="11"/>
					<OrderDetail Quantity="10" ProductID="42"/>
				</Order>
			</Orders>
			<Address>Address line 1,2,3</Address>
		</Customer>
		<Customer CustomerName="Paul Henriot" CustomerID="C002">
			<Orders>
				<Order OrderDate="2011-07-04T00:00:00" OrderID="10245">
					<OrderDetail Quantity="12" ProductID="11"/>
					<OrderDetail Quantity="10" ProductID="42"/>
				</Order>
			</Orders>
			<Address>Address line 5,6,7</Address>
		</Customer>
		<Customer CustomerName="Carlos Gonzales" CustomerID="C003">
			<Orders>
				<Order OrderDate="2012-08-16T00:00:00" OrderID="10283">
					<OrderDetail Quantity="3" ProductID="72"/>
				</Order>
			</Orders>
			<Address>Address line 1,4,5</Address>
		</Customer>
	</Customers>
</ROOT
'
SELECT @STRING 


DECLARE @XML XML = 
'
<ROOT>
	<Customers>
		<Customer CustomerName="Arshad Ali" CustomerID="C001">
			<Orders>
				<Order OrderDate="2012-07-04T00:00:00" OrderID="10248">
					<OrderDetail Quantity="5" ProductID="10"/>
					<OrderDetail Quantity="12" ProductID="11"/>
					<OrderDetail Quantity="10" ProductID="42"/>
				</Order>
			</Orders>
			<Address>Address line 1,2,3</Address>
		</Customer>
		<Customer CustomerName="Paul Henriot" CustomerID="C002">
			<Orders>
				<Order OrderDate="2011-07-04T00:00:00" OrderID="10245">
					<OrderDetail Quantity="12" ProductID="11"/>
					<OrderDetail Quantity="10" ProductID="42"/>
				</Order>
			</Orders>
			<Address>Address line 5,6,7</Address>
		</Customer>
		<Customer CustomerName="Carlos Gonzales" CustomerID="C003">
			<Orders>
				<Order OrderDate="2012-08-16T00:00:00" OrderID="10283">
					<OrderDetail Quantity="3" ProductID="72"/>
				</Order>
			</Orders>
			<Address>Address line 1,4,5</Address>
		</Customer>
	</Customers>
</ROOT>
'
SELECT @XML


-- Importar XML

---- OPENROWSET 
DECLARE @XML XML

--SELECT BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla
SELECT @XML

---- OPENXML (Trabajo Practico)

-- Lectura XML
---- XML.Query
DECLARE @XML XML
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla

SELECT @XML.query('data(/ROOT/Customers/Customer/@CustomerName)') --Leer valores de un atributo de etiqueta
SELECT @XML.query('data(/ROOT/Customers/Customer/@CustomerID)')

SELECT @XML.query('data(/ROOT/Customers/Customer/Address)') -- Leer valores de un atributo

---- XML.Value
--1. Leer datos de los clientes
DECLARE @XML XML
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla

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

SELECT * FROM CUSTOMER

--2. Leer datos de los productos
DECLARE @XML XML
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla

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

SELECT * FROM PRODUCT

--3. Leer datos de ordenes y poblar tabla Order
DECLARE @XML XML
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla

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

--4. Leer datos de detalles de ordenes y poblar tabla Order_Detail
DECLARE @XML XML
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla

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


--5. Implementar SP para leer contenido de un archivo XML y poblar las tablas correspondientes

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

delete order_detail
delete [order]
delete product
delete customer

DECLARE @XML XML
SELECT @XML = BulkColumn FROM OPENROWSET(BULK 'D:\Temp\Orders.xml', SINGLE_CLOB) MiTabla

EXEC uP_Insertar_Ordenes @XML

SELECT * FROM PRODUCT
SELECT * FROM CUSTOMER
SELECT * FROM [ORDER]
SELECT * FROM ORDER_DETAIL

-- Exportar como XML
SELECT * FROM PRODUCT FOR XML AUTO
SELECT * FROM PRODUCT FOR XML RAW
SELECT * FROM PRODUCT FOR XML PATH 
SELECT * FROM PRODUCT FOR XML EXPLICIT --(PRACTICA CALIFICADA)

