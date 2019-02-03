CREATE OR REPLACE FORCE VIEW MFR_RECON_CONT_TMN_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, ctn_key, cum_match_client_base, src_client_id, trg_client_id, match_client_id, src_xtrnl_key, trg_xtrnl_key, match_xtrnl_key, src_client_create_dt, trg_client_create_dt, match_client_create_dt, src_ctn_rubric, trg_ctn_rubric, match_ctn_rubric, src_ref_currency, trg_ref_currency, match_ref_currency, src_ctn_type, trg_ctn_type, match_ctn_type, cum_match_flag, src_is_custodian, trg_is_custodian, match_is_custodian, src_is_inhouse_nostro, trg_is_inhouse_nostro, match_is_inhouse_nostro, src_is_lmt_hrchy_pf, trg_is_lmt_hrchy_pf, match_is_lmt_hrchy_pf, cum_match_blocking, src_block_cnt, trg_block_cnt, match_block_cnt, src_block_detail, trg_block_detail, match_block_detail, cum_match_cost_fee, src_cost_fee_cnt, trg_cost_fee_cnt, match_cost_fee_cnt, src_cost_fee_detail, trg_cost_fee_detail, match_cost_fee_detail, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
AS
SELECT 
  FND.FND_ID,
  FND.STD_FND_COMMENT,
  FND.STD_FND_MIGR_ERROR, 
  FND.STD_FND_SIGN_OFF_FG, 
  FND.STD_FND_BUG_FIX_ITIL_NO,
  FND.MIGR_RUN_ID,
  FND.RCN_PRCS_ID,
  FND.CTN_KEY,
  
  CASE 
  WHEN FND.MATCH_CLIENT_ID = 'OK' AND 
       FND.MATCH_XTRNL_KEY = 'OK' AND
       FND.MATCH_CLIENT_CREATE_DT = 'OK' AND
       FND.MATCH_CTN_RUBRIC = 'OK' AND
       FND.MATCH_REF_CURRENCY = 'OK' AND
       FND.MATCH_CTN_TYPE = 'OK'  
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_BASE,
  
  FND.SRC_CLIENT_ID,
  FND.TRG_CLIENT_ID,
  FND.MATCH_CLIENT_ID,
  FND.SRC_XTRNL_KEY,
  FND.TRG_XTRNL_KEY,
  FND.MATCH_XTRNL_KEY,
  FND.SRC_CLIENT_CREATE_DT,
  FND.TRG_CLIENT_CREATE_DT,
  FND.MATCH_CLIENT_CREATE_DT,
  FND.SRC_CTN_RUBRIC,
  FND.TRG_CTN_RUBRIC,
  FND.MATCH_CTN_RUBRIC,
  FND.SRC_REF_CURRENCY,
  FND.TRG_REF_CURRENCY,
  FND.MATCH_REF_CURRENCY,
  FND.SRC_CTN_TYPE,
  FND.TRG_CTN_TYPE,
  FND.MATCH_CTN_TYPE,
  
  CASE 
  WHEN FND.MATCH_IS_CUSTODIAN = 'OK' AND 
       FND.MATCH_IS_INHOUSE_NOSTRO = 'OK' AND
       FND.MATCH_IS_LMT_HRCHY_PF = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_FLAG,

  FND.SRC_IS_CUSTODIAN,
  FND.TRG_IS_CUSTODIAN,
  FND.MATCH_IS_CUSTODIAN,
  FND.SRC_IS_INHOUSE_NOSTRO,
  FND.TRG_IS_INHOUSE_NOSTRO,
  FND.MATCH_IS_INHOUSE_NOSTRO,
  FND.SRC_IS_LMT_HRCHY_PF,
  FND.TRG_IS_LMT_HRCHY_PF,
  FND.MATCH_IS_LMT_HRCHY_PF,

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
  WHEN FND.MATCH_COST_FEE_CNT = 'OK' AND 
       FND.MATCH_COST_FEE_DETAIL = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_COST_FEE,
  
  FND.SRC_COST_FEE_CNT,
  FND.TRG_COST_FEE_CNT,
  FND.MATCH_COST_FEE_CNT,
  FND.SRC_COST_FEE_DETAIL,
  FND.TRG_COST_FEE_DETAIL,
  FND.MATCH_COST_FEE_DETAIL,

  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_CTN_TMN_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
  ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

