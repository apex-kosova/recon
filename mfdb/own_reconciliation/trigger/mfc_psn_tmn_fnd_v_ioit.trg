CREATE OR REPLACE TRIGGER MFC_PSN_TMN_FND_V_IOIT
INSTEAD OF INSERT ON MFC_PSN_TMN_FND_V
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
        NVL(:new.SRC_CLIENT_TYPE, 'NULL'), NVL(:new.TRG_CLIENT_TYPE, 'NULL'), :new.MATCH_CLIENT_TYPE, 
        NVL(:new.SRC_CLIENT_NM, 'NULL'), NVL(:new.TRG_CLIENT_NM, 'NULL'), :new.MATCH_CLIENT_NM, 
        NVL(:new.SRC_NATION_CNTRY_CD, 'NULL'), NVL(:new.TRG_NATION_CNTRY_CD, 'NULL'), :new.MATCH_NATION_CNTRY_CD, 
        NVL(:new.SRC_SNB_NM, 'NULL'), NVL(:new.TRG_SNB_NM, 'NULL'), :new.MATCH_SNB_NM, 
        NVL(:new.SRC_BUS_CONNECT_TYPE, 'NULL'), NVL(:new.TRG_BUS_CONNECT_TYPE, 'NULL'), :new.MATCH_BUS_CONNECT_TYPE, 
        NVL(TO_CHAR(:new.SRC_PRSN_IDENT_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_PRSN_IDENT_CNT), 'NULL'), :new.MATCH_PRSN_IDENT_CNT, 
        NVL(:new.SRC_PRSN_IDENT_LST, 'NULL'), NVL(:new.TRG_PRSN_IDENT_LST, 'NULL'), :new.MATCH_PRSN_IDENT_LST, 
        NVL(TO_CHAR(:new.SRC_PRSN_REL_PEP_DAP_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_PRSN_REL_PEP_DAP_CNT), 'NULL'), :new.MATCH_PRSN_REL_PEP_DAP_CNT, 
        NVL(:new.SRC_PRSN_REL_PEP_DAP_LST, 'NULL'), NVL(:new.TRG_PRSN_REL_PEP_DAP_LST, 'NULL'), :new.MATCH_PRSN_REL_PEP_DAP_LST, 
        NVL(:new.SRC_PRSN_REL_RSPNSBL, 'NULL'), NVL(:new.TRG_PRSN_REL_RSPNSBL, 'NULL'), :new.MATCH_PRSN_REL_RSPNSBL, 
        NVL(TO_CHAR(:new.SRC_DCMNT_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_DCMNT_CNT), 'NULL'), :new.MATCH_DCMNT_CNT, 
        NVL(:new.SRC_DCMNT_LST, 'NULL'), NVL(:new.TRG_DCMNT_LST, 'NULL'), :new.MATCH_DCMNT_LST
      ) IN 
      ( SELECT 
          NVL(STD_FND_MIGR_ERROR, 'NULL'), 
          NVL(SRC_CLIENT_TYPE, 'NULL'), NVL(TRG_CLIENT_TYPE, 'NULL'), MATCH_CLIENT_TYPE, 
          NVL(SRC_CLIENT_NM, 'NULL'), NVL(TRG_CLIENT_NM, 'NULL'), MATCH_CLIENT_NM, 
          NVL(SRC_NATION_CNTRY_CD, 'NULL'), NVL(TRG_NATION_CNTRY_CD, 'NULL'), MATCH_NATION_CNTRY_CD, 
          NVL(SRC_SNB_NM, 'NULL'), NVL(TRG_SNB_NM, 'NULL'), MATCH_SNB_NM, 
          NVL(SRC_BUS_CONNECT_TYPE, 'NULL'), NVL(TRG_BUS_CONNECT_TYPE, 'NULL'), MATCH_BUS_CONNECT_TYPE, 
          NVL(TO_CHAR(SRC_PRSN_IDENT_CNT), 'NULL'), NVL(TO_CHAR(TRG_PRSN_IDENT_CNT), 'NULL'), MATCH_PRSN_IDENT_CNT, 
          NVL(SRC_PRSN_IDENT_LST, 'NULL'), NVL(TRG_PRSN_IDENT_LST, 'NULL'), MATCH_PRSN_IDENT_LST, 
          NVL(TO_CHAR(SRC_PRSN_REL_PEP_DAP_CNT), 'NULL'), NVL(TO_CHAR(TRG_PRSN_REL_PEP_DAP_CNT), 'NULL'), MATCH_PRSN_REL_PEP_DAP_CNT, 
          NVL(SRC_PRSN_REL_PEP_DAP_LST, 'NULL'), NVL(TRG_PRSN_REL_PEP_DAP_LST, 'NULL'), MATCH_PRSN_REL_PEP_DAP_LST, 
          NVL(SRC_PRSN_REL_RSPNSBL, 'NULL'), NVL(TRG_PRSN_REL_RSPNSBL, 'NULL'), MATCH_PRSN_REL_RSPNSBL, 
          NVL(TO_CHAR(SRC_DCMNT_CNT), 'NULL'), NVL(TO_CHAR(TRG_DCMNT_CNT), 'NULL'), MATCH_DCMNT_CNT, 
          NVL(SRC_DCMNT_LST, 'NULL'), NVL(TRG_DCMNT_LST, 'NULL'), MATCH_DCMNT_LST
        FROM MFC_PSN_TMN_FND 
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
      FROM MFC_PSN_TMN_FND
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

  INSERT INTO MFC_PSN_TMN_FND
  ( FND_ID,
    STD_FND_COMMENT,
    STD_FND_MIGR_ERROR, 
    STD_FND_SIGN_OFF_FG, 
    STD_FND_BUG_FIX_ITIL_NO,
    MIGR_RUN_ID,
    PSN_KEY,
    SRC_CLIENT_TYPE,
    TRG_CLIENT_TYPE,
    MATCH_CLIENT_TYPE,
    SRC_CLIENT_NM,
    TRG_CLIENT_NM,
    MATCH_CLIENT_NM,
    SRC_NATION_CNTRY_CD,
    TRG_NATION_CNTRY_CD,
    MATCH_NATION_CNTRY_CD,
    SRC_SNB_NM,
    TRG_SNB_NM,
    MATCH_SNB_NM,
    SRC_BUS_CONNECT_TYPE,
    TRG_BUS_CONNECT_TYPE,
    MATCH_BUS_CONNECT_TYPE,
    SRC_PRSN_IDENT_CNT,
    TRG_PRSN_IDENT_CNT,
    MATCH_PRSN_IDENT_CNT,
    SRC_PRSN_IDENT_LST,
    TRG_PRSN_IDENT_LST,
    MATCH_PRSN_IDENT_LST,
    SRC_PRSN_REL_PEP_DAP_CNT,
    TRG_PRSN_REL_PEP_DAP_CNT,
    MATCH_PRSN_REL_PEP_DAP_CNT,
    SRC_PRSN_REL_PEP_DAP_LST,
    TRG_PRSN_REL_PEP_DAP_LST,
    MATCH_PRSN_REL_PEP_DAP_LST,
    SRC_PRSN_REL_RSPNSBL,
    TRG_PRSN_REL_RSPNSBL,
    MATCH_PRSN_REL_RSPNSBL,
    SRC_DCMNT_CNT,
    TRG_DCMNT_CNT,
    MATCH_DCMNT_CNT,
    SRC_DCMNT_LST,
    TRG_DCMNT_LST,
    MATCH_DCMNT_LST,
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
    :new.SRC_CLIENT_TYPE,
    :new.TRG_CLIENT_TYPE,
    :new.MATCH_CLIENT_TYPE,
    :new.SRC_CLIENT_NM,
    :new.TRG_CLIENT_NM,
    :new.MATCH_CLIENT_NM,
    :new.SRC_NATION_CNTRY_CD,
    :new.TRG_NATION_CNTRY_CD,
    :new.MATCH_NATION_CNTRY_CD,
    :new.SRC_SNB_NM,
    :new.TRG_SNB_NM,
    :new.MATCH_SNB_NM,
    :new.SRC_BUS_CONNECT_TYPE,
    :new.TRG_BUS_CONNECT_TYPE,
    :new.MATCH_BUS_CONNECT_TYPE,
    :new.SRC_PRSN_IDENT_CNT,
    :new.TRG_PRSN_IDENT_CNT,
    :new.MATCH_PRSN_IDENT_CNT,
    :new.SRC_PRSN_IDENT_LST,
    :new.TRG_PRSN_IDENT_LST,
    :new.MATCH_PRSN_IDENT_LST,
    :new.SRC_PRSN_REL_PEP_DAP_CNT,
    :new.TRG_PRSN_REL_PEP_DAP_CNT,
    :new.MATCH_PRSN_REL_PEP_DAP_CNT,
    :new.SRC_PRSN_REL_PEP_DAP_LST,
    :new.TRG_PRSN_REL_PEP_DAP_LST,
    :new.MATCH_PRSN_REL_PEP_DAP_LST,
    :new.SRC_PRSN_REL_RSPNSBL,
    :new.TRG_PRSN_REL_RSPNSBL,
    :new.MATCH_PRSN_REL_RSPNSBL,
    :new.SRC_DCMNT_CNT,
    :new.TRG_DCMNT_CNT,
    :new.MATCH_DCMNT_CNT,
    :new.SRC_DCMNT_LST,
    :new.TRG_DCMNT_LST,
    :new.MATCH_DCMNT_LST,
    :new.RCN_PRCS_ID,
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

