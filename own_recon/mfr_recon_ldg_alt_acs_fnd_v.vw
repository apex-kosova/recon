CREATE OR REPLACE FORCE VIEW MFR_RECON_LDG_ALT_ACS_FND_V
(fnd_id, ldg_acc_key, ldg_acc_name, price_per_unit, acc_curr_cd, acc_amount, exch_rate, acc_amount_chf, match_acc_amount_chf, run_id, prcs_id, d2k_cum_cnt, d2k_cum_acc_amount, d2k_cum_acc_amount_chf, diff_acc_amount_tms, diff_acc_amount_chf_tms, acs_ldg_acc_grp_nm, recon_prgm_name, recon_scope_name)
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
  FND.MATCH_ACC_AMOUNT_CHF,
  FND.MIGR_RUN_ID, 
  FND.RCN_PRCS_ID, 
  FND.D2K_CUM_CNT,
  FND.D2K_CUM_ACC_AMOUNT,
  FND.D2K_CUM_ACC_AMOUNT_CHF,
  FND.DIFF_ACC_AMOUNT_TMS,
  FND.DIFF_ACC_AMOUNT_CHF_TMS,
  FND.ACS_LDG_ACC_GRP_NM,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP
FROM MFC_LDG_ALT_ACS_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

