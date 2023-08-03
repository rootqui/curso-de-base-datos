-- Trigger Table InsteadOf (En vez de)
CREATE TRIGGER <NOMBRE>
	ON <TABLA>
	INSTEAD OF <DML>
AS
BEGIN
	SET NOCOUNT ON;

	<INSTRUCCIONES>
END

create table empleados(
  documento char(8) not null,
  nombre varchar(30),
  domicilio varchar(30),
  constraint PK_empleados primary key(documento)
);

create table clientes(
  documento char(8) not null,
  nombre varchar(30),
  domicilio varchar(30),
  constraint PK_clientes primary key(documento)
);

create view vista_empleados_clientes
as
  select documento,nombre, domicilio, 'empleado' as condicion from empleados
  union
  select documento,nombre, domicilio, 'cliente' from clientes;

go

INSERT INTO empleados VALUES ('12345678', 'Ar2ro', 'Casa de Ar2ro')
INSERT INTO clientes VALUES ('23456789', 'MArcAn', 'Casa de MarcAn')

SELECT * FROM vista_empleados_clientes

INSERT INTO vista_empleados_clientes VALUES ('87654321', 'Jose', 'Casa de Jose', 'empleado')

-- Creamos un disparador sobre la vista "vista_empleados_clientes" para inserción,
-- que redirija las inserciones a la tabla correspondiente:

CREATE TRIGGER uTR_vista_empleados_clientes_InsteadOf
	ON vista_empleados_clientes
	INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO empleados 
		(documento, nombre, domicilio)
	SELECT documento, nombre, domicilio 
	FROM INSERTED
	WHERE condicion = 'empleado'

	INSERT INTO clientes
		(documento, nombre, domicilio)
	SELECT documento, nombre, domicilio 
	FROM INSERTED
	WHERE condicion = 'cliente'

END

INSERT INTO vista_empleados_clientes VALUES ('87654321', 'Jose', 'Casa de Jose', 'empleado')

SELECT * FROM empleados 
SELECT * FROM CLIENTES

INSERT INTO vista_empleados_clientes VALUES ('87654321', 'Jose', 'Casa de Jose', 'empleado')

-- Ingresamos un empleado y un cliente en la vista:


-- Veamos si se almacenaron en la tabla correspondiente:
select * from empleados;
select * from clientes;

go

-- Creamos un disparador sobre la vista "vista_empleados_clientes" para el evento "update",
-- que redirija las actualizaciones a la tabla correspondiente:

select * from empleados;
UPDATE vista_empleados_clientes SET domicilio = domicilio + ' UPDATE' WHERE DOCUMENTO = '12345678'

ALTER TRIGGER uTR_vista_empleados_clientes_InsteadOf_Update
	ON vista_empleados_clientes
	INSTEAD OF UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT * 
	IF UPDATE(documento)
	BEGIN
		RAISERROR('No se pueden actualizar columnas de clave primaria', 16, 1)
		--SELECT 'No se pueden actualizar columnas de clave primaria'
		--RETURN
	END

	IF UPDATE(domicilio) OR UPDATE(nombre) 
	BEGIN
		UPDATE E 
		SET domicilio = I.domicilio,
			nombre = I.nombre
		FROM INSERTED I
			INNER JOIN empleados E ON I.documento = E.documento
		WHERE I.condicion = 'empleado' 

		UPDATE E 
		SET domicilio = I.domicilio,
			nombre = I.nombre
		FROM INSERTED I
			INNER JOIN clientes E ON I.documento = E.documento
		WHERE I.condicion = 'cliente' 
	END
	--SELECT * FROM DELETED
END
GO

UPDATE vista_empleados_clientes SET domicilio = domicilio + ' UPDATE' WHERE DOCUMENTO = '12345678'
UPDATE vista_empleados_clientes SET nombre = nombre + ' UPDATE' WHERE DOCUMENTO = '23456789'

select * from empleados;
select * from clientes;

-- Realizamos una actualización sobre la vista, de un empleado:

-- Veamos si se actualizó la tabla correspondiente:
select * from empleados;

-- Realizamos una actualización sobre la vista, de un cliente:

-- Veamos si se actualizó la tabla correspondiente:
select * from clientes;

UPDATE vista_empleados_clientes SET DOCUMENTO = '01234567' WHERE DOCUMENTO = '12345678'

select * from empleados;
select * from clientes;

