CREATE OR REPLACE FORCE VIEW MFC_LDG_ERR_VAL_V AS
SELECT acs_ldg_acc_key, err_val_abs_d2k, err_val_pct_d2k, err_val_type
     FROM mfc_ldg_err_val;
grant select on MFC_LDG_ERR_VAL_V to OWN_RECON;
grant select on MFC_LDG_ERR_VAL_V to USR_LOGGING;
grant select on MFC_LDG_ERR_VAL_V to USR_RECONCILIATION;


