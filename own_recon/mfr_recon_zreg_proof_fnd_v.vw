CREATE OR REPLACE FORCE VIEW MFR_RECON_ZREG_PROOF_FND_V
(fnd_id, proof_result_flag, itil_ticket_if_failed, proof_comment, proof_check_by, proof_check_dt, migr_run_id, smpl_id, rcn_prcs_id, rcn_prgm_name, rcn_scope_type)
AS
SELECT 
  FND.FND_ID,
  FND.PROOF_RESULT_FG,
  FND.ITIL_TICKET_IF_FAILED,
  FND.PROOF_COMMENT,
  FND.PROOF_CHECK_BY,
  FND.PROOF_CHECK_DT,
  FND.MIGR_RUN_ID,
  FND.SMPL_ID,
  FND.RCN_PRCS_ID,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP
FROM MFC_ZP_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

