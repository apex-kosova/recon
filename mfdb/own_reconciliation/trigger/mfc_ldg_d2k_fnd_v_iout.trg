CREATE OR REPLACE TRIGGER MFC_LDG_D2K_FND_V_IOUT
INSTEAD OF UPDATE ON MFC_LDG_D2K_FND_V
FOR EACH ROW 
BEGIN  
  UPDATE MFC_LDG_FND
     SET LDG_FND_COMMENT = :new.LDG_FND_COMMENT,
         LDG_FND_SIGN_OFF_FG = :new.LDG_FND_SIGN_OFF_FG, 
         LDG_FND_BUG_FIX_ITIL_NO = :new.LDG_FND_BUG_FIX_ITIL_NO,
         INHERIT_FND_ID = NULL,   -- reset fnd_id of inheritance because rating is modified here in successor finding
         INHERIT_RUN_RANK = NULL  -- reset run_rank of inheritance because rating is modified here in successor finding
   WHERE FND_ID = :old.FND_ID;   

  IF :old.LDG_FND_COMMENT IS NULL AND :new.LDG_FND_COMMENT IS NOT NULL 
  THEN 
    UPDATE MFC_RCN_PRCS
       SET RCN_NO_CMNT_CNT = RCN_NO_CMNT_CNT - 1 
     WHERE RCN_PRCS_ID = :old.RCN_PRCS_ID; 
  ELSIF :old.LDG_FND_COMMENT IS NOT NULL AND :new.LDG_FND_COMMENT IS NULL 
  THEN 
    UPDATE MFC_RCN_PRCS
       SET RCN_NO_CMNT_CNT = RCN_NO_CMNT_CNT + 1 
     WHERE RCN_PRCS_ID = :old.RCN_PRCS_ID; 
  END IF;
END;
/

