CREATE TABLE TIPO_CAMBIO (ID INT IDENTITY NOT NULL PRIMARY KEY, FECHA DATE NOT NULL, COMPRA MONEY NOT NULL, VENTA MONEY NOT NULL)
GO

INSERT INTO TIPO_CAMBIO VALUES ('20230510', 3.67, 3.678)

CREATE TABLE CABECERA_VENTA (ID INT IDENTITY NOT NULL PRIMARY KEY, FECHA DATE NOT NULL, SERIE VARCHAR(4) NOT NULL, NUMERO VARCHAR(10) NOT NULL, MONTO_SOLES MONEY NOT NULL, MONTO_DOLARES MONEY NOT NULL)
GO

INSERT INTO CABECERA_VENTA VALUES ('20230510', 'F001', '1597', 1000, 1000/3.678)
INSERT INTO CABECERA_VENTA VALUES ('20230511', 'F001', '1598', 2000, 0)

SELECT * FROM TIPO_CAMBIO
SELECT * FROM CABECERA_VENTA 

UPDATE CABECERA_VENTA SET FECHA = '20230501'

SELECT * FROM TIPO_CAMBIO
SELECT * FROM CABECERA_VENTA 

UPDATE CABECERA_VENTA SET FECHA = '20230510'

-- TRIGGER DML AFTER
CREATE TRIGGER <NOMBRE>
	ON <tabla>
	AFTER <instrucciones DML>
AS 
BEGIN
	SET NOCOUNT ON;

END
GO

-- 1. Implementar triger dml after, que nos muestre las tablas INSERTED y DELETED

CREATE TRIGGER uTR_VisualizarDeletedInserted
	ON TIPO_CAMBIO
	AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	SELECT * FROM INSERTED
	SELECT * FROM DELETED
END
GO

INSERT INTO TIPO_CAMBIO VALUES ('20230509', 3.65, 3.658)
UPDATE TIPO_CAMBIO SET VENTA = VENTA + 0.001
DELETE TIPO_CAMBIO WHERE ID = 2

INSERT: INSERTED tiene reg, DELETED no tiene reg
UPDATE: 
	INSERTED tiene reg, despues de los cambios
	DELETED tiene reg, antes de los cambios
DELETE: INSERTED no tiene reg, DELETED tiene reg

-- 2. Ejecutar procesos de RollBack, cancelar operaciones (DML)

CREATE TRIGGER uTR_CABECERA_VENTA_ValidarTipoCambio
	ON CABECERA_VENTA
	AFTER INSERT, UPDATE 
AS 
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT 1 
			FROM INSERTED V
			WHERE FECHA NOT IN (SELECT FECHA FROM TIPO_CAMBIO))
	BEGIN
		ROLLBACK; --DESCARTA LOS CAMBIOS
	END

END
GO

UPDATE CABECERA_VENTA SET FECHA = '20230501'

SELECT * 
FROM CABECERA_VENTA V
WHERE FECHA NOT IN (SELECT FECHA FROM TIPO_CAMBIO)	

SELECT * FROM CABECERA_VENTA
SELECT * FROM TIPO_CAMBIO

UPDATE CABECERA_VENTA SET FECHA = '20230501'
INSERT INTO CABECERA_VENTA VALUES ('20231231', 'F001', '9999', 5000, 0)

-- 3. Implementar trigger dml afTER, para calcular monto en dolares en tabla CABECERA_VENTA

ALTER TRIGGER uTR_CABECERA_VENTA_Calcular_Monto_Dolares
	ON CABECERA_VENTA
	AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;
	UPDATE V SET MONTO_DOLARES = V.MONTO_SOLES / (SELECT VENTA FROM TIPO_CAMBIO WHERE FECHA = V.FECHA)
	FROM CABECERA_VENTA V
		INNER JOIN INSERTED I ON V.ID = I.ID
END
GO

SELECT *, MONTO_SOLES / (SELECT VENTA FROM TIPO_CAMBIO WHERE FECHA = V.FECHA)
--UPDATE V SET MONTO_DOLARES = MONTO_SOLES / (SELECT VENTA FROM TIPO_CAMBIO WHERE FECHA = V.FECHA)
FROM CABECERA_VENTA V
	




SELECT * FROM CABECERA_VENTA
SELECT * FROM TIPO_CAMBIO
UPDATE CABECERA_VENTA SET FECHA = '20230510' WHERE ID = 1

-- 4.Implementar trigger dml afTER, para calcular monto en dolares en tabla CABECERA_VENTA, cuando modifico el importe en soles o fecha