CREATE OR REPLACE FORCE VIEW MFR_RECON_SCOPE_V
(recon_scope_type, recon_scope_group, recon_scope_name, recon_scope_descr, recon_scope_rb_visible_fg)
AS
SELECT 
  RCN_SCOPE_TYP,
  RCN_SCOPE_GROUP,
  RCN_SCOPE_NAME,
  RCN_SCOPE_DESCR,
  RCN_SCOPE_RB_VISIBLE_FG
FROM MFC_RCN_SCP_V;

