CREATE OR REPLACE FORCE VIEW MFR_RECON_PERSON_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, psn_key, cum_match_client_base, src_client_id, trg_client_id, match_client_id, src_client_nm, trg_client_nm, match_client_nm, src_client_birth_dt, trg_client_birth_dt, match_client_birth_dt, src_nation_cntry_cd, trg_nation_cntry_cd, match_nation_cntry_cd, src_legal_form, trg_legal_form, match_legal_form, src_snb_cd, trg_snb_cd, match_snb_cd, src_client_type, trg_client_type, match_client_type, src_client_status, trg_client_status, match_client_status, src_ident_status, trg_ident_status, match_ident_status, src_capability_2_act, trg_capability_2_act, match_capability_2_act, cum_match_person_relation, src_prsn_rel_wnr_cmty_cnt, trg_prsn_rel_wnr_cmty_cnt, match_prsn_rel_wnr_cmty_cnt, src_prsn_rel_wnr_cmty_lst, trg_prsn_rel_wnr_cmty_lst, match_prsn_rel_wnr_cmty_lst, src_prsn_rel_all_cnt, trg_prsn_rel_all_cnt, src_prsn_rel_all_lst, trg_prsn_rel_all_lst, cum_match_fatca, src_fatca_cmpl, trg_fatca_cmpl, match_fatca_cmpl, src_fatca_eval, trg_fatca_eval, match_fatca_eval, src_fatca_status, trg_fatca_status, match_fatca_status, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
AS
SELECT 
  FND.FND_ID,
  FND.STD_FND_COMMENT,
  FND.STD_FND_MIGR_ERROR, 
  FND.STD_FND_SIGN_OFF_FG, 
	FND.STD_FND_BUG_FIX_ITIL_NO,
  FND.MIGR_RUN_ID,
  FND.RCN_PRCS_ID,
  FND.PSN_KEY,
  CASE 
  WHEN FND.MATCH_CLIENT_ID = 'OK' AND 
       FND.MATCH_CLIENT_NM = 'OK' AND
       FND.MATCH_CLIENT_BIRTH_DT = 'OK' AND
       FND.MATCH_NATION_CNTRY_CD = 'OK' AND
       FND.MATCH_LEGAL_FORM = 'OK' AND
       FND.MATCH_SNB_CD = 'OK' AND
       FND.MATCH_CLIENT_TYPE = 'OK' AND
       FND.MATCH_CLIENT_STATUS = 'OK' AND
       FND.MATCH_IDENT_STATUS = 'OK' AND
       FND.MATCH_CAPABILITY_2_ACT = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_BASE,
  FND.SRC_CLIENT_ID,
  FND.TRG_CLIENT_ID,
  FND.MATCH_CLIENT_ID,
  FND.SRC_CLIENT_NM,
  FND.TRG_CLIENT_NM,
  FND.MATCH_CLIENT_NM,
  FND.SRC_CLIENT_BIRTH_DT,
  FND.TRG_CLIENT_BIRTH_DT,
  FND.MATCH_CLIENT_BIRTH_DT,
  FND.SRC_NATION_CNTRY_CD,
  FND.TRG_NATION_CNTRY_CD,
  FND.MATCH_NATION_CNTRY_CD,
  FND.SRC_LEGAL_FORM,
  FND.TRG_LEGAL_FORM,
  FND.MATCH_LEGAL_FORM,
  FND.SRC_SNB_CD,
  FND.TRG_SNB_CD,
  FND.MATCH_SNB_CD,
  FND.SRC_CLIENT_TYPE,
  FND.TRG_CLIENT_TYPE,
  FND.MATCH_CLIENT_TYPE,
  FND.SRC_CLIENT_STATUS,
  FND.TRG_CLIENT_STATUS,
  FND.MATCH_CLIENT_STATUS,
  FND.SRC_IDENT_STATUS,
  FND.TRG_IDENT_STATUS,
  FND.MATCH_IDENT_STATUS,
  FND.SRC_CAPABILITY_2_ACT,
  FND.TRG_CAPABILITY_2_ACT,
  FND.MATCH_CAPABILITY_2_ACT,
  CASE 
  WHEN FND.MATCH_PRSN_REL_WNR_CMTY_CNT = 'OK' AND 
       FND.MATCH_PRSN_REL_WNR_CMTY_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_PERSON_RELATION,
  FND.SRC_PRSN_REL_WNR_CMTY_CNT,
  FND.TRG_PRSN_REL_WNR_CMTY_CNT,
  FND.MATCH_PRSN_REL_WNR_CMTY_CNT,
  FND.SRC_PRSN_REL_WNR_CMTY_LST,
  FND.TRG_PRSN_REL_WNR_CMTY_LST,
  FND.MATCH_PRSN_REL_WNR_CMTY_LST,
  FND.SRC_PRSN_REL_ALL_CNT,
  FND.TRG_PRSN_REL_ALL_CNT,
  FND.SRC_PRSN_REL_ALL_LST,
  FND.TRG_PRSN_REL_ALL_LST,
  CASE 
  WHEN FND.MATCH_FATCA_CMPL = 'OK' AND 
       FND.MATCH_FATCA_EVAL = 'OK' AND
       FND.MATCH_FATCA_STATUS = 'OK'  
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_FATCA,
  FND.SRC_FATCA_CMPL,
  FND.TRG_FATCA_CMPL,
  FND.MATCH_FATCA_CMPL,
  FND.SRC_FATCA_EVAL,
  FND.TRG_FATCA_EVAL,
  FND.MATCH_FATCA_EVAL,
  FND.SRC_FATCA_STATUS,
  FND.TRG_FATCA_STATUS,
  FND.MATCH_FATCA_STATUS,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_PSN_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

