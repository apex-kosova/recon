CREATE OR REPLACE PACKAGE BODY mfc_recon_purge AS


  PROCEDURE purge_recon_migr_run
  ( v_migr_run_id IN INTEGER
  ) IS
        
  BEGIN
  	
    DELETE FROM MFC_ADR_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_ADR_TMN_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_BP_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_BP_POS_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_BP_TMN_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_CTN_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_CTN_TMN_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_MACC_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_MACC_TMN_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_MI_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_MI_POS_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_PSN_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;
 
    DELETE FROM MFC_PSN_TMN_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;
 
    DELETE FROM MFC_POS_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_POS_TMN_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_LDG_D2K_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_LDG_ACS_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_LDG_ALT_D2K_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_LDG_ALT_ACS_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_KF_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_ZP_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_MO_FND_V 
     WHERE RCN_PRCS_ID IN (SELECT RCN_PRCS_ID 
                             FROM MFC_RCN_PRCS_V 
                            WHERE MIGR_RUN_ID = v_migr_run_id) ;

    DELETE FROM MFC_RCN_PRCS_V 
     WHERE MIGR_RUN_ID = v_migr_run_id;

    COMMIT;
  	
  END purge_recon_migr_run;


  PROCEDURE purge_recon_orphan_mr
  IS
  
    CURSOR c_purge_migr_run_lst IS 
    SELECT DISTINCT PRCS.MIGR_RUN_ID
      FROM MFC_RCN_PRCS PRCS
     WHERE NOT EXISTS	(	SELECT RUN.RUN_ID
      										FROM MFL_MIGR_RUN_V23 RUN
      									 WHERE RUN.RUN_ID = PRCS.MIGR_RUN_ID
      									);
  BEGIN
  	
    FOR purge_migr_run_rec in c_purge_migr_run_lst 
    LOOP
      -- purge recon data for single orphaned migration run 
      purge_recon_migr_run( purge_migr_run_rec.migr_run_id );
    END LOOP;   
  	
  END purge_recon_orphan_mr;

END mfc_recon_purge;
/

