CREATE OR REPLACE FORCE VIEW MFR_PROCESS_FINDING_V AS
SELECT "FND_ID","FND_DESCRIPTION","FND_RECORD_KEY","FND_RECORD_COUNT","FND_SEVERITY","FND_SUPPORTS_READINESS","PROCESS_ID" FROM MFR_PROCESS_FINDING;
grant select on MFR_PROCESS_FINDING_V to USR_LOGGING;
grant select on MFR_PROCESS_FINDING_V to USR_REPORTING;


