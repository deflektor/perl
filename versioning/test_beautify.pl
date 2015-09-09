use SQL::Beautify;

my $my_sql = "
      CREATE TABLE ADMIN.ADC_JOURNAL 
   (	ADC_JOURNAL_ID NUMBER(38,0), 
	CREATION_DATE DATE DEFAULT SYSDATE, 
	DATABASE_LINK VARCHAR2(128 BYTE)
   )
 NOCOMPRESS LOGGING TABLESPACE EDW_ADMIN_DATA;

			select owner, object_type, object_name, subobject_name, last_ddl_time from all_objects
			where 1=1
			and object_type in ('SEQUENCE','PROCEDURE','PACKAGE','PACKAGE BODY','MATERIALIZED VIEW','TABLE','INDEX','FUNCTION','VIEW', 'SYNONYM') 
			and owner in ('ADMIN', 'STG', 'EDW')
			and object_name not like 'X_%'
			and status = 'VALID'
			and object_type in ('TABLE', 'VIEW') and owner = 'EDW'
			order by 1 asc
			, 2 asc, 
			3 asc, 4 
			asc, 
			5 asc
";

my $tsql = SQL::Beautify->new(spaces=>2, uc_keywords =>1);
$tsql->add_rule("break-token","AND");
$tsql->add_rule("over-token",",");
$tsql->query($my_sql);
print $tsql->beautify;