CREATE OR REPLACE PACKAGE mfc_recon_purge AS


  PROCEDURE purge_recon_migr_run
  ( v_migr_run_id IN INTEGER
  ) ;
  -- executes full purge of reconciliation associated with a migration run 
  -- removes recon processes and associated recon findings of migration run 

  PROCEDURE purge_recon_orphan_mr ;
  -- executes full purge of reconciliation associated with all migration runs that became orphans (migration run disappears in log DB)
  -- removes recon processes and associated findings of all orphan migration run 

END mfc_recon_purge;
/

