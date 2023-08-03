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


-- Importar XML

--- OPENROWSET

-- OPENXML

-- Lectura XML

---- XML.Query

---- XML.Value

-- Exportar como XML
select * from calendario for xml auto

select * from calendario for xml raw
select * from calendario for xml path
select * from calendario for xml explicit --(PRACTICA CALIFICADA)

