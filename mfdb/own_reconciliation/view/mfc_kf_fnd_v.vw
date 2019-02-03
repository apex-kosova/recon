CREATE OR REPLACE FORCE VIEW MFC_KF_FND_V AS
SELECT fnd_id, acs_asset_sum, acs_liability_sum, acs_mortgage_claim_sum, acs_ebank_contract_cnt, migr_run_id, rcn_prcs_id
     FROM mfc_kf_fnd;
grant select on MFC_KF_FND_V to OWN_RECON;
grant select, insert, delete on MFC_KF_FND_V to USR_LOGGING;
grant select, insert on MFC_KF_FND_V to USR_RECONCILIATION;


