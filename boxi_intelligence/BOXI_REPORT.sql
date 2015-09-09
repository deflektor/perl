/* Formatted on 02.01.2013 17:00:15 (QP5 v5.163.1008.3004) */
--
-- BOXI_QUERY  (Table)
--

CREATE TABLE ADMIN.BOXI_REPORTS
(
   CUID           VARCHAR2 (50 CHAR)
  ,ID             NUMBER
  ,Report_Name    VARCHAR2 (255 CHAR)
  ,Title          VARCHAR2 (255 CHAR)
  ,Document_Type  VARCHAR2 (20 CHAR)
  ,Keywords       VARCHAR2 (4000 CHAR)
  ,Description    VARCHAR2 (4000 CHAR)
  ,CreatedBy      VARCHAR2 (50 CHAR)
  ,ModifiedBy     VARCHAR2 (50 CHAR)
  ,enhancedViewing NUMBER (1,0)
  ,stripquery     NUMBER (1,0)
  ,reportselected NUMBER
  ,permanentregionalformatting NUMBER (1,0)
  ,repositorytype VARCHAR2 (20 CHAR)
  ,locale         VARCHAR2 (20 CHAR)
  ,refreshonopen  NUMBER (1,0)
  ,extendmergedimension NUMBER (1,0)
  ,querydrill     NUMBER (1,0)
  ,ispartiallyrefreshed NUMBER (1,0)
  ,nbqaawsconnection NUMBER
  ,inputform      VARCHAR2 (4000 CHAR)
  ,documentversion VARCHAR2 (20 CHAR)
  ,lastrefreshduration NUMBER
  ,documentsize   NUMBER
  ,creationtime   DATE
  ,modificationtime DATE
  ,lastrefreshtime DATE
  ,UPDATE_DATE    DATE
)
TABLESPACE BO_REP


/
COMMENT ON TABLE ADMIN.BOXI_REPORTS IS 'HK - Business Objects Export of Objects Reports'
/
