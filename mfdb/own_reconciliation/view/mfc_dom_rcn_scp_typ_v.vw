CREATE OR REPLACE FORCE VIEW MFC_DOM_RCN_SCP_TYP_V AS
SELECT short_name, long_name
     FROM mfc_dom_rcn_scp_typ;
grant select, update on MFC_DOM_RCN_SCP_TYP_V to OWN_RECON;
grant select on MFC_DOM_RCN_SCP_TYP_V to USR_LOGGING;
grant select on MFC_DOM_RCN_SCP_TYP_V to USR_RECONCILIATION;


