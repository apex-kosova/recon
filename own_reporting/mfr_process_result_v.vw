CREATE OR REPLACE FORCE VIEW MFR_PROCESS_RESULT_V AS
SELECT "RESULT_COUNT","PROCESS_ID" FROM MFR_PROCESS_RESULT;
grant select on MFR_PROCESS_RESULT_V to USR_LOGGING;
grant select on MFR_PROCESS_RESULT_V to USR_REPORTING;


