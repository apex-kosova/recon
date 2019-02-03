CREATE OR REPLACE FORCE VIEW MFC_CLIENT_SAMPLE_V AS
SELECT smpl_id, bank_location_code, client_id, client_subject_cd, client_comment
     FROM mfc_client_sample;
grant select, insert, update, delete on MFC_CLIENT_SAMPLE_V to OWN_RECON;
grant select on MFC_CLIENT_SAMPLE_V to USR_LOGGING;
grant select, insert, update, delete on MFC_CLIENT_SAMPLE_V to USR_RECONCILIATION;


