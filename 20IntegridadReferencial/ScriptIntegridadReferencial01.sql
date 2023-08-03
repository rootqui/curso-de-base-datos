ALTER TABLE SALES.SalesOrderDetail DROP COLUMN LineTotal
GO

ALTER TABLE SALES.SalesOrderDetail ADD LineTotal MONEY
GO

UPDATE SALES.SalesOrderDetail SET LineTotal = (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0)))

UPDATE SALES.SalesOrderDetail SET LineTotal = 0

ALTER TABLE SALES.SalesOrderDetail ADD CONSTRAINT CK_SalesOrderDetail_LineTotal CHECK (LineTotal = ROUND(isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0)), 4))

SELECT LineTotal, isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0)) FROM SALES.SalesOrderDetail 
WHERE LineTotal <> isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))

UPDATE SALES.SalesOrderDetail SET OrderQty = 1
UPDATE SALES.SalesOrderDetail SET UnitPriceDiscount = 1
UPDATE SALES.SalesOrderDetail SET UnitPrice = 0.01
UPDATE SALES.SalesOrderDetail SET LineTotal = 1

BEGIN TRAN
	UPDATE SALES.SalesOrderhEADER SET TaxAmt = 0
ROLLBACK TRAN


BEGIN TRAN
	UPDATE SALES.SalesOrderhEADER SET TaxAmt = 0
ROLLBACK TRAN

SELECT subtotal, * FROM SALES.SalesOrderhEADER WHERE SalesOrderID = 43659
SELECT sum(linetotal) FROM SALES.SalesOrderDetail WHERE SalesOrderID = 43659

update SALES.SalesOrderhEADER set subtotal = 0

select CustomerID, sum(subtotal) from SALES.SalesOrderhEADER
group by CustomerID 


alter table SALES.SalesOrderhEADER add CONSTRAINT CK_SalesOrderhEADER_subtotal CHECK (subtotal = (select sum(H.subtotal) from SALES.SalesOrderhEADER H WHERE H.SalesOrderID = SalesOrderID))
-- Subqueries are not allowed in this context. Only scalar expressions are allowed.

CREATE FUNCTION FN_SalesOrderhEADER_subtotal
(
	@SalesOrderID INT
)
RETURNS MONEY
AS
BEGIN
	declare @SubTotal money
	select @SubTotal = sum(Linetotal) from SALES.SalesOrderDetail where SalesOrderID = @SalesOrderID
	RETURN @SubTotal
END
GO

SELECT DBO.FN_SalesOrderhEADER_subtotal(43659)

select *from SALES.SalesOrderhEADER

UPDATE SALES.SalesOrderhEADER SET subtotal = DBO.FN_SalesOrderhEADER_subtotal(SalesOrderID)

alter table SALES.SalesOrderhEADER add CONSTRAINT CK_SalesOrderhEADER_subtotal2 CHECK (subtotal = DBO.FN_SalesOrderhEADER_subtotal(SalesOrderID))
GO


UPDATE SALES.SalesOrderhEADER SET subtotal = 0


ALTER TABLE SALES.SalesOrderhEADER DROP CONSTRAINT CK_SalesOrderhEADER_subtotal2
ALTER TABLE SALES.SalesOrderhEADER DROP COLUMN subtotal

ALTER TABLE SALES.SalesOrderhEADER ADD SubTotal2 AS (DBO.FN_SalesOrderhEADER_subtotal(SalesOrderID))

SELECT * FROM SALES.SalesOrderhEADER