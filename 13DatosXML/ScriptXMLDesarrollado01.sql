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

-- Exportar como XML
select * from calendario for xml auto

select * from calendario for xml raw
select * from calendario for xml path
select * from calendario for xml explicit --(PRACTICA CALIFICADA)

