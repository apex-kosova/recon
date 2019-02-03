CREATE OR REPLACE FORCE VIEW MFC_SCP_GRP_CLMN_V AS
SELECT rcn_scope_group, rcn_scope_typ, order_no, clmn_base_nm, clmn_d2k_nm, clmn_ar_nm, clmn_avr_nm, clmn_acs_nm, clmn_chk_fg
     FROM mfc_scp_grp_clmn;
grant select on MFC_SCP_GRP_CLMN_V to OWN_RECON;
grant select on MFC_SCP_GRP_CLMN_V to USR_LOGGING;
grant select on MFC_SCP_GRP_CLMN_V to USR_RECONCILIATION;


