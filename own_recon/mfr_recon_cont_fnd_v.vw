CREATE OR REPLACE FORCE VIEW MFR_RECON_CONT_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, ctn_key, cum_match_client_base, src_client_id, trg_client_id, match_client_id, src_dpt_no_dialba, trg_dpt_no_dialba, match_dpt_no_dialba, src_client_create_dt, trg_client_create_dt, match_client_create_dt, src_ref_currency, trg_ref_currency, match_ref_currency, src_ctn_type, trg_ctn_type, match_ctn_type, src_ctn_rubric, trg_ctn_rubric, match_ctn_rubric, src_dpt_prdct, trg_dpt_prdct, match_dpt_prdct, cum_match_blocking, src_block_cnt, trg_block_cnt, match_block_cnt, src_block_detail, trg_block_detail, match_block_detail, cum_match_person_relation, src_bnfcl_own_cnt, trg_bnfcl_own_cnt, match_bnfcl_own_cnt, src_bnfcl_own_lst, trg_bnfcl_own_lst, match_bnfcl_own_lst, cum_match_document, src_doc_cnt, trg_doc_cnt, match_doc_cnt, src_doc_lst, trg_doc_lst, match_doc_lst, cum_match_spec_cond, src_sc_dpt_cf_cnt, trg_sc_dpt_cf_cnt, match_sc_dpt_cf_cnt, src_sc_crtg_cnt, trg_sc_crtg_cnt, match_sc_crtg_cnt, src_sc_ebnk_cnt, trg_sc_ebnk_cnt, match_sc_ebnk_cnt, src_sc_crtg_toff_cnt, trg_sc_crtg_toff_cnt, match_sc_crtg_toff_cnt, src_spcl_cndtn_lst, trg_spcl_cndtn_lst, match_spcl_cndtn_lst, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
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
       FND.MATCH_DPT_NO_DIALBA = 'OK' AND
       FND.MATCH_CLIENT_CREATE_DT = 'OK' AND
       FND.MATCH_REF_CURRENCY = 'OK' AND
       FND.MATCH_CTN_TYPE = 'OK' AND
       FND.MATCH_CTN_RUBRIC = 'OK' AND
       FND.MATCH_DPT_PRDCT = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_BASE,
  FND.SRC_CLIENT_ID,
  FND.TRG_CLIENT_ID,
  FND.MATCH_CLIENT_ID,
  FND.SRC_DPT_NO_DIALBA,
  FND.TRG_DPT_NO_DIALBA,
  FND.MATCH_DPT_NO_DIALBA,
  FND.SRC_CLIENT_CREATE_DT,
  FND.TRG_CLIENT_CREATE_DT,
  FND.MATCH_CLIENT_CREATE_DT,
  FND.SRC_REF_CURRENCY,
  FND.TRG_REF_CURRENCY,
  FND.MATCH_REF_CURRENCY,
  FND.SRC_CTN_TYPE,
  FND.TRG_CTN_TYPE,
  FND.MATCH_CTN_TYPE,
  FND.SRC_CTN_RUBRIC,
  FND.TRG_CTN_RUBRIC,
  FND.MATCH_CTN_RUBRIC,
  FND.SRC_DPT_PRDCT,
  FND.TRG_DPT_PRDCT,
  FND.MATCH_DPT_PRDCT,
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
  WHEN FND.MATCH_BNFCL_OWN_CNT = 'OK' AND 
       FND.MATCH_BNFCL_OWN_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_PERSON_RELATION,
  FND.SRC_BNFCL_OWN_CNT,
  FND.TRG_BNFCL_OWN_CNT,
  FND.MATCH_BNFCL_OWN_CNT,
  FND.SRC_BNFCL_OWN_LST,
  FND.TRG_BNFCL_OWN_LST,
  FND.MATCH_BNFCL_OWN_LST,
  CASE 
  WHEN FND.MATCH_DOC_CNT = 'OK' AND 
       FND.MATCH_DOC_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_DOCUMENT,
  FND.SRC_DOC_CNT,
  FND.TRG_DOC_CNT,
  FND.MATCH_DOC_CNT,
  FND.SRC_DOC_LST,
  FND.TRG_DOC_LST,
  FND.MATCH_DOC_LST,
  CASE 
  WHEN FND.MATCH_SC_DPT_CF_CNT = 'OK' AND 
       FND.MATCH_SC_CRTG_CNT = 'OK' AND
       FND.MATCH_SC_EBNK_CNT = 'OK' AND
       FND.MATCH_SC_CRTG_TOFF_CNT = 'OK' AND
       FND.MATCH_SPCL_CNDTN_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_SPEC_COND,
  FND.SRC_SC_DPT_CF_CNT,
  FND.TRG_SC_DPT_CF_CNT,
  FND.MATCH_SC_DPT_CF_CNT,
  FND.SRC_SC_CRTG_CNT,
  FND.TRG_SC_CRTG_CNT,
  FND.MATCH_SC_CRTG_CNT,
  FND.SRC_SC_EBNK_CNT,
  FND.TRG_SC_EBNK_CNT,
  FND.MATCH_SC_EBNK_CNT,
  FND.SRC_SC_CRTG_TOFF_CNT,
  FND.TRG_SC_CRTG_TOFF_CNT,
  FND.MATCH_SC_CRTG_TOFF_CNT,
  FND.SRC_SPCL_CNDTN_LST,
  FND.TRG_SPCL_CNDTN_LST,
  FND.MATCH_SPCL_CNDTN_LST,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_CTN_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

