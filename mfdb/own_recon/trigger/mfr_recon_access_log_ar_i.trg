CREATE OR REPLACE TRIGGER mfr_recon_access_log_ar_i
   AFTER INSERT ON recon_access_log 
   FOR EACH ROW
BEGIN
   mfl_access_log_api.print(
      i_user_name        => :new.user_name,
      i_access_date      => :new.access_date,
      i_application_name => 'RECON'
   );
END mfr_recon_access_log_ar_i;
/

