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
   select documento,nombre, domicilio,'cliente' from clientes;

go

-- Creamos un disparador sobre la vista "vista_empleados_clientes" para inserción,
-- que redirija las inserciones a la tabla correspondiente:



-- Ingresamos un empleado y un cliente en la vista:


-- Veamos si se almacenaron en la tabla correspondiente:
select * from empleados;
select * from clientes;

go

-- Creamos un disparador sobre la vista "vista_empleados_clientes" para el evento "update",
-- que redirija las actualizaciones a la tabla correspondiente:

-- Realizamos una actualización sobre la vista, de un empleado:

-- Veamos si se actualizó la tabla correspondiente:
select * from empleados;

-- Realizamos una actualización sobre la vista, de un cliente:

-- Veamos si se actualizó la tabla correspondiente:
select * from clientes;

