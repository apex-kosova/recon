CREATE OR REPLACE FORCE VIEW MFR_RECON_MACC_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, macc_key, cum_match_client_base, src_client_id, trg_client_id, match_client_id, src_accnt_id, trg_accnt_id, match_accnt_id, src_iban, trg_iban, match_iban, src_esr_id, trg_esr_id, match_esr_id, src_ctn_key, trg_ctn_key, cum_match_account, src_product_key, trg_product_key, match_product_key, src_product_nm, trg_product_nm, src_create_dt, trg_create_dt, match_create_dt, src_last_intr_run_dt, trg_last_intr_run_dt, match_last_intr_run_dt, src_ref_currency, trg_ref_currency, match_ref_currency, src_accnt_opener, trg_accnt_opener, match_accnt_opener, cum_match_blocking, src_block_cnt, trg_block_cnt, match_block_cnt, src_block_detail, trg_block_detail, match_block_detail, cum_match_spec_cond, src_spcl_cndtn_cnt, trg_spcl_cndtn_cnt, match_spcl_cndtn_cnt, src_spcl_cndtn_lst, trg_spcl_cndtn_lst, match_spcl_cndtn_lst, rcn_prcs_id, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
AS
SELECT 
	FND.FND_ID, 
	FND.STD_FND_COMMENT, 
	FND.STD_FND_MIGR_ERROR, 
  FND.STD_FND_SIGN_OFF_FG, 
	FND.STD_FND_BUG_FIX_ITIL_NO,
	FND.MIGR_RUN_ID, 
	FND.MACC_KEY, 
  CASE 
  WHEN FND.MATCH_CLIENT_ID = 'OK' AND 
       FND.MATCH_ACCNT_ID = 'OK' AND
       FND.MATCH_IBAN = 'OK' AND
       FND.MATCH_ESR_ID = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_BASE, 
	FND.SRC_CLIENT_ID, 
	FND.TRG_CLIENT_ID, 
	FND.MATCH_CLIENT_ID, 
	FND.SRC_ACCNT_ID, 
	FND.TRG_ACCNT_ID, 
	FND.MATCH_ACCNT_ID, 
	FND.SRC_IBAN, 
	FND.TRG_IBAN, 
	FND.MATCH_IBAN, 
	FND.SRC_ESR_ID, 
	FND.TRG_ESR_ID, 
	FND.MATCH_ESR_ID, 
	FND.SRC_CTN_KEY, 
	FND.TRG_CTN_KEY, 
  CASE 
  WHEN FND.MATCH_PRODUCT_KEY = 'OK' AND 
       FND.MATCH_CREATE_DT = 'OK' AND
       FND.MATCH_LAST_INTR_RUN_DT = 'OK' AND
       FND.MATCH_REF_CURRENCY = 'OK' AND
       FND.MATCH_ACCNT_OPENER = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_ACCOUNT, 
	FND.SRC_PRODUCT_KEY, 
	FND.TRG_PRODUCT_KEY, 
	FND.MATCH_PRODUCT_KEY, 
	FND.SRC_PRODUCT_NM, 
	FND.TRG_PRODUCT_NM, 
	FND.SRC_CREATE_DT, 
	FND.TRG_CREATE_DT, 
	FND.MATCH_CREATE_DT, 
  FND.SRC_LAST_INTR_RUN_DT,
  FND.TRG_LAST_INTR_RUN_DT,
  FND.MATCH_LAST_INTR_RUN_DT,
	FND.SRC_REF_CURRENCY, 
	FND.TRG_REF_CURRENCY, 
	FND.MATCH_REF_CURRENCY, 
	FND.SRC_ACCNT_OPENER, 
	FND.TRG_ACCNT_OPENER, 
	FND.MATCH_ACCNT_OPENER, 
  CASE 
  WHEN FND.MATCH_BLOCK_CNT = 'OK' AND 
       FND.MATCH_BLOCK_DETAIL = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_BLOCKING, 
	FND.SRC_BLOCK_CNT, 
	FND.TRG_BLOCK_CNT, 
	FND.MATCH_BLOCK_CNT, 
	FND.SRC_BLOCK_DETAIL, 
	FND.TRG_BLOCK_DETAIL, 
	FND.MATCH_BLOCK_DETAIL, 
  CASE 
  WHEN FND.MATCH_SPCL_CNDTN_CNT = 'OK' AND 
       FND.MATCH_SPCL_CNDTN_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_SPEC_COND, 
	FND.SRC_SPCL_CNDTN_CNT, 
	FND.TRG_SPCL_CNDTN_CNT, 
	FND.MATCH_SPCL_CNDTN_CNT, 
	FND.SRC_SPCL_CNDTN_LST, 
	FND.TRG_SPCL_CNDTN_LST, 
	FND.MATCH_SPCL_CNDTN_LST, 
	FND.RCN_PRCS_ID,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_MACC_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

