CREATE OR REPLACE FORCE VIEW MFC_MO_FND_V AS
SELECT fnd_id, order_result_fg, itil_ticket_if_failed, order_comment, order_check_by, order_check_dt, migr_run_id, order_id, rcn_prcs_id
     FROM mfc_mo_fnd;
grant select, update on MFC_MO_FND_V to OWN_RECON;
grant select, insert, delete on MFC_MO_FND_V to USR_LOGGING;
grant select, insert, update on MFC_MO_FND_V to USR_RECONCILIATION;


