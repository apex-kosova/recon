CREATE OR REPLACE FORCE VIEW MFC_DOM_LDG_ERR_VAL_TYP_V AS
SELECT short_name, long_name
     FROM mfc_dom_ldg_err_val_typ;
grant select on MFC_DOM_LDG_ERR_VAL_TYP_V to OWN_RECON;
grant select on MFC_DOM_LDG_ERR_VAL_TYP_V to USR_LOGGING;
grant select on MFC_DOM_LDG_ERR_VAL_TYP_V to USR_RECONCILIATION;


