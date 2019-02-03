CREATE OR REPLACE FORCE VIEW MFR_RECON_LDG_D2K_FND_V
(fnd_id, ldg_acc_key, ldg_acc_name, price_per_unit, acc_curr_cd, acc_amount, exch_rate, acc_amount_chf, ldg_fnd_comment, ldg_fnd_sign_off_fg, ldg_fnd_bug_fix_itil_no, match_acc_amount_chf, run_id, prcs_id, map_d2k_ldg_acc_key, map_acs_ldg_acc_key, recon_prgm_name, recon_scope_name, inherit_fnd_id, inherit_run_rank)
AS
SELECT 
  FND.FND_ID,
  FND.LDG_ACC_KEY,
  FND.LDG_ACC_NAME,
  FND.PRICE_PER_UNIT,
  FND.ACC_CURR_CD,
  FND.ACC_AMOUNT,
  FND.EXCH_RATE,
  FND.ACC_AMOUNT_CHF,
  FND.LDG_FND_COMMENT,
  FND.LDG_FND_SIGN_OFF_FG, 
	FND.LDG_FND_BUG_FIX_ITIL_NO,
  FND.MATCH_ACC_AMOUNT_CHF,
  FND.MIGR_RUN_ID, 
  FND.RCN_PRCS_ID, 
  FND.MAP_D2K_LDG_ACC_KEY,
  FND.MAP_ACS_LDG_ACC_KEY,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_LDG_D2K_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

