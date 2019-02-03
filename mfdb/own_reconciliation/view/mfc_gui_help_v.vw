CREATE OR REPLACE FORCE VIEW MFC_GUI_HELP_V AS
SELECT 
  LANGUAGE_CD,
  TERM_NM,
  TERM_MEANING
FROM MFC_GUI_HELP;
grant select, insert, update, delete on MFC_GUI_HELP_V to OWN_RECON;
grant select, insert, update, delete on MFC_GUI_HELP_V to USR_RECONCILIATION;


