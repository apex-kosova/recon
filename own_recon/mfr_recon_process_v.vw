CREATE OR REPLACE FORCE VIEW MFR_RECON_PROCESS_V
(prcs_id, prcs_status, prcs_start_time, prcs_end_time, prcs_finding, migr_run_id, recon_prgm_name, recon_scope_type, recon_fnd_cnt, recon_no_comment_cnt, recon_load_cnt, process_type)
AS
SELECT 
  RCN_PRCS_ID,
  RCN_PRCS_STATUS,
  RCN_PRCS_START_TIME,
  RCN_PRCS_END_TIME,
  RCN_PRCS_FINDING,
  MIGR_RUN_ID,
  RCN_PRGM_NAME,
  RCN_SCOPE_TYP,
  RCN_FND_CNT,
  RCN_NO_CMNT_CNT,
  RCN_LOAD_CNT,
  PRCS_TYPE
FROM MFC_RCN_PRCS_V;

