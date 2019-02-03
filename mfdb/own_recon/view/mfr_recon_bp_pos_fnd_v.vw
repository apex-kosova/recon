CREATE OR REPLACE FORCE VIEW MFR_RECON_BP_POS_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, bp_key, cum_match_attorney, src_attorney_cnt, trg_attorney_cnt, match_attorney_cnt, src_attorney_lst, trg_attorney_lst, match_attorney_lst, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
AS
SELECT 
  FND.FND_ID, 
  FND.STD_FND_COMMENT, 
  FND.STD_FND_MIGR_ERROR, 
  FND.STD_FND_SIGN_OFF_FG, 
	FND.STD_FND_BUG_FIX_ITIL_NO,
  FND.MIGR_RUN_ID, 
  FND.RCN_PRCS_ID, 
  FND.BP_KEY, 
  CASE 
  WHEN FND.MATCH_ATTORNEY_CNT = 'OK' AND 
       FND.MATCH_ATTORNEY_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_ATTORNEY, 
  FND.SRC_ATTORNEY_CNT,
  FND.TRG_ATTORNEY_CNT,
  FND.MATCH_ATTORNEY_CNT,
  FND.SRC_ATTORNEY_LST,
  FND.TRG_ATTORNEY_LST,
  FND.MATCH_ATTORNEY_LST,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_BP_POS_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

