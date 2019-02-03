CREATE OR REPLACE FORCE VIEW MFC_ZP_FND_V AS
SELECT fnd_id, proof_result_fg, itil_ticket_if_failed, proof_comment, proof_check_by, proof_check_dt, migr_run_id, smpl_id, rcn_prcs_id
     FROM mfc_zp_fnd;
grant select, update on MFC_ZP_FND_V to OWN_RECON;
grant select, insert, delete on MFC_ZP_FND_V to USR_LOGGING;
grant select, insert, update on MFC_ZP_FND_V to USR_RECONCILIATION;


