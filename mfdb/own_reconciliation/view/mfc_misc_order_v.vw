CREATE OR REPLACE FORCE VIEW MFC_MISC_ORDER_V AS
SELECT order_id, bank_location_code, inspect_order, expected_result
     FROM mfc_misc_order;
grant select, insert, update, delete on MFC_MISC_ORDER_V to OWN_RECON;
grant select on MFC_MISC_ORDER_V to USR_LOGGING;
grant select, insert, update, delete on MFC_MISC_ORDER_V to USR_RECONCILIATION;


