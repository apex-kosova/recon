CREATE OR REPLACE FORCE VIEW MFC_DOM_RCN_SCP_GRP_V AS
SELECT short_name, long_name
     FROM mfc_dom_rcn_scp_grp;
grant select on MFC_DOM_RCN_SCP_GRP_V to OWN_RECON;
grant select on MFC_DOM_RCN_SCP_GRP_V to USR_LOGGING;
grant select on MFC_DOM_RCN_SCP_GRP_V to USR_RECONCILIATION;


