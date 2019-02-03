CREATE OR REPLACE TRIGGER MFC_POS_TMN_FND_V_IOUT
INSTEAD OF UPDATE ON MFC_POS_TMN_FND_V
FOR EACH ROW 
  BEGIN  
    UPDATE MFC_POS_TMN_FND
       SET POS_FND_COMMENT = :new.POS_FND_COMMENT,
           POS_FND_SIGN_OFF_FG = :new.POS_FND_SIGN_OFF_FG,
           POS_FND_BUG_FIX_ITIL_NO = :new.POS_FND_BUG_FIX_ITIL_NO,
           INHERIT_FND_ID = NULL,   -- reset fnd_id of inheritance because rating is modified here in successor finding
           INHERIT_RUN_RANK = NULL  -- reset run_rank of inheritance because rating is modified here in successor finding
     WHERE FND_ID = :old.FND_ID;   

    IF :old.POS_FND_COMMENT IS NULL AND :new.POS_FND_COMMENT IS NOT NULL 
    THEN 
      UPDATE MFC_RCN_PRCS
         SET RCN_NO_CMNT_CNT = RCN_NO_CMNT_CNT - 1 
       WHERE RCN_PRCS_ID = :old.RCN_PRCS_ID; 
    ELSIF :old.POS_FND_COMMENT IS NOT NULL AND :new.POS_FND_COMMENT IS NULL 
    THEN 
      UPDATE MFC_RCN_PRCS
         SET RCN_NO_CMNT_CNT = RCN_NO_CMNT_CNT + 1 
       WHERE RCN_PRCS_ID = :old.RCN_PRCS_ID; 
    END IF;
  END;
/

