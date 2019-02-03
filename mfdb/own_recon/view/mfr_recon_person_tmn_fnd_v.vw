CREATE OR REPLACE FORCE VIEW MFR_RECON_PERSON_TMN_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, psn_key, cum_match_client_base, src_client_type, trg_client_type, match_client_type, src_client_nm, trg_client_nm, match_client_nm, src_nation_cntry_cd, trg_nation_cntry_cd, match_nation_cntry_cd, src_snb_nm, trg_snb_nm, match_snb_nm, src_bus_connect_type, trg_bus_connect_type, match_bus_connect_type, cum_match_person_ident, src_prsn_ident_cnt, trg_prsn_ident_cnt, match_prsn_ident_cnt, src_prsn_ident_lst, trg_prsn_ident_lst, match_prsn_ident_lst, cum_match_person_relation, src_prsn_rel_pep_dap_cnt, trg_prsn_rel_pep_dap_cnt, match_prsn_rel_pep_dap_cnt, src_prsn_rel_pep_dap_lst, trg_prsn_rel_pep_dap_lst, match_prsn_rel_pep_dap_lst, src_prsn_rel_rspnsbl, trg_prsn_rel_rspnsbl, match_prsn_rel_rspnsbl, cum_match_person_document, src_dcmnt_cnt, trg_dcmnt_cnt, match_dcmnt_cnt, src_dcmnt_lst, trg_dcmnt_lst, match_dcmnt_lst, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
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
  WHEN FND.MATCH_CLIENT_TYPE = 'OK' AND 
       FND.MATCH_CLIENT_NM = 'OK' AND
       FND.MATCH_NATION_CNTRY_CD = 'OK' AND
       FND.MATCH_SNB_NM = 'OK' AND
       FND.MATCH_BUS_CONNECT_TYPE = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_BASE,
  
  FND.SRC_CLIENT_TYPE,
  FND.TRG_CLIENT_TYPE,
  FND.MATCH_CLIENT_TYPE,
  FND.SRC_CLIENT_NM,
  FND.TRG_CLIENT_NM,
  FND.MATCH_CLIENT_NM,
  FND.SRC_NATION_CNTRY_CD,
  FND.TRG_NATION_CNTRY_CD,
  FND.MATCH_NATION_CNTRY_CD,
  FND.SRC_SNB_NM,
  FND.TRG_SNB_NM,
  FND.MATCH_SNB_NM,
  FND.SRC_BUS_CONNECT_TYPE,
  FND.TRG_BUS_CONNECT_TYPE,
  FND.MATCH_BUS_CONNECT_TYPE,
  
  CASE 
  WHEN FND.MATCH_PRSN_IDENT_CNT = 'OK' AND 
       FND.MATCH_PRSN_IDENT_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_PERSON_IDENT,
  
  FND.SRC_PRSN_IDENT_CNT,
  FND.TRG_PRSN_IDENT_CNT,
  FND.MATCH_PRSN_IDENT_CNT,
  FND.SRC_PRSN_IDENT_LST,
  FND.TRG_PRSN_IDENT_LST,
  FND.MATCH_PRSN_IDENT_LST,
  
  CASE 
  WHEN FND.MATCH_PRSN_REL_PEP_DAP_CNT = 'OK' AND 
       FND.MATCH_PRSN_REL_PEP_DAP_LST = 'OK' AND
       FND.MATCH_PRSN_REL_RSPNSBL = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_PERSON_RELATION,
  
  FND.SRC_PRSN_REL_PEP_DAP_CNT,
  FND.TRG_PRSN_REL_PEP_DAP_CNT,
  FND.MATCH_PRSN_REL_PEP_DAP_CNT,
  FND.SRC_PRSN_REL_PEP_DAP_LST,
  FND.TRG_PRSN_REL_PEP_DAP_LST,
  FND.MATCH_PRSN_REL_PEP_DAP_LST,
  FND.SRC_PRSN_REL_RSPNSBL,
  FND.TRG_PRSN_REL_RSPNSBL,
  FND.MATCH_PRSN_REL_RSPNSBL,
  
  CASE 
  WHEN FND.MATCH_DCMNT_CNT = 'OK' AND 
       FND.MATCH_DCMNT_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_PERSON_DOCUMENT,
  
  FND.SRC_DCMNT_CNT,
  FND.TRG_DCMNT_CNT,
  FND.MATCH_DCMNT_CNT,
  FND.SRC_DCMNT_LST,
  FND.TRG_DCMNT_LST,
  FND.MATCH_DCMNT_LST,

  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_PSN_TMN_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
  ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

