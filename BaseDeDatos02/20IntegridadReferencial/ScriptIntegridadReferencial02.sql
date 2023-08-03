ALTER TABLE SALES.SALESORDERDETAIL ADD LineTotal2 MONEY 
GO

UPDATE SALES.SALESORDERDETAIL SET LineTotal2 = (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0)))
GO

BEGIN TRAN
	UPDATE SALES.SALESORDERDETAIL SET LineTotal2 = 0
ROLLBACK TRAN 

CREATE TRIGGER uTR_SALESORDERDETAIL_LineTotal2
	ON SALES.SALESORDERDETAIL
	AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON 
	IF UPDATE(LineTotal2)
	BEGIN
		IF EXISTS(SELECT 1 FROM INSERTED WHERE LineTotal2 <> (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))))
		BEGIN
			ROLLBACK;
		END
	END
END

UPDATE SALES.SALESORDERDETAIL SET LineTotal2 = 0
-- The transaction ended in the trigger. The batch has been aborted.
SELECT LineTotal2, * FROM SALES.SALESORDERDETAIL

BEGIN TRAN
	UPDATE SALES.SALESORDERDETAIL SET UnitPriceDiscount = 1
	SELECT UnitPriceDiscount, LineTotal2, (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))), * 
	FROM SALES.SALESORDERDETAIL 
ROLLBACK TRAN


ALTER TRIGGER dbo.uTR_SALESORDERDETAIL_LineTotal2
	ON SALES.SALESORDERDETAIL
	AFTER INSERT, UPDATE
AS
BEGIN
	SET NOCOUNT ON 
	IF UPDATE(LineTotal2) OR UPDATE(UnitPriceDiscount) OR UPDATE(UnitPrice) OR UPDATE(OrderQty)
	BEGIN
		IF EXISTS(SELECT 1 FROM INSERTED WHERE LineTotal2 <> (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))))
		BEGIN
			ROLLBACK;
		END
	END
END
GO

BEGIN TRAN
	UPDATE SALES.SALESORDERDETAIL SET UnitPriceDiscount = 1
	SELECT UnitPriceDiscount, LineTotal2, (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))), * 
	FROM SALES.SALESORDERDETAIL 
ROLLBACK TRAN

-----------
BEGIN TRAN
	update SALES.SALESORDERHeader set SubTotal = 0
ROLLBACK TRAN
-- (31465 rows affected)

CREATE TRIGGER uTR_SalesOrderHeader_SubTotal
   ON  Sales.SalesOrderHeader
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	IF UPDATE(SubTotal)
	BEGIN
		IF EXISTS
		(
			SELECT 1
			FROM INSERTED I
				OUTER APPLY
				(
					SELECT SUM(LineTotal) AS LineTotal
					FROM Sales.SalesOrderDetail 
					WHERE SalesOrderID = I.SalesOrderID 
				) D
			WHERE I.SubTotal <> D.LineTotal 
		)
		BEGIN
			ROLLBACK;
		END
	END
END
GO

BEGIN TRAN
	update SALES.SALESORDERHeader set SubTotal = 0
ROLLBACK TRAN
-- The transaction ended in the trigger. The batch has been aborted.

BEGIN TRAN
	DELETE Sales.SalesOrderDetail WHERE SalesOrderID =  43659 AND SalesOrderDetailID = 12
	SELECT SubTotal FROM Sales.SalesOrderHeader WHERE SalesOrderID =  43659 
	SELECT sum(linetotal) FROM Sales.SalesOrderDetail WHERE SalesOrderID =  43659
ROLLBACK TRAN


CREATE TRIGGER uTR_SalesOrderDetail_Integridad
	ON Sales.SalesOrderDetail
	AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	UPDATE H
	SET SubTotal = coalesce(D.LineTotal, 0)
	FROM Sales.SalesOrderHeader H
		OUTER APPLY
		(
			SELECT SUM(LineTotal) AS LineTotal
			FROM Sales.SalesOrderDetail 
			WHERE SalesOrderID = H.SalesOrderID 
		) D
END
GO

BEGIN TRAN
	DELETE Sales.SalesOrderDetail WHERE SalesOrderID =  43659 AND SalesOrderDetailID = 12
	SELECT SubTotal FROM Sales.SalesOrderHeader WHERE SalesOrderID =  43659 
	SELECT sum(linetotal) FROM Sales.SalesOrderDetail WHERE SalesOrderID =  43659
ROLLBACK TRAN

