CREATE OR REPLACE FORCE VIEW MFR_RECON_BP_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, bp_key, cum_match_client_base, src_client_id, trg_client_id, match_client_id, src_client_type, trg_client_type, src_client_create_dt, trg_client_create_dt, match_client_create_dt, src_fiscal_domicile, trg_fiscal_domicile, match_fiscal_domicile, src_ref_currency, trg_ref_currency, match_ref_currency, src_noga_2008_cd, trg_noga_2008_cd, match_noga_2008_cd, cum_match_blocking, src_block_cnt, trg_block_cnt, match_block_cnt, src_block_detail, trg_block_detail, match_block_detail, cum_match_person_relation, src_rgstr_own_cnt, trg_rgstr_own_cnt, match_rgstr_own_cnt, src_accnt_own_cnt, trg_accnt_own_cnt, match_accnt_own_cnt, src_bnfcl_own_cnt, trg_bnfcl_own_cnt, match_bnfcl_own_cnt, src_prsn_rel_lst, trg_prsn_rel_lst, match_prsn_rel_lst, cum_match_attorney, src_attorney_cnt, trg_attorney_cnt, match_attorney_cnt, src_attorney_lst, trg_attorney_lst, match_attorney_lst, cum_match_spec_cond, src_sc_frgn_tax_dom_cnt, trg_sc_frgn_tax_dom_cnt, match_sc_frgn_tax_dom_cnt, src_sc_nmbrd_accnt_cnt, trg_sc_nmbrd_accnt_cnt, match_sc_nmbrd_accnt_cnt, src_sc_shell_cmpny_cnt, trg_sc_shell_cmpny_cnt, match_sc_shell_cmpny_cnt, src_sc_xtn_dvry_xpns_cnt, trg_sc_xtn_dvry_xpns_cnt, match_sc_xtn_dvry_xpns_cnt, src_sc_no_cntct_nws_cnt, trg_sc_no_cntct_nws_cnt, match_sc_no_cntct_nws_cnt, src_spcl_cndtn_lst, trg_spcl_cndtn_lst, match_spcl_cndtn_lst, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
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
  WHEN FND.MATCH_CLIENT_ID = 'OK' AND 
       FND.MATCH_CLIENT_CREATE_DT = 'OK' AND
       FND.MATCH_FISCAL_DOMICILE = 'OK' AND
       FND.MATCH_REF_CURRENCY = 'OK' AND
       FND.MATCH_NOGA_2008_CD = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_BASE, 
  FND.SRC_CLIENT_ID, 
  FND.TRG_CLIENT_ID, 
  FND.MATCH_CLIENT_ID, 
  FND.SRC_CLIENT_TYPE, 
  FND.TRG_CLIENT_TYPE, 
  FND.SRC_CLIENT_CREATE_DT, 
  FND.TRG_CLIENT_CREATE_DT, 
  FND.MATCH_CLIENT_CREATE_DT, 
  FND.SRC_FISCAL_DOMICILE, 
  FND.TRG_FISCAL_DOMICILE, 
  FND.MATCH_FISCAL_DOMICILE, 
  FND.SRC_REF_CURRENCY, 
  FND.TRG_REF_CURRENCY, 
  FND.MATCH_REF_CURRENCY, 
  FND.SRC_NOGA_2008_CD, 
  FND.TRG_NOGA_2008_CD, 
  FND.MATCH_NOGA_2008_CD, 
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
  WHEN FND.MATCH_RGSTR_OWN_CNT = 'OK' AND 
       FND.MATCH_ACCNT_OWN_CNT = 'OK' AND
       FND.MATCH_BNFCL_OWN_CNT = 'OK' AND
       FND.MATCH_PRSN_REL_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_PERSON_RELATION, 
  FND.SRC_RGSTR_OWN_CNT,
  FND.TRG_RGSTR_OWN_CNT,
  FND.MATCH_RGSTR_OWN_CNT,
  FND.SRC_ACCNT_OWN_CNT,
  FND.TRG_ACCNT_OWN_CNT,
  FND.MATCH_ACCNT_OWN_CNT,
  FND.SRC_BNFCL_OWN_CNT,
  FND.TRG_BNFCL_OWN_CNT,
  FND.MATCH_BNFCL_OWN_CNT,
  FND.SRC_PRSN_REL_LST,
  FND.TRG_PRSN_REL_LST,
  FND.MATCH_PRSN_REL_LST,
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
  CASE 
  WHEN FND.MATCH_SC_FRGN_TAX_DOM_CNT = 'OK' AND 
       FND.MATCH_SC_NMBRD_ACCNT_CNT = 'OK' AND
       FND.MATCH_SC_SHELL_CMPNY_CNT = 'OK' AND
       FND.MATCH_SC_XTN_DVRY_XPNS_CNT = 'OK' AND
       FND.MATCH_SC_NO_CNTCT_NWS_CNT = 'OK'AND
       FND.MATCH_SPCL_CNDTN_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_SPEC_COND, 
  FND.SRC_SC_FRGN_TAX_DOM_CNT,
  FND.TRG_SC_FRGN_TAX_DOM_CNT,
  FND.MATCH_SC_FRGN_TAX_DOM_CNT,
  FND.SRC_SC_NMBRD_ACCNT_CNT,
  FND.TRG_SC_NMBRD_ACCNT_CNT,
  FND.MATCH_SC_NMBRD_ACCNT_CNT,
  FND.SRC_SC_SHELL_CMPNY_CNT,
  FND.TRG_SC_SHELL_CMPNY_CNT,
  FND.MATCH_SC_SHELL_CMPNY_CNT,
  FND.SRC_SC_XTN_DVRY_XPNS_CNT,
  FND.TRG_SC_XTN_DVRY_XPNS_CNT,
  FND.MATCH_SC_XTN_DVRY_XPNS_CNT,
  FND.SRC_SC_NO_CNTCT_NWS_CNT,
  FND.TRG_SC_NO_CNTCT_NWS_CNT,
  FND.MATCH_SC_NO_CNTCT_NWS_CNT,
  FND.SRC_SPCL_CNDTN_LST,
  FND.TRG_SPCL_CNDTN_LST,
  FND.MATCH_SPCL_CNDTN_LST, 
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_BP_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

