CREATE OR REPLACE TRIGGER MFC_BP_TMN_FND_V_IOIT
INSTEAD OF INSERT ON MFC_BP_TMN_FND_V
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
        NVL(:new.SRC_CLIENT_TYPE, 'NULL'), NVL(:new.TRG_CLIENT_TYPE, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_CLIENT_CREATE_DT), 'NULL'), NVL(TO_CHAR(:new.TRG_CLIENT_CREATE_DT), 'NULL'), :new.MATCH_CLIENT_CREATE_DT, 
        NVL(TO_CHAR(:new.SRC_NOGA_2008_CD), 'NULL'), NVL(TO_CHAR(:new.TRG_NOGA_2008_CD), 'NULL'), :new.MATCH_NOGA_2008_CD, 
        NVL(:new.SRC_FISCAL_DOMICILE, 'NULL'), NVL(:new.TRG_FISCAL_DOMICILE, 'NULL'), :new.MATCH_FISCAL_DOMICILE, 
        NVL(:new.SRC_REF_CURRENCY, 'NULL'), NVL(:new.TRG_REF_CURRENCY, 'NULL'), :new.MATCH_REF_CURRENCY, 
        NVL(:new.SRC_XTRNL_LGCY_KEY, 'NULL'), NVL(:new.TRG_XTRNL_LGCY_KEY, 'NULL'), :new.MATCH_XTRNL_LGCY_KEY,
        NVL(:new.SRC_SWIFT_KEY, 'NULL'), NVL(:new.TRG_SWIFT_KEY, 'NULL'), :new.MATCH_SWIFT_KEY,
        NVL(:new.SRC_CLEARING_KEY, 'NULL'), NVL(:new.TRG_CLEARING_KEY, 'NULL'), :new.MATCH_CLEARING_KEY,
        NVL(:new.SRC_CUSTOMER_TYPE, 'NULL'), NVL(:new.TRG_CUSTOMER_TYPE, 'NULL'), :new.MATCH_CUSTOMER_TYPE,
        NVL(:new.SRC_COUNTER_PRTY_TYPE, 'NULL'), NVL(:new.TRG_COUNTER_PRTY_TYPE, 'NULL'), :new.MATCH_COUNTER_PRTY_TYPE,
        NVL(:new.SRC_CSTDN_CSH_CRRSPND_TYPE, 'NULL'), NVL(:new.TRG_CSTDN_CSH_CRRSPND_TYPE, 'NULL'), :new.MATCH_CSTDN_CSH_CRRSPND_TYPE,
        NVL(:new.SRC_CENTRAL_BNK_SELECT, 'NULL'), NVL(:new.TRG_CENTRAL_BNK_SELECT, 'NULL'), :new.MATCH_CENTRAL_BNK_SELECT,
        NVL(:new.SRC_CALC_AGENT, 'NULL'), NVL(:new.TRG_CALC_AGENT, 'NULL'), :new.MATCH_CALC_AGENT,
        NVL(:new.SRC_FIRE_COUNTER_PRTY_TYPE, 'NULL'), NVL(:new.TRG_FIRE_COUNTER_PRTY_TYPE, 'NULL'), :new.MATCH_FIRE_COUNTER_PRTY_TYPE,
        NVL(:new.SRC_FIRE_CENTRL_COUNTER_PRTY, 'NULL'), NVL(:new.TRG_FIRE_CENTRL_COUNTER_PRTY, 'NULL'), :new.MATCH_FIRE_CENTRL_COUNTER_PRTY,
        NVL(:new.SRC_FIRE_ENTITY_CD, 'NULL'), NVL(:new.TRG_FIRE_ENTITY_CD, 'NULL'), :new.MATCH_FIRE_ENTITY_CD,
        NVL(:new.SRC_FIRE_CONSOLID_LVL, 'NULL'), NVL(:new.TRG_FIRE_CONSOLID_LVL, 'NULL'), :new.MATCH_FIRE_CONSOLID_LVL,
        NVL(:new.SRC_KPMG_COUNTER_PRTY, 'NULL'), NVL(:new.TRG_KPMG_COUNTER_PRTY, 'NULL'), :new.MATCH_KPMG_COUNTER_PRTY,
        NVL(TO_CHAR(:new.SRC_PRSN_REL_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_PRSN_REL_CNT), 'NULL'), :new.MATCH_PRSN_REL_CNT, 
        NVL(:new.SRC_PRSN_REL_LST, 'NULL'), NVL(:new.TRG_PRSN_REL_LST, 'NULL'), :new.MATCH_PRSN_REL_LST, 
        NVL(TO_CHAR(:new.SRC_STDG_INSTR_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_STDG_INSTR_CNT), 'NULL'), :new.MATCH_STDG_INSTR_CNT, 
        NVL(:new.SRC_STDG_INSTR_LST, 'NULL'), NVL(:new.TRG_STDG_INSTR_LST, 'NULL'), :new.MATCH_STDG_INSTR_LST 
      ) IN 
      ( SELECT 
          NVL(STD_FND_MIGR_ERROR, 'NULL'), 
          NVL(SRC_CLIENT_TYPE, 'NULL'), NVL(TRG_CLIENT_TYPE, 'NULL'), 
          NVL(TO_CHAR(SRC_CLIENT_CREATE_DT), 'NULL'), NVL(TO_CHAR(TRG_CLIENT_CREATE_DT), 'NULL'), MATCH_CLIENT_CREATE_DT, 
          NVL(TO_CHAR(SRC_NOGA_2008_CD), 'NULL'), NVL(TO_CHAR(TRG_NOGA_2008_CD), 'NULL'), MATCH_NOGA_2008_CD, 
          NVL(SRC_FISCAL_DOMICILE, 'NULL'), NVL(TRG_FISCAL_DOMICILE, 'NULL'), MATCH_FISCAL_DOMICILE, 
          NVL(SRC_REF_CURRENCY, 'NULL'), NVL(TRG_REF_CURRENCY, 'NULL'), MATCH_REF_CURRENCY, 
          NVL(SRC_XTRNL_LGCY_KEY, 'NULL'), NVL(TRG_XTRNL_LGCY_KEY, 'NULL'), MATCH_XTRNL_LGCY_KEY,
          NVL(SRC_SWIFT_KEY, 'NULL'), NVL(TRG_SWIFT_KEY, 'NULL'), MATCH_SWIFT_KEY,
          NVL(SRC_CLEARING_KEY, 'NULL'), NVL(TRG_CLEARING_KEY, 'NULL'), MATCH_CLEARING_KEY,
          NVL(SRC_CUSTOMER_TYPE, 'NULL'), NVL(TRG_CUSTOMER_TYPE, 'NULL'), MATCH_CUSTOMER_TYPE,
          NVL(SRC_COUNTER_PRTY_TYPE, 'NULL'), NVL(TRG_COUNTER_PRTY_TYPE, 'NULL'), MATCH_COUNTER_PRTY_TYPE,
          NVL(SRC_CSTDN_CSH_CRRSPND_TYPE, 'NULL'), NVL(TRG_CSTDN_CSH_CRRSPND_TYPE, 'NULL'), MATCH_CSTDN_CSH_CRRSPND_TYPE,
          NVL(SRC_CENTRAL_BNK_SELECT, 'NULL'), NVL(TRG_CENTRAL_BNK_SELECT, 'NULL'), MATCH_CENTRAL_BNK_SELECT,
          NVL(SRC_CALC_AGENT, 'NULL'), NVL(TRG_CALC_AGENT, 'NULL'), MATCH_CALC_AGENT,
          NVL(SRC_FIRE_COUNTER_PRTY_TYPE, 'NULL'), NVL(TRG_FIRE_COUNTER_PRTY_TYPE, 'NULL'), MATCH_FIRE_COUNTER_PRTY_TYPE,
          NVL(SRC_FIRE_CENTRL_COUNTER_PRTY, 'NULL'), NVL(TRG_FIRE_CENTRL_COUNTER_PRTY, 'NULL'), MATCH_FIRE_CENTRL_COUNTER_PRTY,
          NVL(SRC_FIRE_ENTITY_CD, 'NULL'), NVL(TRG_FIRE_ENTITY_CD, 'NULL'), MATCH_FIRE_ENTITY_CD,
          NVL(SRC_FIRE_CONSOLID_LVL, 'NULL'), NVL(TRG_FIRE_CONSOLID_LVL, 'NULL'), MATCH_FIRE_CONSOLID_LVL,
          NVL(SRC_KPMG_COUNTER_PRTY, 'NULL'), NVL(TRG_KPMG_COUNTER_PRTY, 'NULL'), MATCH_KPMG_COUNTER_PRTY,
          NVL(TO_CHAR(SRC_PRSN_REL_CNT), 'NULL'), NVL(TO_CHAR(TRG_PRSN_REL_CNT), 'NULL'), MATCH_PRSN_REL_CNT, 
          NVL(SRC_PRSN_REL_LST, 'NULL'), NVL(TRG_PRSN_REL_LST, 'NULL'), MATCH_PRSN_REL_LST, 
          NVL(TO_CHAR(SRC_STDG_INSTR_CNT), 'NULL'), NVL(TO_CHAR(TRG_STDG_INSTR_CNT), 'NULL'), MATCH_STDG_INSTR_CNT, 
          NVL(SRC_STDG_INSTR_LST, 'NULL'), NVL(TRG_STDG_INSTR_LST, 'NULL'), MATCH_STDG_INSTR_LST
        FROM MFC_BP_TMN_FND 
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND BP_KEY = :new.BP_KEY
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
      FROM MFC_BP_TMN_FND
      WHERE MIGR_RUN_ID = l_pred_run_id
        AND BP_KEY = :new.BP_KEY
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

	INSERT INTO MFC_BP_TMN_FND
  ( FND_ID, 
    STD_FND_COMMENT, 
    STD_FND_MIGR_ERROR, 
		STD_FND_SIGN_OFF_FG, 
		STD_FND_BUG_FIX_ITIL_NO,
    MIGR_RUN_ID, 
    RCN_PRCS_ID, 
    BP_KEY,
    SRC_CLIENT_TYPE,
    TRG_CLIENT_TYPE,
    MATCH_CLIENT_TYPE,
    SRC_CLIENT_CREATE_DT,
    TRG_CLIENT_CREATE_DT,
    MATCH_CLIENT_CREATE_DT,
    SRC_NOGA_2008_CD,
    TRG_NOGA_2008_CD,
    MATCH_NOGA_2008_CD,
    SRC_FISCAL_DOMICILE,
    TRG_FISCAL_DOMICILE,
    MATCH_FISCAL_DOMICILE,
    SRC_REF_CURRENCY,
    TRG_REF_CURRENCY,
    MATCH_REF_CURRENCY,
    SRC_XTRNL_LGCY_KEY,
    TRG_XTRNL_LGCY_KEY,
    MATCH_XTRNL_LGCY_KEY,
    SRC_SWIFT_KEY,
    TRG_SWIFT_KEY,
    MATCH_SWIFT_KEY,
    SRC_CLEARING_KEY,
    TRG_CLEARING_KEY,
    MATCH_CLEARING_KEY,
    SRC_CUSTOMER_TYPE,
    TRG_CUSTOMER_TYPE,
    MATCH_CUSTOMER_TYPE,
    SRC_COUNTER_PRTY_TYPE,
    TRG_COUNTER_PRTY_TYPE,
    MATCH_COUNTER_PRTY_TYPE,
    SRC_CSTDN_CSH_CRRSPND_TYPE,
    TRG_CSTDN_CSH_CRRSPND_TYPE,
    MATCH_CSTDN_CSH_CRRSPND_TYPE,
    SRC_CENTRAL_BNK_SELECT,
    TRG_CENTRAL_BNK_SELECT,
    MATCH_CENTRAL_BNK_SELECT,
    SRC_CALC_AGENT,
    TRG_CALC_AGENT,
    MATCH_CALC_AGENT,
    SRC_FIRE_COUNTER_PRTY_TYPE,
    TRG_FIRE_COUNTER_PRTY_TYPE,
    MATCH_FIRE_COUNTER_PRTY_TYPE,
    SRC_FIRE_CENTRL_COUNTER_PRTY,
    TRG_FIRE_CENTRL_COUNTER_PRTY,
    MATCH_FIRE_CENTRL_COUNTER_PRTY,
    SRC_FIRE_ENTITY_CD,
    TRG_FIRE_ENTITY_CD,
    MATCH_FIRE_ENTITY_CD,
    SRC_FIRE_CONSOLID_LVL,
    TRG_FIRE_CONSOLID_LVL,
    MATCH_FIRE_CONSOLID_LVL,
    SRC_KPMG_COUNTER_PRTY,
    TRG_KPMG_COUNTER_PRTY,
    MATCH_KPMG_COUNTER_PRTY,
    SRC_PRSN_REL_CNT,
    TRG_PRSN_REL_CNT,
    MATCH_PRSN_REL_CNT,
    SRC_PRSN_REL_LST,
    TRG_PRSN_REL_LST,
    MATCH_PRSN_REL_LST,
    SRC_STDG_INSTR_CNT,
    TRG_STDG_INSTR_CNT,
    MATCH_STDG_INSTR_CNT,
    SRC_STDG_INSTR_LST,
    TRG_STDG_INSTR_LST,
    MATCH_STDG_INSTR_LST,
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
    :new.BP_KEY,
    :new.SRC_CLIENT_TYPE,
    :new.TRG_CLIENT_TYPE,
    :new.MATCH_CLIENT_TYPE,
    :new.SRC_CLIENT_CREATE_DT,
    :new.TRG_CLIENT_CREATE_DT,
    :new.MATCH_CLIENT_CREATE_DT,
    :new.SRC_NOGA_2008_CD,
    :new.TRG_NOGA_2008_CD,
    :new.MATCH_NOGA_2008_CD,
    :new.SRC_FISCAL_DOMICILE,
    :new.TRG_FISCAL_DOMICILE,
    :new.MATCH_FISCAL_DOMICILE,
    :new.SRC_REF_CURRENCY,
    :new.TRG_REF_CURRENCY,
    :new.MATCH_REF_CURRENCY,
    :new.SRC_XTRNL_LGCY_KEY,
    :new.TRG_XTRNL_LGCY_KEY,
    :new.MATCH_XTRNL_LGCY_KEY,
    :new.SRC_SWIFT_KEY,
    :new.TRG_SWIFT_KEY,
    :new.MATCH_SWIFT_KEY,
    :new.SRC_CLEARING_KEY,
    :new.TRG_CLEARING_KEY,
    :new.MATCH_CLEARING_KEY,
    :new.SRC_CUSTOMER_TYPE,
    :new.TRG_CUSTOMER_TYPE,
    :new.MATCH_CUSTOMER_TYPE,
    :new.SRC_COUNTER_PRTY_TYPE,
    :new.TRG_COUNTER_PRTY_TYPE,
    :new.MATCH_COUNTER_PRTY_TYPE,
    :new.SRC_CSTDN_CSH_CRRSPND_TYPE,
    :new.TRG_CSTDN_CSH_CRRSPND_TYPE,
    :new.MATCH_CSTDN_CSH_CRRSPND_TYPE,
    :new.SRC_CENTRAL_BNK_SELECT,
    :new.TRG_CENTRAL_BNK_SELECT,
    :new.MATCH_CENTRAL_BNK_SELECT,
    :new.SRC_CALC_AGENT,
    :new.TRG_CALC_AGENT,
    :new.MATCH_CALC_AGENT,
    :new.SRC_FIRE_COUNTER_PRTY_TYPE,
    :new.TRG_FIRE_COUNTER_PRTY_TYPE,
    :new.MATCH_FIRE_COUNTER_PRTY_TYPE,
    :new.SRC_FIRE_CENTRL_COUNTER_PRTY,
    :new.TRG_FIRE_CENTRL_COUNTER_PRTY,
    :new.MATCH_FIRE_CENTRL_COUNTER_PRTY,
    :new.SRC_FIRE_ENTITY_CD,
    :new.TRG_FIRE_ENTITY_CD,
    :new.MATCH_FIRE_ENTITY_CD,
    :new.SRC_FIRE_CONSOLID_LVL,
    :new.TRG_FIRE_CONSOLID_LVL,
    :new.MATCH_FIRE_CONSOLID_LVL,
    :new.SRC_KPMG_COUNTER_PRTY,
    :new.TRG_KPMG_COUNTER_PRTY,
    :new.MATCH_KPMG_COUNTER_PRTY,
    :new.SRC_PRSN_REL_CNT,
    :new.TRG_PRSN_REL_CNT,
    :new.MATCH_PRSN_REL_CNT,
    :new.SRC_PRSN_REL_LST,
    :new.TRG_PRSN_REL_LST,
    :new.MATCH_PRSN_REL_LST,
    :new.SRC_STDG_INSTR_CNT,
    :new.TRG_STDG_INSTR_CNT,
    :new.MATCH_STDG_INSTR_CNT,
    :new.SRC_STDG_INSTR_LST,
    :new.TRG_STDG_INSTR_LST,
    :new.MATCH_STDG_INSTR_LST,
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

