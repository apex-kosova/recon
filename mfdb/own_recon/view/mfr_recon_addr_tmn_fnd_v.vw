CREATE OR REPLACE FORCE VIEW MFR_RECON_ADDR_TMN_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, adr_key, cum_match_client_base, src_adr_type, trg_adr_type, match_adr_type, src_cntct_lang, trg_cntct_lang, match_cntct_lang, src_client_id, trg_client_id, match_client_id, cum_match_client_postal, src_salutatory_adr, trg_salutatory_adr, match_salutatory_adr, src_client_last_nm, trg_client_last_nm, match_client_last_nm, src_client_first_nm, trg_client_first_nm, match_client_first_nm, src_client_cmpny_nm, trg_client_cmpny_nm, match_client_cmpny_nm, src_adr_street_nm, trg_adr_street_nm, match_adr_street_nm, src_adr_add_on_nm, trg_adr_add_on_nm, match_adr_add_on_nm, src_adr_city_nm, trg_adr_city_nm, match_adr_city_nm, src_adr_zip_cd, trg_adr_zip_cd, match_adr_zip_cd, src_adr_cntry_cd, trg_adr_cntry_cd, match_adr_cntry_cd, src_adr_full_string, trg_adr_full_string, match_adr_full_string, cum_match_client_electronical, src_e_comunicate_chnl, trg_e_comunicate_chnl, match_e_comunicate_chnl, src_e_adr_sort, trg_e_adr_sort, match_e_adr_sort, src_e_adr_full_string, trg_e_adr_full_string, match_e_adr_full_string, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
AS
SELECT 
  FND.FND_ID,
  FND.STD_FND_COMMENT,
  FND.STD_FND_MIGR_ERROR, 
  FND.STD_FND_SIGN_OFF_FG, 
  FND.STD_FND_BUG_FIX_ITIL_NO,
  FND.MIGR_RUN_ID,
  FND.RCN_PRCS_ID,
  FND.ADR_KEY,
  
  CASE 
  WHEN FND.MATCH_ADR_TYPE = 'OK' AND 
       FND.MATCH_CNTCT_LANG = 'OK' AND
       FND.MATCH_CLIENT_ID = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_BASE,
  
  FND.SRC_ADR_TYPE,
  FND.TRG_ADR_TYPE,
  FND.MATCH_ADR_TYPE,
  FND.SRC_CNTCT_LANG,
  FND.TRG_CNTCT_LANG,
  FND.MATCH_CNTCT_LANG,
  FND.SRC_CLIENT_ID,
  FND.TRG_CLIENT_ID,
  FND.MATCH_CLIENT_ID,
  
  CASE 
  WHEN FND.MATCH_SALUTATORY_ADR = 'OK' AND
       FND.MATCH_CLIENT_LAST_NM = 'OK' AND
       FND.MATCH_CLIENT_FIRST_NM = 'OK' AND
       FND.MATCH_CLIENT_CMPNY_NM = 'OK' AND
       FND.MATCH_ADR_STREET_NM = 'OK' AND
       FND.MATCH_ADR_ADD_ON_NM = 'OK' AND
       FND.MATCH_ADR_CITY_NM = 'OK' AND
       FND.MATCH_ADR_ZIP_CD = 'OK' AND
       FND.MATCH_ADR_CNTRY_CD = 'OK' AND
       FND.MATCH_ADR_FULL_STRING = 'OK'  
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_POSTAL,
  
  FND.SRC_SALUTATORY_ADR,
  FND.TRG_SALUTATORY_ADR,
  FND.MATCH_SALUTATORY_ADR,
  FND.SRC_CLIENT_LAST_NM,
  FND.TRG_CLIENT_LAST_NM,
  FND.MATCH_CLIENT_LAST_NM,
  FND.SRC_CLIENT_FIRST_NM,
  FND.TRG_CLIENT_FIRST_NM,
  FND.MATCH_CLIENT_FIRST_NM,
  FND.SRC_CLIENT_CMPNY_NM,
  FND.TRG_CLIENT_CMPNY_NM,
  FND.MATCH_CLIENT_CMPNY_NM,
  FND.SRC_ADR_STREET_NM,
  FND.TRG_ADR_STREET_NM,
  FND.MATCH_ADR_STREET_NM,
  FND.SRC_ADR_ADD_ON_NM,
  FND.TRG_ADR_ADD_ON_NM,
  FND.MATCH_ADR_ADD_ON_NM,
  FND.SRC_ADR_CITY_NM,
  FND.TRG_ADR_CITY_NM,
  FND.MATCH_ADR_CITY_NM,
  FND.SRC_ADR_ZIP_CD,
  FND.TRG_ADR_ZIP_CD,
  FND.MATCH_ADR_ZIP_CD,
  FND.SRC_ADR_CNTRY_CD,
  FND.TRG_ADR_CNTRY_CD,
  FND.MATCH_ADR_CNTRY_CD,
  FND.SRC_ADR_FULL_STRING,
  FND.TRG_ADR_FULL_STRING,
  FND.MATCH_ADR_FULL_STRING,
  
  CASE 
  WHEN FND.MATCH_E_COMUNICATE_CHNL = 'OK' AND
       FND.MATCH_E_ADR_SORT = 'OK' AND
       FND.MATCH_E_ADR_FULL_STRING = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_ELECTRONICAL,
  
  FND.SRC_E_COMUNICATE_CHNL,
  FND.TRG_E_COMUNICATE_CHNL,
  FND.MATCH_E_COMUNICATE_CHNL,
  FND.SRC_E_ADR_SORT,
  FND.TRG_E_ADR_SORT,
  FND.MATCH_E_ADR_SORT,
  FND.SRC_E_ADR_FULL_STRING,
  FND.TRG_E_ADR_FULL_STRING,
  FND.MATCH_E_ADR_FULL_STRING,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_ADR_TMN_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
  ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

