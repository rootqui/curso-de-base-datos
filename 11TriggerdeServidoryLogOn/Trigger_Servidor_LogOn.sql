-- Trigger de Servidor
CREATE TRIGGER <nombre>
	ON ALL SERVER
	AFTER <EVENTOS>
AS
BEGIN
	<INSTRUCCIONES>
END

--1. Implementar Trigger para cancelar la gestion de base de datos si no tiene el rol sysadmin
alter TRIGGER uTR_Servidor
	ON ALL SERVER
	AFTER DDL_DATABASE_EVENTS
AS
BEGIN
	IF IS_SRVROLEMEMBER('sysadmin') = 0
		ROLLBACK;
END

select IS_SRVROLEMEMBER('sysadmin') 


-- Trigger LogOn