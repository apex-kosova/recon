CREATE OR REPLACE TRIGGER MFC_POS_TMN_FND_V_IOIT
INSTEAD OF INSERT ON MFC_POS_TMN_FND_V
FOR EACH ROW 
DECLARE
  l_pred_run_id           INTEGER;
  l_pred_run_rank         INTEGER;
  l_pred_fnd_id           INTEGER;
  l_inherit               VARCHAR2(10 CHAR);
  l_fnd_comment           VARCHAR2(1000 CHAR) := :new.POS_FND_COMMENT;           -- NULL on insert
  l_fnd_sign_off_fg       CHAR(1 BYTE)        := :new.POS_FND_SIGN_OFF_FG;       -- NULL on insert
  l_fnd_bug_fix_itil_no   VARCHAR2(25 CHAR)   := :new.POS_FND_BUG_FIX_ITIL_NO;   -- NULL on insert
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
      ( :new.CLIENT_ID, 
        NVL(:new.SRC_POS_PRODUCT, 'NULL'), 
        NVL(:new.SRC_ASSET_NAME, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_ASSET_PRICE), 'NULL'), 
        NVL(:new.SRC_POS_CURR_CD, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_POS_AMOUNT), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_POS_VALUE_POS_CURR), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_EXCH_RATE), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_POS_VALUE_CHF), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_INTEREST_RATE), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_CUM_INTEREST), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_DEBIT_INTEREST_RATE), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_CUM_DEBIT_INTEREST), 'NULL'), 
        NVL(:new.SRC_INTEREST_FLOW_FRQ_PYR, 'NULL'), 
        NVL(:new.SRC_INTEREST_USAGE, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_ACQUIRE_DT), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_TERM_START_DT), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_TERM_END_DT), 'NULL'), 
        NVL(:new.SRC_DEPOSITARY, 'NULL'), 
        NVL(:new.SRC_PAYBACK_TYPE, 'NULL'), 
        NVL(:new.SRC_PAYBACK_AMOUNT, 'NULL'), 
        NVL(:new.SRC_PAYBACK_PER_YEAR, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_POS_AMOUNT_BLOCKED), 'NULL'), 
        NVL(:new.SRC_POS_BLOCKING_CD, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_CONTRACT_AMOUNT), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_LENDING_VALUE), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_LAND_AREA), 'NULL'), 
        NVL(:new.SRC_POS_BUY_CURR_CD, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_POS_BUY_AMOUNT), 'NULL'), 
        NVL(:new.SRC_POS_SELL_CURR_CD, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_POS_SELL_AMOUNT), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_CUT_OFF_DT), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_ACCR_INTEREST_START_DT), 'NULL'), 
        NVL(TO_CHAR(:new.SRC_ACCR_INTEREST_END_DT), 'NULL'), 
        NVL(:new.SRC_FST_CALENDAR_DT_LST, 'NULL'), 
        NVL(:new.SRC_SND_CALENDAR_DT_LST, 'NULL'), 
        NVL(:new.SRC_CALENDAR_DT_MSG, 'NULL'), 
        NVL(:new.TRG_POS_PRODUCT, 'NULL'), 
        NVL(:new.TRG_ASSET_NAME, 'NULL'), 
        NVL(TO_CHAR(:new.TRG_ASSET_PRICE), 'NULL'), 
        NVL(:new.TRG_POS_CURR_CD, 'NULL'), 
        NVL(TO_CHAR(:new.TRG_POS_AMOUNT), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_POS_VALUE_POS_CURR), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_EXCH_RATE), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_POS_VALUE_CHF), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_INTEREST_RATE), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_CUM_INTEREST), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_DEBIT_INTEREST_RATE), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_CUM_DEBIT_INTEREST), 'NULL'), 
        NVL(:new.TRG_INTEREST_FLOW_FRQ_PYR, 'NULL'), 
        NVL(:new.TRG_INTEREST_USAGE, 'NULL'), 
        NVL(TO_CHAR(:new.TRG_ACQUIRE_DT), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_TERM_START_DT), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_TERM_END_DT), 'NULL'), 
        NVL(:new.TRG_DEPOSITARY, 'NULL'), 
        NVL(:new.TRG_PAYBACK_TYPE, 'NULL'), 
        NVL(:new.TRG_PAYBACK_AMOUNT, 'NULL'), 
        NVL(:new.TRG_PAYBACK_PER_YEAR, 'NULL'), 
        NVL(TO_CHAR(:new.TRG_POS_AMOUNT_BLOCKED), 'NULL'), 
        NVL(:new.TRG_POS_BLOCKING_CD, 'NULL'), 
        NVL(TO_CHAR(:new.TRG_CONTRACT_AMOUNT), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_LENDING_VALUE), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_LAND_AREA), 'NULL'), 
        NVL(:new.TRG_POS_BUY_CURR_CD, 'NULL'), 
        NVL(TO_CHAR(:new.TRG_POS_BUY_AMOUNT), 'NULL'), 
        NVL(:new.TRG_POS_SELL_CURR_CD, 'NULL'), 
        NVL(TO_CHAR(:new.TRG_POS_SELL_AMOUNT), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_CUT_OFF_DT), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_ACCR_INTEREST_START_DT), 'NULL'), 
        NVL(TO_CHAR(:new.TRG_ACCR_INTEREST_END_DT), 'NULL'), 
        NVL(:new.TRG_FST_CALENDAR_DT_LST, 'NULL'), 
        NVL(:new.TRG_SND_CALENDAR_DT_LST, 'NULL'), 
        NVL(:new.TRG_CALENDAR_DT_MSG, 'NULL'), 
        NVL(:new.POS_FND_MIGR_ERROR, 'NULL'),
        :new.MATCH_POS_CURR_CD, 
        :new.MATCH_POS_AMOUNT, 
        :new.MATCH_POS_VALUE_POS_CURR, 
        :new.MATCH_POS_VALUE_CHF, 
        :new.MATCH_INTEREST_RATE, 
        :new.MATCH_DEBIT_INTEREST_RATE, 
        :new.MATCH_CUM_INTEREST, 
        :new.MATCH_CUM_DEBIT_INTEREST, 
        :new.MATCH_ACQUIRE_DT, 
        :new.MATCH_PAYBACK_AMOUNT, 
        :new.MATCH_POS_BUY_CURR_CD, 
        :new.MATCH_POS_BUY_AMOUNT, 
        :new.MATCH_POS_SELL_CURR_CD, 
        :new.MATCH_POS_SELL_AMOUNT,
        :new.MATCH_FST_CALENDAR_DT_LST,
        :new.MATCH_SND_CALENDAR_DT_LST
      ) IN 
      ( SELECT 
          CLIENT_ID, 
          NVL(SRC_POS_PRODUCT, 'NULL'), 
          NVL(SRC_ASSET_NAME, 'NULL'), 
          NVL(TO_CHAR(SRC_ASSET_PRICE), 'NULL'), 
          NVL(SRC_POS_CURR_CD, 'NULL'), 
          NVL(TO_CHAR(SRC_POS_AMOUNT), 'NULL'), 
          NVL(TO_CHAR(SRC_POS_VALUE_POS_CURR), 'NULL'), 
          NVL(TO_CHAR(SRC_EXCH_RATE), 'NULL'), 
          NVL(TO_CHAR(SRC_POS_VALUE_CHF), 'NULL'), 
          NVL(TO_CHAR(SRC_INTEREST_RATE), 'NULL'), 
          NVL(TO_CHAR(SRC_CUM_INTEREST), 'NULL'), 
          NVL(TO_CHAR(SRC_DEBIT_INTEREST_RATE), 'NULL'), 
          NVL(TO_CHAR(SRC_CUM_DEBIT_INTEREST), 'NULL'), 
          NVL(SRC_INTEREST_FLOW_FRQ_PYR, 'NULL'), 
          NVL(SRC_INTEREST_USAGE, 'NULL'), 
          NVL(TO_CHAR(SRC_ACQUIRE_DT), 'NULL'), 
          NVL(TO_CHAR(SRC_TERM_START_DT), 'NULL'), 
          NVL(TO_CHAR(SRC_TERM_END_DT), 'NULL'), 
          NVL(SRC_DEPOSITARY, 'NULL'), 
          NVL(SRC_PAYBACK_TYPE, 'NULL'), 
          NVL(SRC_PAYBACK_AMOUNT, 'NULL'), 
          NVL(SRC_PAYBACK_PER_YEAR, 'NULL'), 
          NVL(TO_CHAR(SRC_POS_AMOUNT_BLOCKED), 'NULL'), 
          NVL(SRC_POS_BLOCKING_CD, 'NULL'), 
          NVL(TO_CHAR(SRC_CONTRACT_AMOUNT), 'NULL'), 
          NVL(TO_CHAR(SRC_LENDING_VALUE), 'NULL'), 
          NVL(TO_CHAR(SRC_LAND_AREA), 'NULL'), 
          NVL(SRC_POS_BUY_CURR_CD, 'NULL'), 
          NVL(TO_CHAR(SRC_POS_BUY_AMOUNT), 'NULL'), 
          NVL(SRC_POS_SELL_CURR_CD, 'NULL'), 
          NVL(TO_CHAR(SRC_POS_SELL_AMOUNT), 'NULL'), 
          NVL(TO_CHAR(SRC_CUT_OFF_DT), 'NULL'), 
          NVL(TO_CHAR(SRC_ACCR_INTEREST_START_DT), 'NULL'), 
          NVL(TO_CHAR(SRC_ACCR_INTEREST_END_DT), 'NULL'), 
          NVL(SRC_FST_CALENDAR_DT_LST, 'NULL'), 
          NVL(SRC_SND_CALENDAR_DT_LST, 'NULL'), 
          NVL(SRC_CALENDAR_DT_MSG, 'NULL'), 
          NVL(TRG_POS_PRODUCT, 'NULL'), 
          NVL(TRG_ASSET_NAME, 'NULL'), 
          NVL(TO_CHAR(TRG_ASSET_PRICE), 'NULL'), 
          NVL(TRG_POS_CURR_CD, 'NULL'), 
          NVL(TO_CHAR(TRG_POS_AMOUNT), 'NULL'), 
          NVL(TO_CHAR(TRG_POS_VALUE_POS_CURR), 'NULL'), 
          NVL(TO_CHAR(TRG_EXCH_RATE), 'NULL'), 
          NVL(TO_CHAR(TRG_POS_VALUE_CHF), 'NULL'), 
          NVL(TO_CHAR(TRG_INTEREST_RATE), 'NULL'), 
          NVL(TO_CHAR(TRG_CUM_INTEREST), 'NULL'), 
          NVL(TO_CHAR(TRG_DEBIT_INTEREST_RATE), 'NULL'), 
          NVL(TO_CHAR(TRG_CUM_DEBIT_INTEREST), 'NULL'), 
          NVL(TRG_INTEREST_FLOW_FRQ_PYR, 'NULL'), 
          NVL(TRG_INTEREST_USAGE, 'NULL'), 
          NVL(TO_CHAR(TRG_ACQUIRE_DT), 'NULL'), 
          NVL(TO_CHAR(TRG_TERM_START_DT), 'NULL'), 
          NVL(TO_CHAR(TRG_TERM_END_DT), 'NULL'), 
          NVL(TRG_DEPOSITARY, 'NULL'), 
          NVL(TRG_PAYBACK_TYPE, 'NULL'), 
          NVL(TRG_PAYBACK_AMOUNT, 'NULL'), 
          NVL(TRG_PAYBACK_PER_YEAR, 'NULL'), 
          NVL(TO_CHAR(TRG_POS_AMOUNT_BLOCKED), 'NULL'), 
          NVL(TRG_POS_BLOCKING_CD, 'NULL'), 
          NVL(TO_CHAR(TRG_CONTRACT_AMOUNT), 'NULL'), 
          NVL(TO_CHAR(TRG_LENDING_VALUE), 'NULL'), 
          NVL(TO_CHAR(TRG_LAND_AREA), 'NULL'), 
          NVL(TRG_POS_BUY_CURR_CD, 'NULL'), 
          NVL(TO_CHAR(TRG_POS_BUY_AMOUNT), 'NULL'), 
          NVL(TRG_POS_SELL_CURR_CD, 'NULL'), 
          NVL(TO_CHAR(TRG_POS_SELL_AMOUNT), 'NULL'), 
          NVL(TO_CHAR(TRG_CUT_OFF_DT), 'NULL'), 
          NVL(TO_CHAR(TRG_ACCR_INTEREST_START_DT), 'NULL'), 
          NVL(TO_CHAR(TRG_ACCR_INTEREST_END_DT), 'NULL'), 
          NVL(TRG_FST_CALENDAR_DT_LST, 'NULL'), 
          NVL(TRG_SND_CALENDAR_DT_LST, 'NULL'), 
          NVL(TRG_CALENDAR_DT_MSG, 'NULL'), 
          NVL(POS_FND_MIGR_ERROR, 'NULL'),
          MATCH_POS_CURR_CD, 
          MATCH_POS_AMOUNT, 
          MATCH_POS_VALUE_POS_CURR, 
          MATCH_POS_VALUE_CHF, 
          MATCH_INTEREST_RATE, 
          MATCH_DEBIT_INTEREST_RATE, 
          MATCH_CUM_INTEREST, 
          MATCH_CUM_DEBIT_INTEREST, 
          MATCH_ACQUIRE_DT, 
          MATCH_PAYBACK_AMOUNT, 
          MATCH_POS_BUY_CURR_CD, 
          MATCH_POS_BUY_AMOUNT, 
          MATCH_POS_SELL_CURR_CD, 
          MATCH_POS_SELL_AMOUNT,
          MATCH_FST_CALENDAR_DT_LST,
          MATCH_SND_CALENDAR_DT_LST
        FROM MFC_POS_TMN_FND 
        WHERE MIGR_RUN_ID = l_pred_run_id
          AND POS_KEY = :NEW.POS_KEY
          AND POS_TYPE = :NEW.POS_TYPE
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
      SELECT FND_ID, POS_FND_COMMENT, POS_FND_SIGN_OFF_FG, POS_FND_BUG_FIX_ITIL_NO, INHERIT_FND_ID, INHERIT_RUN_RANK
      INTO l_pred_fnd_id, l_fnd_comment, l_fnd_sign_off_fg, l_fnd_bug_fix_itil_no, l_root_fnd_id, l_root_run_rank
      FROM MFC_POS_TMN_FND
      WHERE MIGR_RUN_ID = l_pred_run_id
        AND POS_KEY = :NEW.POS_KEY
        AND POS_TYPE = :NEW.POS_TYPE
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

  INSERT INTO MFC_POS_TMN_FND
  ( FND_ID, 
    CLIENT_ID, 
    POS_KEY, 
    POS_TYPE, 
    SRC_POS_PRODUCT, 
    SRC_ASSET_NAME, 
    SRC_ASSET_PRICE, 
    SRC_POS_CURR_CD, 
    SRC_POS_AMOUNT, 
    SRC_POS_VALUE_POS_CURR, 
    SRC_EXCH_RATE, 
    SRC_POS_VALUE_CHF, 
    SRC_INTEREST_RATE, 
    SRC_CUM_INTEREST, 
    SRC_DEBIT_INTEREST_RATE, 
    SRC_CUM_DEBIT_INTEREST, 
    SRC_INTEREST_FLOW_FRQ_PYR, 
    SRC_INTEREST_USAGE, 
    SRC_ACQUIRE_DT, 
    SRC_TERM_START_DT, 
    SRC_TERM_END_DT, 
    SRC_DEPOSITARY, 
    SRC_PAYBACK_TYPE, 
    SRC_PAYBACK_AMOUNT, 
    SRC_PAYBACK_PER_YEAR, 
    SRC_POS_AMOUNT_BLOCKED,
    SRC_POS_BLOCKING_CD,
    SRC_CONTRACT_AMOUNT,
    SRC_LENDING_VALUE,
    SRC_LAND_AREA,
    SRC_POS_BUY_CURR_CD,
    SRC_POS_BUY_AMOUNT,
    SRC_POS_SELL_CURR_CD,
    SRC_POS_SELL_AMOUNT,
    SRC_CUT_OFF_DT,
    SRC_ACCR_INTEREST_START_DT,
    SRC_ACCR_INTEREST_END_DT,
    SRC_FST_CALENDAR_DT_LST,
    SRC_SND_CALENDAR_DT_LST,
    SRC_CALENDAR_DT_MSG,
    TRG_POS_PRODUCT, 
    TRG_ASSET_NAME, 
    TRG_ASSET_PRICE, 
    TRG_POS_CURR_CD, 
    TRG_POS_AMOUNT, 
    TRG_POS_VALUE_POS_CURR, 
    TRG_EXCH_RATE, 
    TRG_POS_VALUE_CHF, 
    TRG_INTEREST_RATE, 
    TRG_CUM_INTEREST, 
    TRG_DEBIT_INTEREST_RATE, 
    TRG_CUM_DEBIT_INTEREST, 
    TRG_INTEREST_FLOW_FRQ_PYR, 
    TRG_INTEREST_USAGE, 
    TRG_ACQUIRE_DT, 
    TRG_TERM_START_DT, 
    TRG_TERM_END_DT, 
    TRG_DEPOSITARY, 
    TRG_PAYBACK_TYPE, 
    TRG_PAYBACK_AMOUNT, 
    TRG_PAYBACK_PER_YEAR, 
    TRG_POS_AMOUNT_BLOCKED,
    TRG_POS_BLOCKING_CD,
    TRG_CONTRACT_AMOUNT,
    TRG_LENDING_VALUE,
    TRG_LAND_AREA,
    TRG_POS_BUY_CURR_CD,
    TRG_POS_BUY_AMOUNT,
    TRG_POS_SELL_CURR_CD,
    TRG_POS_SELL_AMOUNT,
    TRG_CUT_OFF_DT,
    TRG_ACCR_INTEREST_START_DT,
    TRG_ACCR_INTEREST_END_DT,
    TRG_FST_CALENDAR_DT_LST,
    TRG_SND_CALENDAR_DT_LST,
    TRG_CALENDAR_DT_MSG,
    POS_FND_COMMENT, 
    POS_FND_MIGR_ERROR,
    POS_FND_SIGN_OFF_FG, 
    POS_FND_BUG_FIX_ITIL_NO,
    MATCH_POS_CURR_CD, 
    MATCH_POS_AMOUNT, 
    MATCH_POS_VALUE_POS_CURR, 
    MATCH_POS_VALUE_CHF, 
    MATCH_INTEREST_RATE,
    MATCH_DEBIT_INTEREST_RATE, 
    MATCH_CUM_INTEREST, 
    MATCH_CUM_DEBIT_INTEREST, 
    MATCH_ACQUIRE_DT,
    MATCH_PAYBACK_AMOUNT,
    MATCH_POS_BUY_CURR_CD,
    MATCH_POS_BUY_AMOUNT,
    MATCH_POS_SELL_CURR_CD,
    MATCH_POS_SELL_AMOUNT,
    MATCH_FST_CALENDAR_DT_LST,
    MATCH_SND_CALENDAR_DT_LST,
    MIGR_RUN_ID, 
    RCN_PRCS_ID,
    INHERIT_FND_ID,
    INHERIT_RUN_RANK
  ) VALUES 
  ( MFC_RCN_FND_FND_ID_SEQ.NEXTVAL, 
    :new.CLIENT_ID, 
    :new.POS_KEY, 
    :new.POS_TYPE, 
    :new.SRC_POS_PRODUCT, 
    :new.SRC_ASSET_NAME, 
    :new.SRC_ASSET_PRICE, 
    :new.SRC_POS_CURR_CD, 
    :new.SRC_POS_AMOUNT, 
    :new.SRC_POS_VALUE_POS_CURR, 
    :new.SRC_EXCH_RATE, 
    :new.SRC_POS_VALUE_CHF, 
    :new.SRC_INTEREST_RATE, 
    :new.SRC_CUM_INTEREST, 
    :new.SRC_DEBIT_INTEREST_RATE, 
    :new.SRC_CUM_DEBIT_INTEREST, 
    :new.SRC_INTEREST_FLOW_FRQ_PYR, 
    :new.SRC_INTEREST_USAGE, 
    :new.SRC_ACQUIRE_DT, 
    :new.SRC_TERM_START_DT, 
    :new.SRC_TERM_END_DT, 
    :new.SRC_DEPOSITARY, 
    :new.SRC_PAYBACK_TYPE, 
    :new.SRC_PAYBACK_AMOUNT, 
    :new.SRC_PAYBACK_PER_YEAR, 
    :new.SRC_POS_AMOUNT_BLOCKED,
    :new.SRC_POS_BLOCKING_CD,
    :new.SRC_CONTRACT_AMOUNT,
    :new.SRC_LENDING_VALUE,
    :new.SRC_LAND_AREA,
    :new.SRC_POS_BUY_CURR_CD,
    :new.SRC_POS_BUY_AMOUNT,
    :new.SRC_POS_SELL_CURR_CD,
    :new.SRC_POS_SELL_AMOUNT,
    :new.SRC_CUT_OFF_DT,
    :new.SRC_ACCR_INTEREST_START_DT,
    :new.SRC_ACCR_INTEREST_END_DT,
    :new.SRC_FST_CALENDAR_DT_LST,
    :new.SRC_SND_CALENDAR_DT_LST,
    :new.SRC_CALENDAR_DT_MSG,
    :new.TRG_POS_PRODUCT, 
    :new.TRG_ASSET_NAME, 
    :new.TRG_ASSET_PRICE, 
    :new.TRG_POS_CURR_CD, 
    :new.TRG_POS_AMOUNT, 
    :new.TRG_POS_VALUE_POS_CURR, 
    :new.TRG_EXCH_RATE, 
    :new.TRG_POS_VALUE_CHF, 
    :new.TRG_INTEREST_RATE, 
    :new.TRG_CUM_INTEREST, 
    :new.TRG_DEBIT_INTEREST_RATE, 
    :new.TRG_CUM_DEBIT_INTEREST, 
    :new.TRG_INTEREST_FLOW_FRQ_PYR, 
    :new.TRG_INTEREST_USAGE, 
    :new.TRG_ACQUIRE_DT, 
    :new.TRG_TERM_START_DT, 
    :new.TRG_TERM_END_DT, 
    :new.TRG_DEPOSITARY, 
    :new.TRG_PAYBACK_TYPE, 
    :new.TRG_PAYBACK_AMOUNT, 
    :new.TRG_PAYBACK_PER_YEAR, 
    :new.TRG_POS_AMOUNT_BLOCKED,
    :new.TRG_POS_BLOCKING_CD,
    :new.TRG_CONTRACT_AMOUNT,
    :new.TRG_LENDING_VALUE,
    :new.TRG_LAND_AREA,
    :new.TRG_POS_BUY_CURR_CD,
    :new.TRG_POS_BUY_AMOUNT,
    :new.TRG_POS_SELL_CURR_CD,
    :new.TRG_POS_SELL_AMOUNT,
    :new.TRG_CUT_OFF_DT,
    :new.TRG_ACCR_INTEREST_START_DT,
    :new.TRG_ACCR_INTEREST_END_DT,
    :new.TRG_FST_CALENDAR_DT_LST,
    :new.TRG_SND_CALENDAR_DT_LST,
    :new.TRG_CALENDAR_DT_MSG,
    l_fnd_comment,                       -- may get inherited comment rating
    :new.POS_FND_MIGR_ERROR,
    l_fnd_sign_off_fg,                   -- may get inherited sign off flag rating
    l_fnd_bug_fix_itil_no,               -- may get inherited ITIL no of bug fix request rating
    :new.MATCH_POS_CURR_CD, 
    :new.MATCH_POS_AMOUNT, 
    :new.MATCH_POS_VALUE_POS_CURR, 
    :new.MATCH_POS_VALUE_CHF, 
    :new.MATCH_INTEREST_RATE,
    :new.MATCH_DEBIT_INTEREST_RATE, 
    :new.MATCH_CUM_INTEREST, 
    :new.MATCH_CUM_DEBIT_INTEREST, 
    :new.MATCH_ACQUIRE_DT,
    :new.MATCH_PAYBACK_AMOUNT,
    :new.MATCH_POS_BUY_CURR_CD,
    :new.MATCH_POS_BUY_AMOUNT,
    :new.MATCH_POS_SELL_CURR_CD,
    :new.MATCH_POS_SELL_AMOUNT,
    :new.MATCH_FST_CALENDAR_DT_LST,
    :new.MATCH_SND_CALENDAR_DT_LST,
    :new.MIGR_RUN_ID, 
    :new.RCN_PRCS_ID,
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

