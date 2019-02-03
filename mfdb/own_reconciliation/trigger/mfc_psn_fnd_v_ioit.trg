CREATE OR REPLACE TRIGGER MFC_PSN_FND_V_IOIT
INSTEAD OF INSERT ON MFC_PSN_FND_V
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
        NVL(:new.SRC_CLIENT_ID, 'NULL'), NVL(:new.TRG_CLIENT_ID, 'NULL'), :new.MATCH_CLIENT_ID, NVL(:new.SRC_CLIENT_NM, 'NULL'), NVL(:new.TRG_CLIENT_NM, 'NULL'), :new.MATCH_CLIENT_NM, 
        NVL(TO_CHAR(:new.SRC_CLIENT_BIRTH_DT), 'NULL'), NVL(TO_CHAR(:new.TRG_CLIENT_BIRTH_DT), 'NULL'), :new.MATCH_CLIENT_BIRTH_DT, 
        NVL(:new.SRC_NATION_CNTRY_CD, 'NULL'), NVL(:new.TRG_NATION_CNTRY_CD, 'NULL'), :new.MATCH_NATION_CNTRY_CD, NVL(:new.SRC_LEGAL_FORM, 'NULL'), NVL(:new.TRG_LEGAL_FORM, 'NULL'), :new.MATCH_LEGAL_FORM, 
        NVL(:new.SRC_SNB_CD, 'NULL'), NVL(:new.TRG_SNB_CD, 'NULL'), :new.MATCH_SNB_CD, NVL(:new.SRC_CLIENT_TYPE, 'NULL'), NVL(:new.TRG_CLIENT_TYPE, 'NULL'), :new.MATCH_CLIENT_TYPE, 
        NVL(:new.SRC_CLIENT_STATUS, 'NULL'), NVL(:new.TRG_CLIENT_STATUS, 'NULL'), :new.MATCH_CLIENT_STATUS, NVL(:new.SRC_IDENT_STATUS, 'NULL'), NVL(:new.TRG_IDENT_STATUS, 'NULL'), :new.MATCH_IDENT_STATUS, 
        NVL(:new.SRC_CAPABILITY_2_ACT, 'NULL'), NVL(:new.TRG_CAPABILITY_2_ACT, 'NULL'), :new.MATCH_CAPABILITY_2_ACT, NVL(TO_CHAR(:new.SRC_PRSN_REL_WNR_CMTY_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_PRSN_REL_WNR_CMTY_CNT), 'NULL'), :new.MATCH_PRSN_REL_WNR_CMTY_CNT, 
        NVL(:new.SRC_PRSN_REL_WNR_CMTY_LST, 'NULL'), NVL(:new.TRG_PRSN_REL_WNR_CMTY_LST, 'NULL'), :new.MATCH_PRSN_REL_WNR_CMTY_LST, NVL(TO_CHAR(:new.SRC_PRSN_REL_ALL_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_PRSN_REL_ALL_CNT), 'NULL'), 
        NVL(:new.SRC_PRSN_REL_ALL_LST, 'NULL'), NVL(:new.TRG_PRSN_REL_ALL_LST, 'NULL'), NVL(:new.SRC_FATCA_CMPL, 'NULL'), NVL(:new.TRG_FATCA_CMPL, 'NULL'), :new.MATCH_FATCA_CMPL, 
        NVL(:new.SRC_FATCA_EVAL, 'NULL'), NVL(:new.TRG_FATCA_EVAL, 'NULL'), :new.MATCH_FATCA_EVAL, NVL(:new.SRC_FATCA_STATUS, 'NULL'), NVL(:new.TRG_FATCA_STATUS, 'NULL'), :new.MATCH_FATCA_STATUS
      ) IN 
      ( SELECT 
          NVL(STD_FND_MIGR_ERROR, 'NULL'), 
          NVL(SRC_CLIENT_ID, 'NULL'), NVL(TRG_CLIENT_ID, 'NULL'), MATCH_CLIENT_ID, NVL(SRC_CLIENT_NM, 'NULL'), NVL(TRG_CLIENT_NM, 'NULL'), MATCH_CLIENT_NM, 
          NVL(TO_CHAR(SRC_CLIENT_BIRTH_DT), 'NULL'), NVL(TO_CHAR(TRG_CLIENT_BIRTH_DT), 'NULL'), MATCH_CLIENT_BIRTH_DT, 
          NVL(SRC_NATION_CNTRY_CD, 'NULL'), NVL(TRG_NATION_CNTRY_CD, 'NULL'), MATCH_NATION_CNTRY_CD, NVL(SRC_LEGAL_FORM, 'NULL'), NVL(TRG_LEGAL_FORM, 'NULL'), MATCH_LEGAL_FORM, 
          NVL(SRC_SNB_CD, 'NULL'), NVL(TRG_SNB_CD, 'NULL'), MATCH_SNB_CD, NVL(SRC_CLIENT_TYPE, 'NULL'), NVL(TRG_CLIENT_TYPE, 'NULL'), MATCH_CLIENT_TYPE, 
          NVL(SRC_CLIENT_STATUS, 'NULL'), NVL(TRG_CLIENT_STATUS, 'NULL'), MATCH_CLIENT_STATUS, NVL(SRC_IDENT_STATUS, 'NULL'), NVL(TRG_IDENT_STATUS, 'NULL'), MATCH_IDENT_STATUS, 
          NVL(SRC_CAPABILITY_2_ACT, 'NULL'), NVL(TRG_CAPABILITY_2_ACT, 'NULL'), MATCH_CAPABILITY_2_ACT, NVL(TO_CHAR(SRC_PRSN_REL_WNR_CMTY_CNT), 'NULL'), NVL(TO_CHAR(TRG_PRSN_REL_WNR_CMTY_CNT), 'NULL'), MATCH_PRSN_REL_WNR_CMTY_CNT, 
          NVL(SRC_PRSN_REL_WNR_CMTY_LST, 'NULL'), NVL(TRG_PRSN_REL_WNR_CMTY_LST, 'NULL'), MATCH_PRSN_REL_WNR_CMTY_LST, NVL(TO_CHAR(SRC_PRSN_REL_ALL_CNT), 'NULL'), NVL(TO_CHAR(TRG_PRSN_REL_ALL_CNT), 'NULL'), 
          NVL(SRC_PRSN_REL_ALL_LST, 'NULL'), NVL(TRG_PRSN_REL_ALL_LST, 'NULL'), NVL(SRC_FATCA_CMPL, 'NULL'), NVL(TRG_FATCA_CMPL, 'NULL'), MATCH_FATCA_CMPL, 
          NVL(SRC_FATCA_EVAL, 'NULL'), NVL(TRG_FATCA_EVAL, 'NULL'), MATCH_FATCA_EVAL, NVL(SRC_FATCA_STATUS, 'NULL'), NVL(TRG_FATCA_STATUS, 'NULL'), MATCH_FATCA_STATUS
        FROM MFC_PSN_FND 
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND PSN_KEY = :new.PSN_KEY
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
      FROM MFC_PSN_FND
      WHERE MIGR_RUN_ID = l_pred_run_id
        AND PSN_KEY = :new.PSN_KEY
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

  INSERT INTO MFC_PSN_FND
  ( FND_ID,
    STD_FND_COMMENT,
    STD_FND_MIGR_ERROR, 
    STD_FND_SIGN_OFF_FG, 
    STD_FND_BUG_FIX_ITIL_NO,
    MIGR_RUN_ID,
    PSN_KEY,
    SRC_CLIENT_ID,
    TRG_CLIENT_ID,
    MATCH_CLIENT_ID,
    SRC_CLIENT_NM,
    TRG_CLIENT_NM,
    MATCH_CLIENT_NM,
    SRC_CLIENT_BIRTH_DT,
    TRG_CLIENT_BIRTH_DT,
    MATCH_CLIENT_BIRTH_DT,
    SRC_NATION_CNTRY_CD,
    TRG_NATION_CNTRY_CD,
    MATCH_NATION_CNTRY_CD,
    SRC_LEGAL_FORM,
    TRG_LEGAL_FORM,
    MATCH_LEGAL_FORM,
    SRC_SNB_CD,
    TRG_SNB_CD,
    MATCH_SNB_CD,
    SRC_CLIENT_TYPE,
    TRG_CLIENT_TYPE,
    MATCH_CLIENT_TYPE,
    SRC_CLIENT_STATUS,
    TRG_CLIENT_STATUS,
    MATCH_CLIENT_STATUS,
    SRC_IDENT_STATUS,
    TRG_IDENT_STATUS,
    MATCH_IDENT_STATUS,
    SRC_CAPABILITY_2_ACT,
    TRG_CAPABILITY_2_ACT,
    MATCH_CAPABILITY_2_ACT,
    SRC_PRSN_REL_WNR_CMTY_CNT,
    TRG_PRSN_REL_WNR_CMTY_CNT,
    MATCH_PRSN_REL_WNR_CMTY_CNT,
    SRC_PRSN_REL_WNR_CMTY_LST,
    TRG_PRSN_REL_WNR_CMTY_LST,
    MATCH_PRSN_REL_WNR_CMTY_LST,
    SRC_PRSN_REL_ALL_CNT,
    TRG_PRSN_REL_ALL_CNT,
    SRC_PRSN_REL_ALL_LST,
    TRG_PRSN_REL_ALL_LST,
    SRC_FATCA_CMPL,
    TRG_FATCA_CMPL,
    MATCH_FATCA_CMPL,
    SRC_FATCA_EVAL,
    TRG_FATCA_EVAL,
    MATCH_FATCA_EVAL,
    SRC_FATCA_STATUS,
    TRG_FATCA_STATUS,
    MATCH_FATCA_STATUS,
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
    :new.PSN_KEY,
    :new.SRC_CLIENT_ID,
    :new.TRG_CLIENT_ID,
    :new.MATCH_CLIENT_ID,
    :new.SRC_CLIENT_NM,
    :new.TRG_CLIENT_NM,
    :new.MATCH_CLIENT_NM,
    :new.SRC_CLIENT_BIRTH_DT,
    :new.TRG_CLIENT_BIRTH_DT,
    :new.MATCH_CLIENT_BIRTH_DT,
    :new.SRC_NATION_CNTRY_CD,
    :new.TRG_NATION_CNTRY_CD,
    :new.MATCH_NATION_CNTRY_CD,
    :new.SRC_LEGAL_FORM,
    :new.TRG_LEGAL_FORM,
    :new.MATCH_LEGAL_FORM,
    :new.SRC_SNB_CD,
    :new.TRG_SNB_CD,
    :new.MATCH_SNB_CD,
    :new.SRC_CLIENT_TYPE,
    :new.TRG_CLIENT_TYPE,
    :new.MATCH_CLIENT_TYPE,
    :new.SRC_CLIENT_STATUS,
    :new.TRG_CLIENT_STATUS,
    :new.MATCH_CLIENT_STATUS,
    :new.SRC_IDENT_STATUS,
    :new.TRG_IDENT_STATUS,
    :new.MATCH_IDENT_STATUS,
    :new.SRC_CAPABILITY_2_ACT,
    :new.TRG_CAPABILITY_2_ACT,
    :new.MATCH_CAPABILITY_2_ACT,
    :new.SRC_PRSN_REL_WNR_CMTY_CNT,
    :new.TRG_PRSN_REL_WNR_CMTY_CNT,
    :new.MATCH_PRSN_REL_WNR_CMTY_CNT,
    :new.SRC_PRSN_REL_WNR_CMTY_LST,
    :new.TRG_PRSN_REL_WNR_CMTY_LST,
    :new.MATCH_PRSN_REL_WNR_CMTY_LST,
    :new.SRC_PRSN_REL_ALL_CNT,
    :new.TRG_PRSN_REL_ALL_CNT,
    :new.SRC_PRSN_REL_ALL_LST,
    :new.TRG_PRSN_REL_ALL_LST,
    :new.SRC_FATCA_CMPL,
    :new.TRG_FATCA_CMPL,
    :new.MATCH_FATCA_CMPL,
    :new.SRC_FATCA_EVAL,
    :new.TRG_FATCA_EVAL,
    :new.MATCH_FATCA_EVAL,
    :new.SRC_FATCA_STATUS,
    :new.TRG_FATCA_STATUS,
    :new.MATCH_FATCA_STATUS,
    :new.RCN_PRCS_ID,
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

