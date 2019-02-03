CREATE OR REPLACE FORCE VIEW MFR_TECH_QLTY_CHK_SCOPE_V AS
SELECT "SCOPE_NAME","SCOPE_DESCRIPTION","SCOPE_TYPE","SUB_MAT_NAME" FROM MFR_TECH_QLTY_CHK_SCOPE;
grant select, insert, update, delete on MFR_TECH_QLTY_CHK_SCOPE_V to USR_LOGGING;
grant select, insert, update, delete on MFR_TECH_QLTY_CHK_SCOPE_V to USR_REPORTING;


