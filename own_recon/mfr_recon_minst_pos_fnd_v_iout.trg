CREATE OR REPLACE TRIGGER MFR_RECON_MINST_POS_FND_V_IOUT  -- NOTE: missing R in MINSTR name due to name length limit
INSTEAD OF UPDATE ON MFR_RECON_MINSTR_POS_FND_V
FOR EACH ROW 
  BEGIN  
    UPDATE MFC_MI_POS_FND_V
       SET STD_FND_COMMENT = :new.STD_FND_COMMENT,
       	   STD_FND_SIGN_OFF_FG = :new.STD_FND_SIGN_OFF_FG,
       	   STD_FND_BUG_FIX_ITIL_NO = :new.STD_FND_BUG_FIX_ITIL_NO
     WHERE FND_ID = :old.FND_ID;   
  END;
/

