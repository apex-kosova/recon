CREATE OR REPLACE FORCE VIEW MFR_RECON_BP_TMN_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, bp_key, cum_match_client_base, src_client_type, trg_client_type, match_client_type, src_client_create_dt, trg_client_create_dt, match_client_create_dt, src_noga_2008_cd, trg_noga_2008_cd, match_noga_2008_cd, src_fiscal_domicile, trg_fiscal_domicile, match_fiscal_domicile, src_ref_currency, trg_ref_currency, match_ref_currency, cum_match_key, src_xtrnl_lgcy_key, trg_xtrnl_lgcy_key, match_xtrnl_lgcy_key, src_swift_key, trg_swift_key, match_swift_key, src_clearing_key, trg_clearing_key, match_clearing_key, cum_match_class, src_customer_type, trg_customer_type, match_customer_type, src_counter_prty_type, trg_counter_prty_type, match_counter_prty_type, src_cstdn_csh_crrspnd_type, trg_cstdn_csh_crrspnd_type, match_cstdn_csh_crrspnd_type, src_central_bnk_select, trg_central_bnk_select, match_central_bnk_select, src_calc_agent, trg_calc_agent, match_calc_agent, cum_match_fi_reporting, src_fire_counter_prty_type, trg_fire_counter_prty_type, match_fire_counter_prty_type, src_fire_centrl_counter_prty, trg_fire_centrl_counter_prty, match_fire_centrl_counter_prty, src_fire_entity_cd, trg_fire_entity_cd, match_fire_entity_cd, src_fire_consolid_lvl, trg_fire_consolid_lvl, match_fire_consolid_lvl, src_kpmg_counter_prty, trg_kpmg_counter_prty, match_kpmg_counter_prty, cum_match_person_relation, src_prsn_rel_cnt, trg_prsn_rel_cnt, match_prsn_rel_cnt, src_prsn_rel_lst, trg_prsn_rel_lst, match_prsn_rel_lst, cum_match_standing_instruct, src_stdg_instr_cnt, trg_stdg_instr_cnt, match_stdg_instr_cnt, src_stdg_instr_lst, trg_stdg_instr_lst, match_stdg_instr_lst, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
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
  WHEN FND.MATCH_CLIENT_TYPE = 'OK' AND 
       FND.MATCH_CLIENT_CREATE_DT = 'OK' AND
       FND.MATCH_NOGA_2008_CD = 'OK' AND
       FND.MATCH_FISCAL_DOMICILE = 'OK' AND
       FND.MATCH_REF_CURRENCY = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLIENT_BASE, 
  
  FND.SRC_CLIENT_TYPE,
  FND.TRG_CLIENT_TYPE,
  FND.MATCH_CLIENT_TYPE,
  FND.SRC_CLIENT_CREATE_DT,
  FND.TRG_CLIENT_CREATE_DT,
  FND.MATCH_CLIENT_CREATE_DT,
  FND.SRC_NOGA_2008_CD,
  FND.TRG_NOGA_2008_CD,
  FND.MATCH_NOGA_2008_CD,
  FND.SRC_FISCAL_DOMICILE,
  FND.TRG_FISCAL_DOMICILE,
  FND.MATCH_FISCAL_DOMICILE,
  FND.SRC_REF_CURRENCY,
  FND.TRG_REF_CURRENCY,
  FND.MATCH_REF_CURRENCY,
  
  CASE 
  WHEN FND.MATCH_XTRNL_LGCY_KEY = 'OK' AND 
       FND.MATCH_SWIFT_KEY = 'OK' AND 
       FND.MATCH_CLEARING_KEY = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_KEY, 
  
  FND.SRC_XTRNL_LGCY_KEY,
  FND.TRG_XTRNL_LGCY_KEY,
  FND.MATCH_XTRNL_LGCY_KEY,
  FND.SRC_SWIFT_KEY,
  FND.TRG_SWIFT_KEY,
  FND.MATCH_SWIFT_KEY,
  FND.SRC_CLEARING_KEY,
  FND.TRG_CLEARING_KEY,
  FND.MATCH_CLEARING_KEY,
  
  CASE 
  WHEN FND.MATCH_CUSTOMER_TYPE = 'OK' AND 
       FND.MATCH_COUNTER_PRTY_TYPE = 'OK' AND 
       FND.MATCH_CSTDN_CSH_CRRSPND_TYPE = 'OK'  AND 
       FND.MATCH_CENTRAL_BNK_SELECT = 'OK'  AND 
       FND.MATCH_CALC_AGENT = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_CLASS, 
  
  FND.SRC_CUSTOMER_TYPE,
  FND.TRG_CUSTOMER_TYPE,
  FND.MATCH_CUSTOMER_TYPE,
  FND.SRC_COUNTER_PRTY_TYPE,
  FND.TRG_COUNTER_PRTY_TYPE,
  FND.MATCH_COUNTER_PRTY_TYPE,
  FND.SRC_CSTDN_CSH_CRRSPND_TYPE,
  FND.TRG_CSTDN_CSH_CRRSPND_TYPE,
  FND.MATCH_CSTDN_CSH_CRRSPND_TYPE,
  FND.SRC_CENTRAL_BNK_SELECT,
  FND.TRG_CENTRAL_BNK_SELECT,
  FND.MATCH_CENTRAL_BNK_SELECT,
  FND.SRC_CALC_AGENT,
  FND.TRG_CALC_AGENT,
  FND.MATCH_CALC_AGENT,

  CASE 
  WHEN FND.MATCH_FIRE_COUNTER_PRTY_TYPE = 'OK' AND 
       FND.MATCH_FIRE_CENTRL_COUNTER_PRTY = 'OK' AND 
       FND.MATCH_FIRE_ENTITY_CD = 'OK'  AND 
       FND.MATCH_FIRE_CONSOLID_LVL = 'OK'  AND 
       FND.MATCH_KPMG_COUNTER_PRTY = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_FI_REPORTING, 
  
  FND.SRC_FIRE_COUNTER_PRTY_TYPE,
  FND.TRG_FIRE_COUNTER_PRTY_TYPE,
  FND.MATCH_FIRE_COUNTER_PRTY_TYPE,
  FND.SRC_FIRE_CENTRL_COUNTER_PRTY,
  FND.TRG_FIRE_CENTRL_COUNTER_PRTY,
  FND.MATCH_FIRE_CENTRL_COUNTER_PRTY,
  FND.SRC_FIRE_ENTITY_CD,
  FND.TRG_FIRE_ENTITY_CD,
  FND.MATCH_FIRE_ENTITY_CD,
  FND.SRC_FIRE_CONSOLID_LVL,
  FND.TRG_FIRE_CONSOLID_LVL,
  FND.MATCH_FIRE_CONSOLID_LVL,
  FND.SRC_KPMG_COUNTER_PRTY,
  FND.TRG_KPMG_COUNTER_PRTY,
  FND.MATCH_KPMG_COUNTER_PRTY,

  CASE 
  WHEN FND.MATCH_PRSN_REL_CNT = 'OK' AND
       FND.MATCH_PRSN_REL_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_PERSON_RELATION, 
  
  FND.SRC_PRSN_REL_CNT,
  FND.TRG_PRSN_REL_CNT,
  FND.MATCH_PRSN_REL_CNT,
  FND.SRC_PRSN_REL_LST,
  FND.TRG_PRSN_REL_LST,
  FND.MATCH_PRSN_REL_LST,
  
  CASE 
  WHEN FND.MATCH_STDG_INSTR_CNT = 'OK' AND 
       FND.MATCH_STDG_INSTR_LST = 'OK' 
  THEN 'OK'
  ELSE 'NOK'
  END AS CUM_MATCH_STANDING_INSTRUCT, 
  
  FND.SRC_STDG_INSTR_CNT,
  FND.TRG_STDG_INSTR_CNT,
  FND.MATCH_STDG_INSTR_CNT,
  FND.SRC_STDG_INSTR_LST,
  FND.TRG_STDG_INSTR_LST,
  FND.MATCH_STDG_INSTR_LST,
  
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_BP_TMN_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
  ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

