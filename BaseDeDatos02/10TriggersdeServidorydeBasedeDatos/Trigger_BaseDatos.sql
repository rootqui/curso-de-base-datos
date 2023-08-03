select * from sys.trigger_event_types

-- consulta a vista de eventos

;WITH
CTE
AS
(
	Select *, 0 AS TAB, 
		CONVERT(VARCHAR(MAX), ROW_NUMBER() OVER (ORDER BY TYPE)) AS ORDEN
	From Sys.trigger_event_types
	where parent_type is null
	UNION ALL 
	SELECT T.*, C.TAB + 1, 
		 C.ORDEN + '.' + CONVERT(VARCHAR(MAX), ROW_NUMBER() OVER (PARTITION BY T.PARENT_TYPE ORDER BY C.TYPE)) AS ORDEN
	FROM CTE C
		INNER JOIN Sys.trigger_event_types T ON T.PARENT_TYPE = C.TYPE
)
SELECT TYPE, PARENT_TYPE,REPLICATE(' ', TAB * 8) + TYPE_NAME
FROM CTE
ORDER BY ORDEN


CREATE TRIGGER <NOMBRE>
	ON DATABASE
	FOR <EVENTOS>
AS
BEGIN
	--IF IS_MEMBER ('db_owner') = 0
	--BEGIN
	--   PRINT 'You must ask your DBA to drop or alter tables!' 
	--   ROLLBACK TRANSACTION
	--END
END

CREATE TRIGGER uTR_BaseDatos
	ON DATABASE
	FOR DDL_DATABASE_LEVEL_EVENTS
AS
BEGIN
	SELECT 'interceptando eventos DDL'

	--IF IS_MEMBER ('db_owner') = 0
	--BEGIN
	--   PRINT 'You must ask your DBA to drop or alter tables!' 
	--   ROLLBACK TRANSACTION
	--END
END

create proc uP_FechaSistema
as
begin
	SELECT GETDATE()
end

DROP FUNCTION uFN_FechaSistema
(
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @GETDATE DATETIME = GETDATE()
	RETURN @GETDATE
END
GO

CREATE VIEW uV_FechaSistemas
AS
SELECT GETDATE() AS GETDATE
GO

-- 1. Implementa un trigger que evite la eliminacion de procedimientos almacenados

ALTER TRIGGER uTR_Cancela_Eliminacion
	ON DATABASE
	FOR DROP_PROCEDURE
AS
BEGIN
	IF IS_MEMBER ('db_owner') = 0
	BEGIN
	   PRINT 'You must ask your DBA to drop or alter tables!' 
	   ROLLBACK TRANSACTION
	END
END


-- 2. Implementa un trigger que evite la creacion y actualizacion de funciones

SELECT IS_MEMBER ('db_owner')




-- 3. Implementar Trigger para visualizar contenido de EvenData()

CREATE TRIGGER uTR_Lectura_EvenData
	ON DATABASE
	FOR DDL_TABLE_EVENTS -- (CREATE TABLE, DROP TABLE, ALTER TABLE)
AS
BEGIN
	SELECT EVENTDATA()
END
GO

CREATE TABLE uP_Test (ID INT PRIMARY KEY)
GO


ALTER TRIGGER uTR_Historial_EvenData
	ON DATABASE
	FOR DDL_PROCEDURE_EVENTS, DDL_FUNCTION_EVENTS, DDL_TRIGGER_EVENTS, DDL_VIEW_EVENTS --DDL_DATABASE_LEVEL_EVENTS 
AS
BEGIN
	DECLARE @evendata XML = EVENTDATA()

	INSERT INTO uU_HistorialEvenData
		(EventType, PostTime, ServerName, LoginName, UserName, ObjectName, ObjectType, TSQLCommand_CommandText)
	SELECT 
		@evendata.value('(/EVENT_INSTANCE/EventType)[1],','varchar(max)'),
		@evendata.value('(/EVENT_INSTANCE/PostTime)[1],','datetime'),
		@evendata.value('(/EVENT_INSTANCE/ServerName)[1],','varchar(max)'),
		@evendata.value('(/EVENT_INSTANCE/LoginName)[1],','varchar(max)'),
		@evendata.value('(/EVENT_INSTANCE/UserName)[1],','varchar(max)'),
		@evendata.value('(/EVENT_INSTANCE/ObjectName)[1],','varchar(max)'),
		@evendata.value('(/EVENT_INSTANCE/ObjectType)[1],','varchar(max)'),
		@evendata.value('(/EVENT_INSTANCE/TSQLCommand/CommandText)[1],','varchar(max)')
END
GO

CREATE TABLE uU_HistorialEvenData (ID INT PRIMARY KEY IDENTITY, EventType VARCHAR(1000), PostTime DATETIME, ServerName VARCHAR(1000), LoginName VARCHAR(100), UserName VARCHAR(1000), ObjectName VARCHAR(100), ObjectType VARCHAR(1000), 
	TSQLCommand_CommandText VARCHAR(MAX) )


ALTER view uV_FechaSistema
as
select getdate() as FechaSistema
go

SELECT * FROM uU_HistorialEvenData

DROP view uV_FechaSistema



SELECT * FROM uU_HistorialEvenData
WHERE OBJECTNAME = 'uV_FechaSistema'