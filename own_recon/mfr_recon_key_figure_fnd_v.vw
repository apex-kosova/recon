CREATE OR REPLACE FORCE VIEW MFR_RECON_KEY_FIGURE_FND_V
(fnd_id, acs_asset_sum, acs_liability_sum, acs_mortgage_claim_sum, acs_ebank_contract_cnt, migr_run_id, rcn_prcs_id, rcn_prgm_name, rcn_scope_type)
AS
SELECT 
  FND.FND_ID, 
	FND.ACS_ASSET_SUM, 
	FND.ACS_LIABILITY_SUM, 
	FND.ACS_MORTGAGE_CLAIM_SUM, 
	FND.ACS_EBANK_CONTRACT_CNT, 
	FND.MIGR_RUN_ID, 
	FND.RCN_PRCS_ID,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP
FROM MFC_KF_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS 
	ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

