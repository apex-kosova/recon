CREATE OR REPLACE FORCE VIEW MFR_RAIFFEISEN_BANK_V20 AS
SELECT 
  BANK_LOCATION_CODE,
  BANK_NAME,
  BANK_LANGUAGE_CODE,
  BANK_LANGUAGE_NAME,
  BANK_MIGRATION_STATUS,
  BANK_EXEC_PRIO
FROM MFL_RAIFFEISEN_BANK_V20;

