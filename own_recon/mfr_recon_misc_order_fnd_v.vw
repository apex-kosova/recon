CREATE OR REPLACE FORCE VIEW MFR_RECON_MISC_ORDER_FND_V
(fnd_id, order_result_flag, itil_ticket_if_failed, order_comment, order_check_by, order_check_dt, migr_run_id, order_id, rcn_prcs_id, rcn_prgm_name, rcn_scope_type)
AS
SELECT 
  FND.FND_ID,
  FND.ORDER_RESULT_FG, 
  FND.ITIL_TICKET_IF_FAILED,
  FND.ORDER_COMMENT, 
  FND.ORDER_CHECK_BY, 
  FND.ORDER_CHECK_DT, 
  FND.MIGR_RUN_ID, 
  FND.ORDER_ID, 
  FND.RCN_PRCS_ID,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP
FROM MFC_MO_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

