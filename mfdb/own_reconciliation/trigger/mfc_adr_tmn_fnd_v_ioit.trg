CREATE OR REPLACE TRIGGER MFC_ADR_TMN_FND_V_IOIT
INSTEAD OF INSERT ON MFC_ADR_TMN_FND_V
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
        :new.SRC_ADR_TYPE, :new.TRG_ADR_TYPE, :new.MATCH_ADR_TYPE,
        NVL(:new.SRC_CNTCT_LANG, 'NULL'), NVL(:new.TRG_CNTCT_LANG, 'NULL'), :new.MATCH_CNTCT_LANG,
        NVL(:new.SRC_CLIENT_ID, 'NULL'), NVL(:new.TRG_CLIENT_ID, 'NULL'), :new.MATCH_CLIENT_ID, 
        NVL(:new.SRC_SALUTATORY_ADR, 'NULL'), NVL(:new.TRG_SALUTATORY_ADR, 'NULL'), :new.MATCH_SALUTATORY_ADR,
        NVL(:new.SRC_CLIENT_LAST_NM, 'NULL'), NVL(:new.TRG_CLIENT_LAST_NM, 'NULL'), :new.MATCH_CLIENT_LAST_NM, 
        NVL(:new.SRC_CLIENT_FIRST_NM, 'NULL'), NVL(:new.TRG_CLIENT_FIRST_NM, 'NULL'), :new.MATCH_CLIENT_FIRST_NM, 
        NVL(:new.SRC_CLIENT_CMPNY_NM, 'NULL'), NVL(:new.TRG_CLIENT_CMPNY_NM, 'NULL'), :new.MATCH_CLIENT_CMPNY_NM,
        NVL(:new.SRC_ADR_STREET_NM, 'NULL'), NVL(:new.TRG_ADR_STREET_NM, 'NULL'), :new.MATCH_ADR_STREET_NM, 
        NVL(:new.SRC_ADR_ADD_ON_NM, 'NULL'), NVL(:new.TRG_ADR_ADD_ON_NM, 'NULL'), :new.MATCH_ADR_ADD_ON_NM,
        NVL(:new.SRC_ADR_CITY_NM, 'NULL'), NVL(:new.TRG_ADR_CITY_NM, 'NULL'), :new.MATCH_ADR_CITY_NM,
        NVL(:new.SRC_ADR_ZIP_CD, 'NULL'), NVL(:new.TRG_ADR_ZIP_CD, 'NULL'), :new.MATCH_ADR_ZIP_CD, 
        NVL(:new.SRC_ADR_CNTRY_CD, 'NULL'), NVL(:new.TRG_ADR_CNTRY_CD, 'NULL'), :new.MATCH_ADR_CNTRY_CD,
        NVL(:new.SRC_ADR_FULL_STRING, 'NULL'), NVL(:new.TRG_ADR_FULL_STRING, 'NULL'), :new.MATCH_ADR_FULL_STRING,
        NVL(:new.SRC_E_COMUNICATE_CHNL, 'NULL'), NVL(:new.TRG_E_COMUNICATE_CHNL, 'NULL'), :new.MATCH_E_COMUNICATE_CHNL,
        NVL(:new.SRC_E_ADR_SORT, 'NULL'), NVL(:new.TRG_E_ADR_SORT, 'NULL'), :new.MATCH_E_ADR_SORT,
        NVL(:new.SRC_E_ADR_FULL_STRING, 'NULL'), NVL(:new.TRG_E_ADR_FULL_STRING, 'NULL'), :new.MATCH_E_ADR_FULL_STRING
      ) IN 
      ( SELECT 
          NVL(STD_FND_MIGR_ERROR, 'NULL'), 
          SRC_ADR_TYPE, TRG_ADR_TYPE, MATCH_ADR_TYPE,
          NVL(SRC_CNTCT_LANG, 'NULL'), NVL(TRG_CNTCT_LANG, 'NULL'), MATCH_CNTCT_LANG,
          NVL(SRC_CLIENT_ID, 'NULL'), NVL(TRG_CLIENT_ID, 'NULL'), MATCH_CLIENT_ID, 
          NVL(SRC_SALUTATORY_ADR, 'NULL'), NVL(TRG_SALUTATORY_ADR, 'NULL'), MATCH_SALUTATORY_ADR,
          NVL(SRC_CLIENT_LAST_NM, 'NULL'), NVL(TRG_CLIENT_LAST_NM, 'NULL'), MATCH_CLIENT_LAST_NM, 
          NVL(SRC_CLIENT_FIRST_NM, 'NULL'), NVL(TRG_CLIENT_FIRST_NM, 'NULL'), MATCH_CLIENT_FIRST_NM, 
          NVL(SRC_CLIENT_CMPNY_NM, 'NULL'), NVL(TRG_CLIENT_CMPNY_NM, 'NULL'), MATCH_CLIENT_CMPNY_NM,
          NVL(SRC_ADR_STREET_NM, 'NULL'), NVL(TRG_ADR_STREET_NM, 'NULL'), MATCH_ADR_STREET_NM, 
          NVL(SRC_ADR_ADD_ON_NM, 'NULL'), NVL(TRG_ADR_ADD_ON_NM, 'NULL'), MATCH_ADR_ADD_ON_NM,
          NVL(SRC_ADR_CITY_NM, 'NULL'), NVL(TRG_ADR_CITY_NM, 'NULL'), MATCH_ADR_CITY_NM,
          NVL(SRC_ADR_ZIP_CD, 'NULL'), NVL(TRG_ADR_ZIP_CD, 'NULL'), MATCH_ADR_ZIP_CD, 
          NVL(SRC_ADR_CNTRY_CD, 'NULL'), NVL(TRG_ADR_CNTRY_CD, 'NULL'), MATCH_ADR_CNTRY_CD,
          NVL(SRC_ADR_FULL_STRING, 'NULL'), NVL(TRG_ADR_FULL_STRING, 'NULL'), MATCH_ADR_FULL_STRING,
          NVL(SRC_E_COMUNICATE_CHNL, 'NULL'), NVL(TRG_E_COMUNICATE_CHNL, 'NULL'), MATCH_E_COMUNICATE_CHNL,
          NVL(SRC_E_ADR_SORT, 'NULL'), NVL(TRG_E_ADR_SORT, 'NULL'), MATCH_E_ADR_SORT,
          NVL(SRC_E_ADR_FULL_STRING, 'NULL'), NVL(TRG_E_ADR_FULL_STRING, 'NULL'), MATCH_E_ADR_FULL_STRING
        FROM MFC_ADR_TMN_FND 
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND ADR_KEY = :new.ADR_KEY
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
      FROM MFC_ADR_TMN_FND
      WHERE MIGR_RUN_ID = l_pred_run_id
        AND ADR_KEY = :new.ADR_KEY
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

	INSERT INTO MFC_ADR_TMN_FND
  ( FND_ID, 
    STD_FND_COMMENT, 
    STD_FND_MIGR_ERROR, 
		STD_FND_SIGN_OFF_FG, 
		STD_FND_BUG_FIX_ITIL_NO,
    MIGR_RUN_ID, 
    RCN_PRCS_ID, 
    ADR_KEY, 
    SRC_ADR_TYPE,
    TRG_ADR_TYPE,
    MATCH_ADR_TYPE,
    SRC_CNTCT_LANG,
    TRG_CNTCT_LANG,
    MATCH_CNTCT_LANG,
    SRC_CLIENT_ID,
    TRG_CLIENT_ID,
    MATCH_CLIENT_ID,
    SRC_SALUTATORY_ADR,
    TRG_SALUTATORY_ADR,
    MATCH_SALUTATORY_ADR,
    SRC_CLIENT_LAST_NM,
    TRG_CLIENT_LAST_NM,
    MATCH_CLIENT_LAST_NM,
    SRC_CLIENT_FIRST_NM,
    TRG_CLIENT_FIRST_NM,
    MATCH_CLIENT_FIRST_NM,
    SRC_CLIENT_CMPNY_NM,
    TRG_CLIENT_CMPNY_NM,
    MATCH_CLIENT_CMPNY_NM,
    SRC_ADR_STREET_NM,
    TRG_ADR_STREET_NM,
    MATCH_ADR_STREET_NM,
    SRC_ADR_ADD_ON_NM,
    TRG_ADR_ADD_ON_NM,
    MATCH_ADR_ADD_ON_NM,
    SRC_ADR_CITY_NM,
    TRG_ADR_CITY_NM,
    MATCH_ADR_CITY_NM,
    SRC_ADR_ZIP_CD,
    TRG_ADR_ZIP_CD,
    MATCH_ADR_ZIP_CD,
    SRC_ADR_CNTRY_CD,
    TRG_ADR_CNTRY_CD,
    MATCH_ADR_CNTRY_CD,
    SRC_ADR_FULL_STRING,
    TRG_ADR_FULL_STRING,
    MATCH_ADR_FULL_STRING,
    SRC_E_COMUNICATE_CHNL,
    TRG_E_COMUNICATE_CHNL,
    MATCH_E_COMUNICATE_CHNL,
    SRC_E_ADR_SORT,
    TRG_E_ADR_SORT,
    MATCH_E_ADR_SORT,
    SRC_E_ADR_FULL_STRING,
    TRG_E_ADR_FULL_STRING,
    MATCH_E_ADR_FULL_STRING,
    INHERIT_FND_ID,
    INHERIT_RUN_RANK
  ) VALUES 
  ( MFC_RCN_FND_FND_ID_SEQ.NEXTVAL, 
    l_fnd_comment,                       -- may get inherited comment rating
    :new.STD_FND_MIGR_ERROR, 
    l_fnd_sign_off_fg,                   -- may get inherited sign off flag rating
    l_fnd_bug_fix_itil_no,               -- may get inherited ITIL no of bug fix request rating
    :new.MIGR_RUN_ID, 
    :new.RCN_PRCS_ID, 
    :new.ADR_KEY, 
    :new.SRC_ADR_TYPE,
    :new.TRG_ADR_TYPE,
    :new.MATCH_ADR_TYPE,
    :new.SRC_CNTCT_LANG,
    :new.TRG_CNTCT_LANG,
    :new.MATCH_CNTCT_LANG,
    :new.SRC_CLIENT_ID,
    :new.TRG_CLIENT_ID,
    :new.MATCH_CLIENT_ID,
    :new.SRC_SALUTATORY_ADR,
    :new.TRG_SALUTATORY_ADR,
    :new.MATCH_SALUTATORY_ADR,
    :new.SRC_CLIENT_LAST_NM,
    :new.TRG_CLIENT_LAST_NM,
    :new.MATCH_CLIENT_LAST_NM,
    :new.SRC_CLIENT_FIRST_NM,
    :new.TRG_CLIENT_FIRST_NM,
    :new.MATCH_CLIENT_FIRST_NM,
    :new.SRC_CLIENT_CMPNY_NM,
    :new.TRG_CLIENT_CMPNY_NM,
    :new.MATCH_CLIENT_CMPNY_NM,
    :new.SRC_ADR_STREET_NM,
    :new.TRG_ADR_STREET_NM,
    :new.MATCH_ADR_STREET_NM,
    :new.SRC_ADR_ADD_ON_NM,
    :new.TRG_ADR_ADD_ON_NM,
    :new.MATCH_ADR_ADD_ON_NM,
    :new.SRC_ADR_CITY_NM,
    :new.TRG_ADR_CITY_NM,
    :new.MATCH_ADR_CITY_NM,
    :new.SRC_ADR_ZIP_CD,
    :new.TRG_ADR_ZIP_CD,
    :new.MATCH_ADR_ZIP_CD,
    :new.SRC_ADR_CNTRY_CD,
    :new.TRG_ADR_CNTRY_CD,
    :new.MATCH_ADR_CNTRY_CD,
    :new.SRC_ADR_FULL_STRING,
    :new.TRG_ADR_FULL_STRING,
    :new.MATCH_ADR_FULL_STRING,
    :new.SRC_E_COMUNICATE_CHNL,
    :new.TRG_E_COMUNICATE_CHNL,
    :new.MATCH_E_COMUNICATE_CHNL,
    :new.SRC_E_ADR_SORT,
    :new.TRG_E_ADR_SORT,
    :new.MATCH_E_ADR_SORT,
    :new.SRC_E_ADR_FULL_STRING,
    :new.TRG_E_ADR_FULL_STRING,
    :new.MATCH_E_ADR_FULL_STRING,
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

