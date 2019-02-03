CREATE OR REPLACE FORCE VIEW MFC_DOM_RCN_PRCS_TYP_V AS
SELECT short_name, long_name
     FROM mfc_dom_rcn_prcs_typ;
grant select on MFC_DOM_RCN_PRCS_TYP_V to OWN_RECON;
grant select on MFC_DOM_RCN_PRCS_TYP_V to USR_LOGGING;
grant select on MFC_DOM_RCN_PRCS_TYP_V to USR_RECONCILIATION;


