CREATE OR REPLACE FORCE VIEW MFR_RUN_CHAIN_V
(bank_run_id, member_run_id)
AS
SELECT 
  MFL_MIGR_RUN_BNK_RUN_ID,
  MFL_MIGR_RUN_MBR_RUN_ID
FROM MFL_RUN_CHAIN_V;

