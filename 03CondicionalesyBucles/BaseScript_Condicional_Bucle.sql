CREATE TABLE CALENDARIO (ID INT PRIMARY KEY, FECHA DATE)
GO

------------------ CONDICIONALES

-- 1: Simple CASE expression:
CASE input_expression
     WHEN when_expression THEN result_expression 
	 [ ...n ]
     [ ELSE else_result_expression ]
END

-- Practica 1: 
-- Extraer el mes de la fecha, evaluarla y mostrar en una columna adicional el nombre del mes

-- 2: Searched CASE expression:
CASE
     WHEN Boolean_expression THEN result_expression 
	 [ ...n ]
     [ ELSE else_result_expression ]
END

-- Practica 2: 
-- Evaluar los meses en que se realizan pago se gratificaciones y mostrar en una columna adicional el texto "Pago de Grati"


-- 3: IF...ELSE

IF Boolean_expression   
     { sql_statement | statement_block }   
[ ELSE   
     { sql_statement | statement_block } ] 

-- Practica 3:
-- Extraer el primer registro del mes abril, recuperar el dia en una variable y dependiendo del valor imprimir el texto "1ra Quincena" si el valor esta en la primera quincena, 
-- caso contrario imprimir '2da Quincena'


-- 4: IIF Function
IIF( boolean_expression, true_value, false_value )

-- Practica 4:
-- Evaluar el dia de los registros de la tabla calendario, si el valor esta en la primera quincena mostrar columna con valor "1ra Quincena", caso contrario "2da Quincena"


-- 5: CHOOSE Function
CHOOSE ( index, val_1, val_2 [, val_n ] )

-- Practica 5: (Calificada)


------------------ BUCLES

-- 1. WHILE 
WHILE Boolean_expression   
     { sql_statement | statement_block | BREAK | CONTINUE }

-- Práctica 1 
-- Poblar la tabla Calendario con las fechas del mes de Abril 2023


