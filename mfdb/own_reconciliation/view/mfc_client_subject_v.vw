CREATE OR REPLACE FORCE VIEW MFC_CLIENT_SUBJECT_V AS
SELECT language_cd, client_subject_cd, client_subject_nm
     FROM mfc_client_subject;
grant select on MFC_CLIENT_SUBJECT_V to OWN_RECON;
grant select on MFC_CLIENT_SUBJECT_V to USR_LOGGING;
grant select on MFC_CLIENT_SUBJECT_V to USR_RECONCILIATION;


