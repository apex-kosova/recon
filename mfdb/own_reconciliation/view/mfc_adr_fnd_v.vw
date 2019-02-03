CREATE OR REPLACE FORCE VIEW MFC_ADR_FND_V AS
SELECT 
  FND_ID, 
  STD_FND_COMMENT, 
  STD_FND_MIGR_ERROR, 
  STD_FND_SIGN_OFF_FG, 
  STD_FND_BUG_FIX_ITIL_NO, 
  MIGR_RUN_ID, 
  RCN_PRCS_ID,
  ADR_KEY, 
  SRC_CLIENT_ID,
  TRG_CLIENT_ID,
  MATCH_CLIENT_ID,
  SRC_CLIENT_LAST_NM,
  TRG_CLIENT_LAST_NM,
  MATCH_CLIENT_LAST_NM,
  SRC_CLIENT_FIRST_NM,
  TRG_CLIENT_FIRST_NM,
  MATCH_CLIENT_FIRST_NM,
  SRC_CLIENT_CMPNY_NM,
  TRG_CLIENT_CMPNY_NM,
  MATCH_CLIENT_CMPNY_NM,
  SRC_ADR_STREET_NM,
  TRG_ADR_STREET_NM,
  MATCH_ADR_STREET_NM,
  SRC_ADR_CITY_NM,
  TRG_ADR_CITY_NM,
  MATCH_ADR_CITY_NM,
  SRC_ADR_ZIP_CD,
  TRG_ADR_ZIP_CD,
  MATCH_ADR_ZIP_CD,
  SRC_ADR_CNTRY_CD,
  TRG_ADR_CNTRY_CD,
  MATCH_ADR_CNTRY_CD,
  SRC_ADR_FULL_STRING,
  TRG_ADR_FULL_STRING,
  MATCH_ADR_FULL_STRING,
  INHERIT_FND_ID,
  INHERIT_RUN_RANK
FROM MFC_ADR_FND;
grant select, update on MFC_ADR_FND_V to OWN_RECON;
grant select, insert, update, delete on MFC_ADR_FND_V to USR_LOGGING;
grant select, insert, update on MFC_ADR_FND_V to USR_RECONCILIATION;

