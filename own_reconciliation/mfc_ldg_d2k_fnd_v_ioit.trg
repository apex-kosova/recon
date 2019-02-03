CREATE OR REPLACE TRIGGER MFC_LDG_D2K_FND_V_IOIT
INSTEAD OF INSERT ON MFC_LDG_D2K_FND_V
FOR EACH ROW 
DECLARE
  l_pred_run_id           INTEGER;
  l_pred_run_rank         INTEGER;
  l_pred_fnd_id           INTEGER;
  l_inherit               VARCHAR2(10 CHAR);
  l_fnd_comment           VARCHAR2(1000 CHAR) := :new.LDG_FND_COMMENT;           -- NULL on insert
  l_fnd_sign_off_fg       CHAR(1 BYTE)        := :new.LDG_FND_SIGN_OFF_FG;       -- NULL on insert
  l_fnd_bug_fix_itil_no   VARCHAR2(25 CHAR)   := :new.LDG_FND_BUG_FIX_ITIL_NO;   -- NULL on insert
  l_root_fnd_id           INTEGER;
  l_root_run_rank         INTEGER;

BEGIN  
  -- get last closed recon run predecessor, if available
  BEGIN
    WITH RUN_RANK
    AS
    ( SELECT 
        RCN_RUN.RUN_ID RECON_RUN, 
        SBLG_RUN.RUN_ID SIBLING_RECON_RUN,
        DENSE_RANK() OVER (PARTITION BY RCN_RUN.RUN_ID ORDER BY SBLG_RUN.RUN_ID) DRANK
      FROM MFL_MIGR_RUN_V23 RCN_RUN 
      JOIN MFL_RUN_CHAIN_V PRNT
        ON RCN_RUN.RUN_ID = PRNT.MFL_MIGR_RUN_MBR_RUN_ID
      JOIN MFL_MIGR_RUN_V23 MIGR_RUN 
        ON PRNT.MFL_MIGR_RUN_BNK_RUN_ID = MIGR_RUN.RUN_ID 
      JOIN MFL_RUN_CHAIN_V CHLD
        ON MIGR_RUN.RUN_ID = CHLD.MFL_MIGR_RUN_BNK_RUN_ID
      JOIN MFL_MIGR_RUN_V23 SBLG_RUN 
        ON CHLD.MFL_MIGR_RUN_MBR_RUN_ID = SBLG_RUN.RUN_ID 
      WHERE RCN_RUN.WFT_NAME = SBLG_RUN.WFT_NAME 
        AND SBLG_RUN.RUN_STATUS = 'cls'
    )  
    SELECT MAX(RNK.SIBLING_RECON_RUN), MAX(RNK.DRANK)
    INTO l_pred_run_id, l_pred_run_rank
    FROM RUN_RANK RNK
    JOIN MFL_MIGR_RUN_V23 RUN
      ON RNK.RECON_RUN = RUN.RUN_ID
    WHERE RNK.RECON_RUN = :new.MIGR_RUN_ID 
      AND RNK.SIBLING_RECON_RUN < RNK.RECON_RUN 
    GROUP BY RNK.RECON_RUN
    ;
    --DBMS_OUTPUT.PUT_LINE('RECON RUN_ID : '||:new.MIGR_RUN_ID);
    --DBMS_OUTPUT.PUT_LINE('PREDECESSOR RUN_ID : '||l_pred_run_id);
    --DBMS_OUTPUT.PUT_LINE('PREDECESSOR RANK : '||l_pred_run_rank);

  EXCEPTION 
    WHEN NO_DATA_FOUND THEN  -- catch up if no predecessor recon run exists 
      NULL; 
      --DBMS_OUTPUT.PUT_LINE('RECON RUN_ID : '||:new.MIGR_RUN_ID);
      --DBMS_OUTPUT.PUT_LINE('PREDECESSOR RUN_ID : '||l_pred_run_id);
      --DBMS_OUTPUT.PUT_LINE('PREDECESSOR RANK : '||l_pred_run_rank);

    WHEN OTHERS THEN  -- handles all other errors
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20501, 'Find RECON run predecessor failed !   '||SQLERRM);
  END;

  IF l_pred_run_id IS NOT NULL
  THEN -- check for finding in predecessor recon run 
    BEGIN 
      SELECT 'INHERITED'
      INTO l_inherit
      FROM DUAL
      WHERE 
      ( NVL(:new.LDG_ACC_NAME, 'NULL'), NVL(TO_CHAR(:new.PRICE_PER_UNIT), 'NULL'),
        :new.ACC_CURR_CD, TO_CHAR(:new.ACC_AMOUNT),
        NVL(TO_CHAR(:new.EXCH_RATE), 'NULL'), NVL(TO_CHAR(:new.ACC_AMOUNT_CHF), 'NULL'), 
        :new.MATCH_ACC_AMOUNT_CHF,
        NVL(:new.MAP_D2K_LDG_ACC_KEY, 'NULL'), NVL(:new.MAP_ACS_LDG_ACC_KEY, 'NULL'),
        'MFCLFD'
      ) IN 
      ( SELECT 
          NVL(LDG_ACC_NAME, 'NULL'), NVL(TO_CHAR(PRICE_PER_UNIT), 'NULL'),
          ACC_CURR_CD, TO_CHAR(ACC_AMOUNT),
          NVL(TO_CHAR(EXCH_RATE), 'NULL'), NVL(TO_CHAR(ACC_AMOUNT_CHF), 'NULL'), 
          MATCH_ACC_AMOUNT_CHF,
          NVL(MAP_D2K_LDG_ACC_KEY, 'NULL'), NVL(MAP_ACS_LDG_ACC_KEY, 'NULL'),
          LDG_FND_TYPE
        FROM MFC_LDG_FND 
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND LDG_ACC_KEY = :NEW.LDG_ACC_KEY
      )
      ;
      EXCEPTION 
        WHEN NO_DATA_FOUND THEN  -- catch up if predecessor recon finding is not equal
          NULL;                  -- proceed with no equal predecessor finding 
        WHEN OTHERS THEN         -- handles all other errors
          ROLLBACK;
          RAISE_APPLICATION_ERROR(-20501, 'Find RECON finding predecessor failed !   '||SQLERRM);
    END;

    IF l_inherit = 'INHERITED' 
    THEN -- get rating
      SELECT FND_ID, LDG_FND_COMMENT, LDG_FND_SIGN_OFF_FG, LDG_FND_BUG_FIX_ITIL_NO, INHERIT_FND_ID, INHERIT_RUN_RANK
      INTO l_pred_fnd_id, l_fnd_comment, l_fnd_sign_off_fg, l_fnd_bug_fix_itil_no, l_root_fnd_id, l_root_run_rank
      FROM MFC_LDG_FND
      WHERE MIGR_RUN_ID = l_pred_run_id
        AND LDG_ACC_KEY = :NEW.LDG_ACC_KEY
      ;
      IF l_root_fnd_id IS NULL AND l_root_run_rank IS NULL
      THEN 
        l_root_fnd_id := l_pred_fnd_id;
        l_root_run_rank := l_pred_run_rank;
      END IF; 
    END IF; 

  END IF;
  --DBMS_OUTPUT.PUT_LINE('Predecessor finding exists : '||l_inherit);
  --DBMS_OUTPUT.PUT_LINE('Predecessor finding id : '||l_pred_fnd_id);
  --DBMS_OUTPUT.PUT_LINE('Predecessor finding comment : '||l_fnd_comment);
  --DBMS_OUTPUT.PUT_LINE('Predecessor finding sign off flag : '||l_fnd_sign_off_fg);
  --DBMS_OUTPUT.PUT_LINE('Predecessor finding bug fix ITIL no : '||l_fnd_bug_fix_itil_no);
  --DBMS_OUTPUT.PUT_LINE('Root finding id : '||l_root_fnd_id);
  --DBMS_OUTPUT.PUT_LINE('Root recon run rank : '||l_root_run_rank);

  -- finally the insert      

  INSERT INTO MFC_LDG_FND
  ( FND_ID,
    LDG_ACC_KEY,
    LDG_ACC_NAME,
    PRICE_PER_UNIT,
    ACC_CURR_CD,
    ACC_AMOUNT,
    EXCH_RATE,
    ACC_AMOUNT_CHF,
    LDG_FND_COMMENT,
    LDG_FND_SIGN_OFF_FG, 
    LDG_FND_BUG_FIX_ITIL_NO,
    MATCH_ACC_AMOUNT_CHF,
    MIGR_RUN_ID,
    RCN_PRCS_ID,
    MAP_D2K_LDG_ACC_KEY,
    MAP_ACS_LDG_ACC_KEY,
    D2K_CUM_CNT,
    D2K_CUM_ACC_AMOUNT,
    D2K_CUM_ACC_AMOUNT_CHF,
    LDG_FND_TYPE,
    INHERIT_FND_ID,
    INHERIT_RUN_RANK
  ) VALUES 
  ( MFC_RCN_FND_FND_ID_SEQ.NEXTVAL, 
    :new.LDG_ACC_KEY,
    :new.LDG_ACC_NAME,
    :new.PRICE_PER_UNIT,
    :new.ACC_CURR_CD,
    :new.ACC_AMOUNT,
    :new.EXCH_RATE,
    :new.ACC_AMOUNT_CHF,
    l_fnd_comment,                       -- may get inherited comment rating
    l_fnd_sign_off_fg,                   -- may get inherited sign off flag rating
    l_fnd_bug_fix_itil_no,               -- may get inherited ITIL no of bug fix request rating
    :new.MATCH_ACC_AMOUNT_CHF,
    :new.MIGR_RUN_ID,
    :new.RCN_PRCS_ID,
    :new.MAP_D2K_LDG_ACC_KEY,
    :new.MAP_ACS_LDG_ACC_KEY,
    NULL,
    NULL,
    NULL,
    'MFCLFD',
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

