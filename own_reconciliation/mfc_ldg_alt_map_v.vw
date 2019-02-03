CREATE OR REPLACE FORCE VIEW MFC_LDG_ALT_MAP_V AS
SELECT D2K_LDG_ACC_KEY, ACS_LDG_ACC_KEY, ACS_LDG_GRP_NM
     FROM MFC_LDG_ALT_MAP;
grant select on MFC_LDG_ALT_MAP_V to OWN_RECON;
grant select on MFC_LDG_ALT_MAP_V to USR_LOGGING;
grant select on MFC_LDG_ALT_MAP_V to USR_RECONCILIATION;


