CREATE OR REPLACE FORCE VIEW MFR_RECON_MISC_ORDER_V AS
SELECT 
  ORDER_ID, 
	BANK_LOCATION_CODE, 
	INSPECT_ORDER,
  EXPECTED_RESULT
FROM MFC_MISC_ORDER_V;
