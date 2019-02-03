CREATE OR REPLACE TRIGGER MFC_CTN_FND_V_IOIT
INSTEAD OF INSERT ON MFC_CTN_FND_V
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
        NVL(:new.SRC_CLIENT_ID, 'NULL'), NVL(:new.TRG_CLIENT_ID, 'NULL'), :new.MATCH_CLIENT_ID, NVL(:new.SRC_DPT_NO_DIALBA, 'NULL'), NVL(:new.TRG_DPT_NO_DIALBA, 'NULL'), :new.MATCH_DPT_NO_DIALBA, 
        NVL(TO_CHAR(:new.SRC_CLIENT_CREATE_DT), 'NULL'), NVL(TO_CHAR(:new.TRG_CLIENT_CREATE_DT), 'NULL'), :new.MATCH_CLIENT_CREATE_DT, NVL(:new.SRC_REF_CURRENCY, 'NULL'), NVL(:new.TRG_REF_CURRENCY, 'NULL'), :new.MATCH_REF_CURRENCY, 
        NVL(:new.SRC_CTN_TYPE, 'NULL'), NVL(:new.TRG_CTN_TYPE, 'NULL'), :new.MATCH_CTN_TYPE, NVL(:new.SRC_CTN_RUBRIC, 'NULL'), NVL(:new.TRG_CTN_RUBRIC, 'NULL'), :new.MATCH_CTN_RUBRIC, 
        NVL(:new.SRC_DPT_PRDCT, 'NULL'), NVL(:new.TRG_DPT_PRDCT, 'NULL'), :new.MATCH_DPT_PRDCT, NVL(TO_CHAR(:new.SRC_BLOCK_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_BLOCK_CNT), 'NULL'), :new.MATCH_BLOCK_CNT,  
        NVL(:new.SRC_BLOCK_DETAIL, 'NULL'), NVL(:new.TRG_BLOCK_DETAIL, 'NULL'), :new.MATCH_BLOCK_DETAIL, NVL(TO_CHAR(:new.SRC_BNFCL_OWN_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_BNFCL_OWN_CNT), 'NULL'), :new.MATCH_BNFCL_OWN_CNT,  
        NVL(:new.SRC_BNFCL_OWN_LST, 'NULL'), NVL(:new.TRG_BNFCL_OWN_LST, 'NULL'), :new.MATCH_BNFCL_OWN_LST, NVL(TO_CHAR(:new.SRC_DOC_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_DOC_CNT), 'NULL'), :new.MATCH_DOC_CNT,  
        NVL(:new.SRC_DOC_LST, 'NULL'), NVL(:new.TRG_DOC_LST, 'NULL'), :new.MATCH_DOC_LST, NVL(TO_CHAR(:new.SRC_SC_DPT_CF_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_DPT_CF_CNT), 'NULL'), :new.MATCH_SC_DPT_CF_CNT,  
        NVL(TO_CHAR(:new.SRC_SC_CRTG_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_CRTG_CNT), 'NULL'), :new.MATCH_SC_CRTG_CNT, NVL(TO_CHAR(:new.SRC_SC_EBNK_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_EBNK_CNT), 'NULL'), :new.MATCH_SC_EBNK_CNT, 
        NVL(TO_CHAR(:new.SRC_SC_CRTG_TOFF_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_CRTG_TOFF_CNT), 'NULL'), :new.MATCH_SC_CRTG_TOFF_CNT, NVL(:new.SRC_SPCL_CNDTN_LST, 'NULL'), NVL(:new.TRG_SPCL_CNDTN_LST, 'NULL'), :new.MATCH_SPCL_CNDTN_LST 
      ) IN 
      ( SELECT 
          NVL(STD_FND_MIGR_ERROR, 'NULL'), 
          NVL(SRC_CLIENT_ID, 'NULL'), NVL(TRG_CLIENT_ID, 'NULL'), MATCH_CLIENT_ID, NVL(SRC_DPT_NO_DIALBA, 'NULL'), NVL(TRG_DPT_NO_DIALBA, 'NULL'), MATCH_DPT_NO_DIALBA, 
          NVL(TO_CHAR(SRC_CLIENT_CREATE_DT), 'NULL'), NVL(TO_CHAR(TRG_CLIENT_CREATE_DT), 'NULL'), MATCH_CLIENT_CREATE_DT, NVL(SRC_REF_CURRENCY, 'NULL'), NVL(TRG_REF_CURRENCY, 'NULL'), MATCH_REF_CURRENCY, 
          NVL(SRC_CTN_TYPE, 'NULL'), NVL(TRG_CTN_TYPE, 'NULL'), MATCH_CTN_TYPE, NVL(SRC_CTN_RUBRIC, 'NULL'), NVL(TRG_CTN_RUBRIC, 'NULL'), MATCH_CTN_RUBRIC, 
          NVL(SRC_DPT_PRDCT, 'NULL'), NVL(TRG_DPT_PRDCT, 'NULL'), MATCH_DPT_PRDCT, NVL(TO_CHAR(SRC_BLOCK_CNT), 'NULL'), NVL(TO_CHAR(TRG_BLOCK_CNT), 'NULL'), MATCH_BLOCK_CNT,  
          NVL(SRC_BLOCK_DETAIL, 'NULL'), NVL(TRG_BLOCK_DETAIL, 'NULL'), MATCH_BLOCK_DETAIL, NVL(TO_CHAR(SRC_BNFCL_OWN_CNT), 'NULL'), NVL(TO_CHAR(TRG_BNFCL_OWN_CNT), 'NULL'), MATCH_BNFCL_OWN_CNT,  
          NVL(SRC_BNFCL_OWN_LST, 'NULL'), NVL(TRG_BNFCL_OWN_LST, 'NULL'), MATCH_BNFCL_OWN_LST, NVL(TO_CHAR(SRC_DOC_CNT), 'NULL'), NVL(TO_CHAR(TRG_DOC_CNT), 'NULL'), MATCH_DOC_CNT,  
          NVL(SRC_DOC_LST, 'NULL'), NVL(TRG_DOC_LST, 'NULL'), MATCH_DOC_LST, NVL(TO_CHAR(SRC_SC_DPT_CF_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_DPT_CF_CNT), 'NULL'), MATCH_SC_DPT_CF_CNT,  
          NVL(TO_CHAR(SRC_SC_CRTG_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_CRTG_CNT), 'NULL'), MATCH_SC_CRTG_CNT, NVL(TO_CHAR(SRC_SC_EBNK_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_EBNK_CNT), 'NULL'), MATCH_SC_EBNK_CNT, 
          NVL(TO_CHAR(SRC_SC_CRTG_TOFF_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_CRTG_TOFF_CNT), 'NULL'), MATCH_SC_CRTG_TOFF_CNT, NVL(SRC_SPCL_CNDTN_LST, 'NULL'), NVL(TRG_SPCL_CNDTN_LST, 'NULL'), MATCH_SPCL_CNDTN_LST 
        FROM MFC_CTN_FND 
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND CTN_KEY = :new.CTN_KEY
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
      FROM MFC_CTN_FND
      WHERE MIGR_RUN_ID = l_pred_run_id
        AND CTN_KEY = :new.CTN_KEY
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

	INSERT INTO MFC_CTN_FND
  ( FND_ID, 
    STD_FND_COMMENT, 
    STD_FND_MIGR_ERROR, 
		STD_FND_SIGN_OFF_FG, 
		STD_FND_BUG_FIX_ITIL_NO,
    MIGR_RUN_ID, 
    CTN_KEY, 
    SRC_CLIENT_ID,
    TRG_CLIENT_ID,
    MATCH_CLIENT_ID,
    SRC_DPT_NO_DIALBA,
    TRG_DPT_NO_DIALBA,
    MATCH_DPT_NO_DIALBA,
    SRC_CLIENT_CREATE_DT,
    TRG_CLIENT_CREATE_DT,
    MATCH_CLIENT_CREATE_DT,
    SRC_REF_CURRENCY,
    TRG_REF_CURRENCY,
    MATCH_REF_CURRENCY,
    SRC_CTN_TYPE,
    TRG_CTN_TYPE,
    MATCH_CTN_TYPE,
    SRC_CTN_RUBRIC,
    TRG_CTN_RUBRIC,
    MATCH_CTN_RUBRIC,
    SRC_DPT_PRDCT,
    TRG_DPT_PRDCT,
    MATCH_DPT_PRDCT,
    SRC_BLOCK_CNT,
    TRG_BLOCK_CNT,
    MATCH_BLOCK_CNT,
    SRC_BLOCK_DETAIL,
    TRG_BLOCK_DETAIL,
    MATCH_BLOCK_DETAIL,
    SRC_BNFCL_OWN_CNT,
    TRG_BNFCL_OWN_CNT,
    MATCH_BNFCL_OWN_CNT,
    SRC_BNFCL_OWN_LST,
    TRG_BNFCL_OWN_LST,
    MATCH_BNFCL_OWN_LST,
    SRC_DOC_CNT,
    TRG_DOC_CNT,
    MATCH_DOC_CNT,
    SRC_DOC_LST,
    TRG_DOC_LST,
    MATCH_DOC_LST,
    SRC_SC_DPT_CF_CNT,
    TRG_SC_DPT_CF_CNT,
    MATCH_SC_DPT_CF_CNT,
    SRC_SC_CRTG_CNT,
    TRG_SC_CRTG_CNT,
    MATCH_SC_CRTG_CNT,
    SRC_SC_EBNK_CNT,
    TRG_SC_EBNK_CNT,
    MATCH_SC_EBNK_CNT,
    SRC_SC_CRTG_TOFF_CNT,
    TRG_SC_CRTG_TOFF_CNT,
    MATCH_SC_CRTG_TOFF_CNT,
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
    :new.CTN_KEY,
    :new.SRC_CLIENT_ID,
    :new.TRG_CLIENT_ID,
    :new.MATCH_CLIENT_ID,
    :new.SRC_DPT_NO_DIALBA,
    :new.TRG_DPT_NO_DIALBA,
    :new.MATCH_DPT_NO_DIALBA,
    :new.SRC_CLIENT_CREATE_DT,
    :new.TRG_CLIENT_CREATE_DT,
    :new.MATCH_CLIENT_CREATE_DT,
    :new.SRC_REF_CURRENCY,
    :new.TRG_REF_CURRENCY,
    :new.MATCH_REF_CURRENCY,
    :new.SRC_CTN_TYPE,
    :new.TRG_CTN_TYPE,
    :new.MATCH_CTN_TYPE,
    :new.SRC_CTN_RUBRIC,
    :new.TRG_CTN_RUBRIC,
    :new.MATCH_CTN_RUBRIC,
    :new.SRC_DPT_PRDCT,
    :new.TRG_DPT_PRDCT,
    :new.MATCH_DPT_PRDCT,
    :new.SRC_BLOCK_CNT,
    :new.TRG_BLOCK_CNT,
    :new.MATCH_BLOCK_CNT,
    :new.SRC_BLOCK_DETAIL,
    :new.TRG_BLOCK_DETAIL,
    :new.MATCH_BLOCK_DETAIL,
    :new.SRC_BNFCL_OWN_CNT,
    :new.TRG_BNFCL_OWN_CNT,
    :new.MATCH_BNFCL_OWN_CNT,
    :new.SRC_BNFCL_OWN_LST,
    :new.TRG_BNFCL_OWN_LST,
    :new.MATCH_BNFCL_OWN_LST,
    :new.SRC_DOC_CNT,
    :new.TRG_DOC_CNT,
    :new.MATCH_DOC_CNT,
    :new.SRC_DOC_LST,
    :new.TRG_DOC_LST,
    :new.MATCH_DOC_LST,
    :new.SRC_SC_DPT_CF_CNT,
    :new.TRG_SC_DPT_CF_CNT,
    :new.MATCH_SC_DPT_CF_CNT,
    :new.SRC_SC_CRTG_CNT,
    :new.TRG_SC_CRTG_CNT,
    :new.MATCH_SC_CRTG_CNT,
    :new.SRC_SC_EBNK_CNT,
    :new.TRG_SC_EBNK_CNT,
    :new.MATCH_SC_EBNK_CNT,
    :new.SRC_SC_CRTG_TOFF_CNT,
    :new.TRG_SC_CRTG_TOFF_CNT,
    :new.MATCH_SC_CRTG_TOFF_CNT,
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

