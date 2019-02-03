CREATE OR REPLACE TRIGGER MFC_MACC_FND_V_IOIT
INSTEAD OF INSERT ON MFC_MACC_FND_V
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
        NVL(:new.SRC_CLIENT_ID, 'NULL'), NVL(:new.TRG_CLIENT_ID, 'NULL'), :new.MATCH_CLIENT_ID, NVL(:new.SRC_ACCNT_ID, 'NULL'), NVL(:new.TRG_ACCNT_ID, 'NULL'), :new.MATCH_ACCNT_ID, 
        NVL(:new.SRC_IBAN, 'NULL'), NVL(:new.TRG_IBAN, 'NULL'), :new.MATCH_IBAN, NVL(:new.SRC_ESR_ID, 'NULL'), NVL(:new.TRG_ESR_ID, 'NULL'), :new.MATCH_ESR_ID, 
        NVL(:new.SRC_CTN_KEY, 'NULL'), NVL(:new.TRG_CTN_KEY, 'NULL'), NVL(:new.SRC_PRODUCT_KEY, 'NULL'), NVL(:new.TRG_PRODUCT_KEY, 'NULL'), :new.MATCH_PRODUCT_KEY, 
        NVL(:new.SRC_PRODUCT_NM, 'NULL'), NVL(:new.TRG_PRODUCT_NM, 'NULL'), NVL(TO_CHAR(:new.SRC_CREATE_DT), 'NULL'), NVL(TO_CHAR(:new.TRG_CREATE_DT), 'NULL'), :new.MATCH_CREATE_DT,  
        NVL(TO_CHAR(:new.SRC_LAST_INTR_RUN_DT), 'NULL'), NVL(TO_CHAR(:new.TRG_LAST_INTR_RUN_DT), 'NULL'), :new.MATCH_LAST_INTR_RUN_DT, NVL(:new.SRC_REF_CURRENCY, 'NULL'), NVL(:new.TRG_REF_CURRENCY, 'NULL'), :new.MATCH_REF_CURRENCY, 
        NVL(:new.SRC_ACCNT_OPENER, 'NULL'), NVL(:new.TRG_ACCNT_OPENER, 'NULL'), :new.MATCH_ACCNT_OPENER, NVL(TO_CHAR(:new.SRC_BLOCK_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_BLOCK_CNT), 'NULL'), :new.MATCH_BLOCK_CNT,  
        NVL(:new.SRC_BLOCK_DETAIL, 'NULL'), NVL(:new.TRG_BLOCK_DETAIL, 'NULL'), :new.MATCH_BLOCK_DETAIL, NVL(TO_CHAR(:new.SRC_SPCL_CNDTN_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SPCL_CNDTN_CNT), 'NULL'), :new.MATCH_SPCL_CNDTN_CNT,  
        NVL(:new.SRC_SPCL_CNDTN_LST, 'NULL'), NVL(:new.TRG_SPCL_CNDTN_LST, 'NULL'), :new.MATCH_SPCL_CNDTN_LST 
      ) IN 
      ( SELECT 
          NVL(STD_FND_MIGR_ERROR, 'NULL'), 
          NVL(SRC_CLIENT_ID, 'NULL'), NVL(TRG_CLIENT_ID, 'NULL'), MATCH_CLIENT_ID, NVL(SRC_ACCNT_ID, 'NULL'), NVL(TRG_ACCNT_ID, 'NULL'), MATCH_ACCNT_ID, 
          NVL(SRC_IBAN, 'NULL'), NVL(TRG_IBAN, 'NULL'), MATCH_IBAN, NVL(SRC_ESR_ID, 'NULL'), NVL(TRG_ESR_ID, 'NULL'), MATCH_ESR_ID, 
          NVL(SRC_CTN_KEY, 'NULL'), NVL(TRG_CTN_KEY, 'NULL'), NVL(SRC_PRODUCT_KEY, 'NULL'), NVL(TRG_PRODUCT_KEY, 'NULL'), MATCH_PRODUCT_KEY, 
          NVL(SRC_PRODUCT_NM, 'NULL'), NVL(TRG_PRODUCT_NM, 'NULL'), NVL(TO_CHAR(SRC_CREATE_DT), 'NULL'), NVL(TO_CHAR(TRG_CREATE_DT), 'NULL'), MATCH_CREATE_DT,  
          NVL(TO_CHAR(SRC_LAST_INTR_RUN_DT), 'NULL'), NVL(TO_CHAR(TRG_LAST_INTR_RUN_DT), 'NULL'), MATCH_LAST_INTR_RUN_DT, NVL(SRC_REF_CURRENCY, 'NULL'), NVL(TRG_REF_CURRENCY, 'NULL'), MATCH_REF_CURRENCY, 
          NVL(SRC_ACCNT_OPENER, 'NULL'), NVL(TRG_ACCNT_OPENER, 'NULL'), MATCH_ACCNT_OPENER, NVL(TO_CHAR(SRC_BLOCK_CNT), 'NULL'), NVL(TO_CHAR(TRG_BLOCK_CNT), 'NULL'), MATCH_BLOCK_CNT,  
          NVL(SRC_BLOCK_DETAIL, 'NULL'), NVL(TRG_BLOCK_DETAIL, 'NULL'), MATCH_BLOCK_DETAIL, NVL(TO_CHAR(SRC_SPCL_CNDTN_CNT), 'NULL'), NVL(TO_CHAR(TRG_SPCL_CNDTN_CNT), 'NULL'), MATCH_SPCL_CNDTN_CNT,  
          NVL(SRC_SPCL_CNDTN_LST, 'NULL'), NVL(TRG_SPCL_CNDTN_LST, 'NULL'), MATCH_SPCL_CNDTN_LST 
        FROM MFC_MACC_FND 
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND MACC_KEY = :new.MACC_KEY
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
      SELECT FND_ID, STD_FND_COMMENT, STD_FND_SIGN_OFF_FG, STD_FND_BUG_FIX_ITIL_NO, INHERIT_FND_ID, INHERIT_RUN_RANK
      INTO l_pred_fnd_id, l_fnd_comment, l_fnd_sign_off_fg, l_fnd_bug_fix_itil_no, l_root_fnd_id, l_root_run_rank
      FROM MFC_MACC_FND
      WHERE MIGR_RUN_ID = l_pred_run_id
        AND MACC_KEY = :new.MACC_KEY
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

	INSERT INTO MFC_MACC_FND
  ( FND_ID, 
    STD_FND_COMMENT, 
    STD_FND_MIGR_ERROR, 
		STD_FND_SIGN_OFF_FG, 
		STD_FND_BUG_FIX_ITIL_NO,
    MIGR_RUN_ID, 
    MACC_KEY, 
    SRC_CLIENT_ID,
    TRG_CLIENT_ID,
    MATCH_CLIENT_ID,
    SRC_ACCNT_ID,
    TRG_ACCNT_ID,
    MATCH_ACCNT_ID,
    SRC_IBAN,
    TRG_IBAN,
    MATCH_IBAN,
    SRC_ESR_ID,
    TRG_ESR_ID,
    MATCH_ESR_ID,
    SRC_CTN_KEY,
    TRG_CTN_KEY,
    SRC_PRODUCT_KEY,
    TRG_PRODUCT_KEY,
    MATCH_PRODUCT_KEY,
    SRC_PRODUCT_NM,
    TRG_PRODUCT_NM,
    SRC_CREATE_DT,
    TRG_CREATE_DT,
    MATCH_CREATE_DT,
    SRC_LAST_INTR_RUN_DT,
    TRG_LAST_INTR_RUN_DT,
    MATCH_LAST_INTR_RUN_DT,
    SRC_REF_CURRENCY,
    TRG_REF_CURRENCY,
    MATCH_REF_CURRENCY,
    SRC_ACCNT_OPENER,
    TRG_ACCNT_OPENER,
    MATCH_ACCNT_OPENER,
    SRC_BLOCK_CNT,
    TRG_BLOCK_CNT,
    MATCH_BLOCK_CNT,
    SRC_BLOCK_DETAIL,
    TRG_BLOCK_DETAIL,
    MATCH_BLOCK_DETAIL,
    SRC_SPCL_CNDTN_CNT,
    TRG_SPCL_CNDTN_CNT,
    MATCH_SPCL_CNDTN_CNT,
    SRC_SPCL_CNDTN_LST,
    TRG_SPCL_CNDTN_LST,
    MATCH_SPCL_CNDTN_LST,
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
    :new.MACC_KEY,
    :new.SRC_CLIENT_ID,
    :new.TRG_CLIENT_ID,
    :new.MATCH_CLIENT_ID,
    :new.SRC_ACCNT_ID,
    :new.TRG_ACCNT_ID,
    :new.MATCH_ACCNT_ID,
    :new.SRC_IBAN,
    :new.TRG_IBAN,
    :new.MATCH_IBAN,
    :new.SRC_ESR_ID,
    :new.TRG_ESR_ID,
    :new.MATCH_ESR_ID,
    :new.SRC_CTN_KEY,
    :new.TRG_CTN_KEY,
    :new.SRC_PRODUCT_KEY,
    :new.TRG_PRODUCT_KEY,
    :new.MATCH_PRODUCT_KEY,
    :new.SRC_PRODUCT_NM,
    :new.TRG_PRODUCT_NM,
    :new.SRC_CREATE_DT,
    :new.TRG_CREATE_DT,
    :new.MATCH_CREATE_DT,
    :new.SRC_LAST_INTR_RUN_DT,
    :new.TRG_LAST_INTR_RUN_DT,
    :new.MATCH_LAST_INTR_RUN_DT,
    :new.SRC_REF_CURRENCY,
    :new.TRG_REF_CURRENCY,
    :new.MATCH_REF_CURRENCY,
    :new.SRC_ACCNT_OPENER,
    :new.TRG_ACCNT_OPENER,
    :new.MATCH_ACCNT_OPENER,
    :new.SRC_BLOCK_CNT,
    :new.TRG_BLOCK_CNT,
    :new.MATCH_BLOCK_CNT,
    :new.SRC_BLOCK_DETAIL,
    :new.TRG_BLOCK_DETAIL,
    :new.MATCH_BLOCK_DETAIL,
    :new.SRC_SPCL_CNDTN_CNT,
    :new.TRG_SPCL_CNDTN_CNT,
    :new.MATCH_SPCL_CNDTN_CNT,
    :new.SRC_SPCL_CNDTN_LST,
    :new.TRG_SPCL_CNDTN_LST,
    :new.MATCH_SPCL_CNDTN_LST,
    :new.RCN_PRCS_ID,
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

