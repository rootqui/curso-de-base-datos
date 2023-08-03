CREATE TABLE CALENDARIO (ID INT PRIMARY KEY, FECHA DATE)
GO

SELECT * FROM CALENDARIO

------------------ CONDICIONALES

-- 1: Simple CASE expression:
CASE input_expression
     WHEN when_expression THEN result_expression 
	 [ ...n ]
     [ ELSE else_result_expression ]
END

-- Practica 1: 
-- Extraer el mes de la fecha, evaluarla y mostrar en una columna adicional el nombre del mes

SELECT ID, FECHA, 
	CASE MONTH(FECHA)
		WHEN 1 THEN 'Enero'
		WHEN 2 THEN 'Febrero'
		ELSE '???'
	END AS Nombre_Mes
FROM CALENDARIO 

-- 2: Searched CASE expression:
CASE
     WHEN Boolean_expression THEN result_expression 
	 [ ...n ]
     [ ELSE else_result_expression ]
END

SELECT ID, FECHA,
	CASE 
		WHEN MONTH(FECHA) = 1 THEN 'ENERO'
		WHEN MONTH(FECHA) = 2 THEN 'FEBRERO'
		ELSE '???'
	END
FROM CALENDARIO

-- Practica 2: 
-- Evaluar los meses en que se realizan pago se gratificaciones y mostrar en una columna adicional el texto "Pago de Grati"

INSERT INTO CALENDARIO VALUES (50, '20230701')

SELECT ID, FECHA,
	CASE 
		WHEN MONTH(FECHA) = 7 OR MONTH(FECHA) = 12 THEN 'Pago de Gratificación'
		ELSE ''
	END
FROM CALENDARIO

SELECT ID, FECHA,
	CASE 
		WHEN MONTH(FECHA) IN (7, 12) THEN 'Pago de Gratificación'
		ELSE ''
	END
FROM CALENDARIO
	
-- 3: IF...ELSE

IF Boolean_expression   
     { sql_statement | statement_block }   
[ ELSE   
     { sql_statement | statement_block } ] 

-- Practica 3:
-- Extraer el primer registro del mes abril, recuperar el dia en una variable y dependiendo del valor imprimir el texto "1ra Quincena" si el valor esta en la primera quincena, 
-- caso contrario imprimir '2da Quincena'

INSERT INTO CALENDARIO VALUES (51, '20230401')
INSERT INTO CALENDARIO VALUES (52, '20230415')
INSERT INTO CALENDARIO VALUES (53, '20230430')

DECLARE @DIA TINYINT

SELECT TOP 1 @DIA = DAY(FECHA) FROM CALENDARIO 
WHERE MONTH(FECHA) = 4
ORDER BY FECHA ASC

IF @DIA BETWEEN 1 AND 15
	SELECT '1ra Quincena'
ELSE
	SELECT '2da Quincena'

-- Declarar una variable que permita definir el mes de analisis
-- si el valor de la variable encuentra registros en la tabla calendario, consultar todos los registros de ese mes, 
-- de lo contrario consultar los registros de toda la tabla

DECLARE @MES TINYINT = 4

IF EXISTS(SELECT 1 FROM CALENDARIO WHERE MONTH(FECHA) = @MES)
BEGIN
	SELECT * FROM CALENDARIO WHERE MONTH(FECHA) = @MES
	SELECT GETDATE()
END
ELSE
BEGIN
	SELECT * FROM CALENDARIO 
	SELECT @@ROWCOUNT 
END

--SELECT *, MONTH(FECHA) 
--FROM CALENDARIO
--WHERE MONTH(FECHA) = @MES

-- 4: IIF Function
IIF( boolean_expression, true_value, false_value )

-- Practica 4:
-- Evaluar el dia de los registros de la tabla calendario, si el valor esta en la primera quincena mostrar columna con valor "1ra Quincena", 
-- caso contrario "2da Quincena"

SELECT ID, FECHA,
	IIF(DAY(FECHA) <= 15, '1RA QUINCENA', '2DA QUINCENA') AS QUINCENA
FROM CALENDARIO

-- 5: CHOOSE Function
CHOOSE ( index, val_1, val_2 [, val_n ] )

-- Practica 5: (Calificada)


------------------ BUCLES

-- 1. WHILE 
WHILE Boolean_expression   
     { sql_statement | statement_block | BREAK | CONTINUE }

-- Práctica 1 
-- Poblar la tabla Calendario con las fechas del mes de Abril 2023

DECLARE @DIA_INICIAL TINYINT = 1, @DIA_FINAL TINYINT = 30,
	@ID INT, @FECHA DATE

WHILE @DIA_INICIAL <= @DIA_FINAL
BEGIN
	
	SELECT @ID = (SELECT MAX(ID) + 1 FROM CALENDARIO)
	SELECT @FECHA = '202304' + RIGHT('00' + CONVERT(VARCHAR, @DIA_INICIAL), 2)

	INSERT INTO CALENDARIO VALUES (@ID, @FECHA)
	SET @DIA_INICIAL = @DIA_INICIAL + 1
END

SELECT * FROM CALENDARIO

