CREATE OR REPLACE FORCE VIEW MFC_RCN_PRGM_V AS
SELECT rcn_prgm_name, system_role, prgm_type
     FROM mfc_rcn_prgm;
grant select on MFC_RCN_PRGM_V to OWN_RECON;
grant select on MFC_RCN_PRGM_V to USR_LOGGING;
grant select on MFC_RCN_PRGM_V to USR_RECONCILIATION;


