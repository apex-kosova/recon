CREATE OR REPLACE PROCEDURE DELETE_FOR_TESTING AS
BEGIN
  delete from mfr_process_finding;
  delete from mfr_process_result;
  delete from mfr_scope_finding;
  delete from mfr_process;
  commit;
END DELETE_FOR_TESTING;
/
grant execute on DELETE_FOR_TESTING to USR_REPORTING with grant option;


