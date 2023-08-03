-- CONEXION A
/*
Type
	RID = Bloqueo en una única fila de una tabla identificada por un identificador de fila (RID).
	KEY = Bloqueo en un índice que protege un intervalo de claves en transacciones serializables.
	PAG = Bloqueo en una página de datos o de índices.
	EXT = Bloqueo en una extensión.
	TAB = Bloqueo en toda una tabla, incluidos todos los datos y los índices.
	DB = Bloqueo en una base de datos.
	FIL = Bloqueo en un archivo de base de datos.
	APP = Bloqueo en un recurso especificado por la aplicación.
	MD = Bloqueos de metadatos o información de catálogo.
	HBT = Bloqueo en un montón o árbol B (HoBT). Esta información está incompleta en SQL Server.
	AU = Bloqueo en una unidad de asignación. Esta información está incompleta en SQL Server.
Mode
	NULL = No se concede acceso al recurso. Sirve como marcador de posición.
	Sch-S = Estabilidad del esquema. Garantiza que un elemento de un esquema, como una tabla o un índice, no se quite mientras una sesión mantenga un bloqueo de estabilidad del esquema sobre él.
	Sch-M = Modificación del esquema. Debe mantenerlo cualquier sesión que desee cambiar el esquema del recurso especificado. Garantiza que ninguna otra sesión se refiera al objeto indicado.
	S = Compartido. La sesión que lo mantiene recibe acceso compartido al recurso.
	U = Actualizar. Indica que se ha obtenido un bloqueo de actualización sobre recursos que finalmente se pueden actualizar. Se utiliza para evitar una forma común de interbloqueo que tiene lugar cuando varias sesiones bloquean recursos para una posible actualización más adelante.
	X = Exclusivo. La sesión que lo mantiene recibe acceso exclusivo al recurso.
	IS = Intención compartida. Indica la intención de establecer bloqueos S en algún recurso subordinado de la jerarquía de bloqueos.
	IU = Actualizar intención. Indica la intención de establecer bloqueos U en algún recurso subordinado de la jerarquía de bloqueos.
	IX = Intención exclusiva. Indica la intención de colocar bloqueos X en algunos recursos subordinados en la jerarquía de bloqueos.
	SIU = Actualizar intención compartida. Indica el acceso compartido a un recurso con la intención de obtener bloqueos de actualización sobre recursos subordinados en la jerarquía de bloqueos.
	SIX = Intención compartida exclusiva. Indica acceso compartido a un recurso con la intención de obtener bloqueos exclusivos sobre recursos subordinados de la jerarquía de bloqueos.
	UIX = Actualizar intención exclusiva. Indica un bloqueo de actualización en un recurso con la intención de adquirir bloqueos exclusivos sobre recursos subordinados en la jerarquía de bloqueos.
	BU = Actualización masiva. Utilizado en las operaciones masivas.
	RangeS_S = Intervalo de claves compartido y bloqueo de recurso compartido. Indica recorrido de intervalo serializable.
	RangeS_U = Intervalo de claves compartido y bloqueo de recurso de actualización. Indica recorrido de actualización serializable.
	RangeI_N = Insertar intervalo de claves y bloqueo de recurso Null. Se utiliza para probar los intervalos antes de insertar una clave nueva en un índice.
	RangeI_S = Bloqueo de conversión de intervalo de claves. Creado por una superposición de bloqueos RangeI_N y S.
	RangeI_U = Bloqueo de conversión de intervalo de claves creado por una superposición de bloqueos RangeI_N y U.
	RangeI_X = Bloqueo de conversión de intervalo de claves creado por una superposición de bloqueos RangeI_N y X.
	RangeX_S = Bloqueo de conversión de rango de claves creado por una superposición de bloqueos RangeI_N y RangeS_S Cerraduras.
	RangeX_U = Bloqueo de conversión de intervalo de claves creado por una superposición de bloqueos RangeI_N y RangeS_U.
	RangeX_X = Intervalo de claves exclusivo y bloqueo de recurso exclusivo. Es un bloqueo de conversión que se utiliza cuando se actualiza una clave de un intervalo.	
*/
EXEC SP_LOCK

-- TEST 1 - BLOQUEOS
SELECT * FROM PRODUCT 

BEGIN TRANSACTION A
	SELECT * FROM PRODUCT
	--10	PRODUCTO 10
	--11	PRODUCTO 11
	--42	PRODUCTO 42
	--72	PRODUCTO 72
	INSERT INTO PRODUCT VALUES (100, 'PRODUCTO 100')
	SELECT * FROM PRODUCT
	--10	PRODUCTO 10
	--11	PRODUCTO 11
	--42	PRODUCTO 42
	--72	PRODUCTO 72
	--100	PRODUCTO 100

ROLLBACK TRANSACTION A

SELECT @@TRANCOUNT

--TEST 2 - ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRANSACTION A
	SELECT * FROM PRODUCT
	DELETE PRODUCT WHERE ID = 101
	SELECT * FROM PRODUCT
ROLLBACK TRANSACTION A
SELECT * FROM PRODUCT

BEGIN TRANSACTION B
	SELECT * FROM ORDER_DETAIL 
	UPDATE ORDER_DETAIL SET QUANTITY = 50 WHERE ID_ORDER = 1 AND ID = 1
	SELECT * FROM ORDER_DETAIL WHERE ID_ORDER = 1 AND ID = 1
ROLLBACK TRANSACTION B

-- TEST 3 - ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
	SELECT * FROM PRODUCT WHERE ID = 10

ROLLBACK TRANSACTION
	
SET TRANSACTION ISOLATION LEVEL 
REPEATABLE READ

BEGIN TRANSACTION
	SELECT * FROM PRODUCT WHERE ID = 10
ROLLBACK TRANSACTION


-- TEST 4 - ISOLATION LEVEL SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL 
SERIALIZABLE

SELECT * FROM PRODUCT ORDER BY ID

BEGIN TRANSACTION
	SELECT * FROM PRODUCT WHERE ID < 20

ROLLBACK TRANSACTION

-- TEST 5 - ISOLATION LEVEL SNAPSHOT
SET TRANSACTION ISOLATION LEVEL 
READ COMMITTED

BEGIN TRANSACTION
	SELECT * FROM PRODUCT WHERE ID = 10
	UPDATE PRODUCT SET NAME = NAME + ' UPDATE' WHERE ID = 10
	SELECT * FROM PRODUCT WHERE ID = 10
COMMIT TRANSACTION
ROLLBACK TRANSACTION

SELECT * FROM PRODUCT WHERE ID = 10

-------
BEGIN TRANSACTION
	SELECT * FROM PRODUCT WHERE ID = 10
	UPDATE PRODUCT SET NAME = NAME + ' UPDATE' WHERE ID = 10
	SELECT * FROM PRODUCT WHERE ID = 10
COMMIT TRANSACTION

SELECT * FROM PRODUCT WHERE ID = 10