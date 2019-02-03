CREATE OR REPLACE TRIGGER MFC_MI_POS_FND_V_IOIT
INSTEAD OF INSERT ON MFC_MI_POS_FND_V
FOR EACH ROW 
DECLARE
  l_pred_run_id           INTEGER;
  l_pred_run_rank         INTEGER;
  l_pred_fnd_id           INTEGER;
  l_inherit               VARCHAR2(10 CHAR);
  l_fnd_comment           VARCHAR2(1000 CHAR) := :new.STD_FND_COMMENT;           -- NULL on insert
  l_fnd_sign_off_fg       CHAR(1 BYTE)        := :new.STD_FND_SIGN_OFF_FG;       -- NULL on insert
  l_fnd_bug_fix_itil_no   VARCHAR2(25 CHAR)   := :new.STD_FND_BUG_FIX_ITIL_NO;   -- NULL on insert
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
      ( NVL(:new.STD_FND_MIGR_ERROR, 'NULL'), 
        :new.MATCH_MINSTR
      ) IN 
      ( SELECT 
          NVL(STD_FND_MIGR_ERROR, 'NULL'), 
          MATCH_MINSTR
        FROM MFC_MI_POS_FND 
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND NVL(SRC_ADR_KEY, 'NULL') = NVL(:new.SRC_ADR_KEY, 'NULL')
          AND NVL(SRC_BP_KEY, 'NULL') = NVL(:new.SRC_BP_KEY, 'NULL')
          AND NVL(SRC_CTN_KEY, 'NULL') = NVL(:new.SRC_CTN_KEY, 'NULL')
          AND NVL(SRC_MACC_KEY, 'NULL') = NVL(:new.SRC_MACC_KEY, 'NULL')
          AND NVL(SRC_MINSTR_TMPL, 'NULL') = NVL(:new.SRC_MINSTR_TMPL, 'NULL')
          AND NVL(SRC_MAIL_ACTION, 'NULL') = NVL(:new.SRC_MAIL_ACTION, 'NULL')
          AND NVL(SRC_SMP_KEY, 'NULL') = NVL(:new.SRC_SMP_KEY, 'NULL')
          AND NVL(TRG_ADR_KEY, 'NULL') = NVL(:new.TRG_ADR_KEY, 'NULL')
          AND NVL(TRG_BP_KEY, 'NULL') = NVL(:new.TRG_BP_KEY, 'NULL')
          AND NVL(TRG_CTN_KEY, 'NULL') = NVL(:new.TRG_CTN_KEY, 'NULL')
          AND NVL(TRG_MACC_KEY, 'NULL') = NVL(:new.TRG_MACC_KEY, 'NULL')
          AND NVL(TRG_MINSTR_TMPL, 'NULL') = NVL(:new.TRG_MINSTR_TMPL, 'NULL')
          AND NVL(TRG_MAIL_ACTION, 'NULL') = NVL(:new.TRG_MAIL_ACTION, 'NULL')
          AND NVL(TRG_SMP_KEY, 'NULL') = NVL(:new.TRG_SMP_KEY, 'NULL')
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
      BEGIN 
        SELECT FND_ID, STD_FND_COMMENT, STD_FND_SIGN_OFF_FG, STD_FND_BUG_FIX_ITIL_NO, INHERIT_FND_ID, INHERIT_RUN_RANK
        INTO l_pred_fnd_id, l_fnd_comment, l_fnd_sign_off_fg, l_fnd_bug_fix_itil_no, l_root_fnd_id, l_root_run_rank
        FROM MFC_MI_POS_FND
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND NVL(SRC_ADR_KEY, 'NULL') = NVL(:new.SRC_ADR_KEY, 'NULL')
          AND NVL(SRC_BP_KEY, 'NULL') = NVL(:new.SRC_BP_KEY, 'NULL')
          AND NVL(SRC_CTN_KEY, 'NULL') = NVL(:new.SRC_CTN_KEY, 'NULL')
          AND NVL(SRC_MACC_KEY, 'NULL') = NVL(:new.SRC_MACC_KEY, 'NULL')
          AND NVL(SRC_MINSTR_TMPL, 'NULL') = NVL(:new.SRC_MINSTR_TMPL, 'NULL')
          AND NVL(SRC_MAIL_ACTION, 'NULL') = NVL(:new.SRC_MAIL_ACTION, 'NULL')
          AND NVL(SRC_SMP_KEY, 'NULL') = NVL(:new.SRC_SMP_KEY, 'NULL')
          AND NVL(TRG_ADR_KEY, 'NULL') = NVL(:new.TRG_ADR_KEY, 'NULL')
          AND NVL(TRG_BP_KEY, 'NULL') = NVL(:new.TRG_BP_KEY, 'NULL')
          AND NVL(TRG_CTN_KEY, 'NULL') = NVL(:new.TRG_CTN_KEY, 'NULL')
          AND NVL(TRG_MACC_KEY, 'NULL') = NVL(:new.TRG_MACC_KEY, 'NULL')
          AND NVL(TRG_MINSTR_TMPL, 'NULL') = NVL(:new.TRG_MINSTR_TMPL, 'NULL')
          AND NVL(TRG_MAIL_ACTION, 'NULL') = NVL(:new.TRG_MAIL_ACTION, 'NULL')
          AND NVL(TRG_SMP_KEY, 'NULL') = NVL(:new.TRG_SMP_KEY, 'NULL')
        ;
        EXCEPTION 
          WHEN NO_DATA_FOUND THEN  -- handles missing predecessor that has been detected just before -- should not happen
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20501, 'Detected RECON finding predecessor missing !   '||SQLERRM);
          WHEN TOO_MANY_ROWS THEN  -- handles duplicate errors from previous RECON run
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20501, 'Find RECON finding predecessor failed - duplicates detected !   '||SQLERRM);
          WHEN OTHERS THEN         -- handles all other errors
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20501, 'Find RECON finding predecessor failed !   '||SQLERRM);
      END;
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

	INSERT INTO MFC_MI_POS_FND
  ( FND_ID, 
    STD_FND_COMMENT, 
    STD_FND_MIGR_ERROR, 
    STD_FND_SIGN_OFF_FG, 
    STD_FND_BUG_FIX_ITIL_NO,
    MIGR_RUN_ID, 
    SRC_ADR_KEY,
    SRC_BP_KEY,
    SRC_CTN_KEY,
    SRC_MACC_KEY,
    SRC_MINSTR_TMPL,
    SRC_MAIL_ACTION,
    SRC_SMP_KEY,
    MATCH_MINSTR,
    TRG_ADR_KEY,
    TRG_BP_KEY,
    TRG_CTN_KEY,
    TRG_MACC_KEY,
    TRG_MINSTR_TMPL,
    TRG_MAIL_ACTION,
    TRG_SMP_KEY,
    RCN_PRCS_ID, 
    INHERIT_FND_ID,
    INHERIT_RUN_RANK
  ) VALUES 
  ( MFC_RCN_FND_FND_ID_SEQ.NEXTVAL, 
    l_fnd_comment,                       -- may get inherited comment rating
    :new.STD_FND_MIGR_ERROR, 
    l_fnd_sign_off_fg,                   -- may get inherited sign off flag rating
    l_fnd_bug_fix_itil_no,               -- may get inherited ITIL no of bug fix request rating
    :new.MIGR_RUN_ID, 
    :new.SRC_ADR_KEY,
    :new.SRC_BP_KEY,
    :new.SRC_CTN_KEY,
    :new.SRC_MACC_KEY,
    :new.SRC_MINSTR_TMPL,
    :new.SRC_MAIL_ACTION,
    :new.SRC_SMP_KEY,
    :new.MATCH_MINSTR,
    :new.TRG_ADR_KEY,
    :new.TRG_BP_KEY,
    :new.TRG_CTN_KEY,
    :new.TRG_MACC_KEY,
    :new.TRG_MINSTR_TMPL,
    :new.TRG_MAIL_ACTION,
    :new.TRG_SMP_KEY,
    :new.RCN_PRCS_ID, 
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

