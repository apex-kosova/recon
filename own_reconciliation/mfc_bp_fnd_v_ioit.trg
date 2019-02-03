CREATE OR REPLACE TRIGGER MFC_BP_FND_V_IOIT
INSTEAD OF INSERT ON MFC_BP_FND_V
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
        NVL(:new.SRC_CLIENT_ID, 'NULL'), NVL(:new.TRG_CLIENT_ID, 'NULL'), :new.MATCH_CLIENT_ID, NVL(:new.SRC_CLIENT_TYPE, 'NULL'), NVL(:new.TRG_CLIENT_TYPE, 'NULL'), 
        NVL(TO_CHAR(:new.SRC_CLIENT_CREATE_DT), 'NULL'), NVL(TO_CHAR(:new.TRG_CLIENT_CREATE_DT), 'NULL'), :new.MATCH_CLIENT_CREATE_DT, 
        NVL(:new.SRC_FISCAL_DOMICILE, 'NULL'), NVL(:new.TRG_FISCAL_DOMICILE, 'NULL'), :new.MATCH_FISCAL_DOMICILE, NVL(:new.SRC_REF_CURRENCY, 'NULL'), NVL(:new.TRG_REF_CURRENCY, 'NULL'), :new.MATCH_REF_CURRENCY, 
        NVL(TO_CHAR(:new.SRC_NOGA_2008_CD), 'NULL'), NVL(TO_CHAR(:new.TRG_NOGA_2008_CD), 'NULL'), :new.MATCH_NOGA_2008_CD, NVL(TO_CHAR(:new.SRC_BLOCK_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_BLOCK_CNT), 'NULL'), :new.MATCH_BLOCK_CNT, 
        NVL(:new.SRC_BLOCK_DETAIL, 'NULL'), NVL(:new.TRG_BLOCK_DETAIL, 'NULL'), :new.MATCH_BLOCK_DETAIL, NVL(TO_CHAR(:new.SRC_RGSTR_OWN_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_RGSTR_OWN_CNT), 'NULL'), :new.MATCH_RGSTR_OWN_CNT, 
        NVL(TO_CHAR(:new.SRC_ACCNT_OWN_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_ACCNT_OWN_CNT), 'NULL'), :new.MATCH_ACCNT_OWN_CNT, NVL(TO_CHAR(:new.SRC_ACCNT_OWN_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_ACCNT_OWN_CNT), 'NULL'), :new.MATCH_ACCNT_OWN_CNT, 
        NVL(:new.SRC_PRSN_REL_LST, 'NULL'), NVL(:new.TRG_PRSN_REL_LST, 'NULL'), :new.MATCH_PRSN_REL_LST, NVL(TO_CHAR(:new.SRC_ATTORNEY_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_ATTORNEY_CNT), 'NULL'), :new.MATCH_ATTORNEY_CNT,
        NVL(:new.SRC_ATTORNEY_LST, 'NULL'), NVL(:new.TRG_ATTORNEY_LST, 'NULL'), :new.MATCH_ATTORNEY_LST, NVL(TO_CHAR(:new.SRC_SC_FRGN_TAX_DOM_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_FRGN_TAX_DOM_CNT), 'NULL'), :new.MATCH_SC_FRGN_TAX_DOM_CNT,  
        NVL(TO_CHAR(:new.SRC_SC_NMBRD_ACCNT_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_NMBRD_ACCNT_CNT), 'NULL'), :new.MATCH_SC_NMBRD_ACCNT_CNT, NVL(TO_CHAR(:new.SRC_SC_SHELL_CMPNY_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_SHELL_CMPNY_CNT), 'NULL'), :new.MATCH_SC_SHELL_CMPNY_CNT, 
        NVL(TO_CHAR(:new.SRC_SC_XTN_DVRY_XPNS_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_XTN_DVRY_XPNS_CNT), 'NULL'), :new.MATCH_SC_XTN_DVRY_XPNS_CNT, NVL(TO_CHAR(:new.SRC_SC_NO_CNTCT_NWS_CNT), 'NULL'), NVL(TO_CHAR(:new.TRG_SC_NO_CNTCT_NWS_CNT), 'NULL'), :new.MATCH_SC_NO_CNTCT_NWS_CNT, 
        NVL(:new.SRC_SPCL_CNDTN_LST, 'NULL'), NVL(:new.TRG_SPCL_CNDTN_LST, 'NULL'), :new.MATCH_SPCL_CNDTN_LST 
      ) IN 
      ( SELECT 
          NVL(STD_FND_MIGR_ERROR, 'NULL'), 
          NVL(SRC_CLIENT_ID, 'NULL'), NVL(TRG_CLIENT_ID, 'NULL'), MATCH_CLIENT_ID, NVL(SRC_CLIENT_TYPE, 'NULL'), NVL(TRG_CLIENT_TYPE, 'NULL'), 
          NVL(TO_CHAR(SRC_CLIENT_CREATE_DT), 'NULL'), NVL(TO_CHAR(TRG_CLIENT_CREATE_DT), 'NULL'), MATCH_CLIENT_CREATE_DT, 
          NVL(SRC_FISCAL_DOMICILE, 'NULL'), NVL(TRG_FISCAL_DOMICILE, 'NULL'), MATCH_FISCAL_DOMICILE, NVL(SRC_REF_CURRENCY, 'NULL'), NVL(TRG_REF_CURRENCY, 'NULL'), MATCH_REF_CURRENCY, 
          NVL(TO_CHAR(SRC_NOGA_2008_CD), 'NULL'), NVL(TO_CHAR(TRG_NOGA_2008_CD), 'NULL'), MATCH_NOGA_2008_CD, NVL(TO_CHAR(SRC_BLOCK_CNT), 'NULL'), NVL(TO_CHAR(TRG_BLOCK_CNT), 'NULL'), MATCH_BLOCK_CNT, 
          NVL(SRC_BLOCK_DETAIL, 'NULL'), NVL(TRG_BLOCK_DETAIL, 'NULL'), MATCH_BLOCK_DETAIL, NVL(TO_CHAR(SRC_RGSTR_OWN_CNT), 'NULL'), NVL(TO_CHAR(TRG_RGSTR_OWN_CNT), 'NULL'), MATCH_RGSTR_OWN_CNT, 
          NVL(TO_CHAR(SRC_ACCNT_OWN_CNT), 'NULL'), NVL(TO_CHAR(TRG_ACCNT_OWN_CNT), 'NULL'), MATCH_ACCNT_OWN_CNT, NVL(TO_CHAR(SRC_ACCNT_OWN_CNT), 'NULL'), NVL(TO_CHAR(TRG_ACCNT_OWN_CNT), 'NULL'), MATCH_ACCNT_OWN_CNT, 
          NVL(SRC_PRSN_REL_LST, 'NULL'), NVL(TRG_PRSN_REL_LST, 'NULL'), MATCH_PRSN_REL_LST, NVL(TO_CHAR(SRC_ATTORNEY_CNT), 'NULL'), NVL(TO_CHAR(TRG_ATTORNEY_CNT), 'NULL'), MATCH_ATTORNEY_CNT,
          NVL(SRC_ATTORNEY_LST, 'NULL'), NVL(TRG_ATTORNEY_LST, 'NULL'), MATCH_ATTORNEY_LST, NVL(TO_CHAR(SRC_SC_FRGN_TAX_DOM_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_FRGN_TAX_DOM_CNT), 'NULL'), MATCH_SC_FRGN_TAX_DOM_CNT,  
          NVL(TO_CHAR(SRC_SC_NMBRD_ACCNT_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_NMBRD_ACCNT_CNT), 'NULL'), MATCH_SC_NMBRD_ACCNT_CNT, NVL(TO_CHAR(SRC_SC_SHELL_CMPNY_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_SHELL_CMPNY_CNT), 'NULL'), MATCH_SC_SHELL_CMPNY_CNT, 
          NVL(TO_CHAR(SRC_SC_XTN_DVRY_XPNS_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_XTN_DVRY_XPNS_CNT), 'NULL'), MATCH_SC_XTN_DVRY_XPNS_CNT, NVL(TO_CHAR(SRC_SC_NO_CNTCT_NWS_CNT), 'NULL'), NVL(TO_CHAR(TRG_SC_NO_CNTCT_NWS_CNT), 'NULL'), MATCH_SC_NO_CNTCT_NWS_CNT, 
          NVL(SRC_SPCL_CNDTN_LST, 'NULL'), NVL(TRG_SPCL_CNDTN_LST, 'NULL'), MATCH_SPCL_CNDTN_LST 
        FROM MFC_BP_FND 
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
      FROM MFC_BP_FND
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

	INSERT INTO MFC_BP_FND
  ( FND_ID, 
    STD_FND_COMMENT, 
    STD_FND_MIGR_ERROR, 
		STD_FND_SIGN_OFF_FG, 
		STD_FND_BUG_FIX_ITIL_NO,
    MIGR_RUN_ID, 
    RCN_PRCS_ID, 
    BP_KEY, 
    SRC_CLIENT_ID, 
    TRG_CLIENT_ID, 
    MATCH_CLIENT_ID, 
    SRC_CLIENT_TYPE, 
    TRG_CLIENT_TYPE, 
    SRC_CLIENT_CREATE_DT, 
    TRG_CLIENT_CREATE_DT, 
    MATCH_CLIENT_CREATE_DT, 
    SRC_FISCAL_DOMICILE, 
    TRG_FISCAL_DOMICILE, 
    MATCH_FISCAL_DOMICILE, 
    SRC_REF_CURRENCY, 
    TRG_REF_CURRENCY, 
    MATCH_REF_CURRENCY, 
    SRC_NOGA_2008_CD, 
    TRG_NOGA_2008_CD, 
    MATCH_NOGA_2008_CD, 
    SRC_BLOCK_CNT, 
    TRG_BLOCK_CNT, 
    MATCH_BLOCK_CNT, 
    SRC_BLOCK_DETAIL,
    TRG_BLOCK_DETAIL,
    MATCH_BLOCK_DETAIL,
    SRC_RGSTR_OWN_CNT,
    TRG_RGSTR_OWN_CNT,
    MATCH_RGSTR_OWN_CNT,
    SRC_ACCNT_OWN_CNT,
    TRG_ACCNT_OWN_CNT,
    MATCH_ACCNT_OWN_CNT,
    SRC_BNFCL_OWN_CNT,
    TRG_BNFCL_OWN_CNT,
    MATCH_BNFCL_OWN_CNT,
    SRC_PRSN_REL_LST,
    TRG_PRSN_REL_LST,
    MATCH_PRSN_REL_LST,
    SRC_ATTORNEY_CNT,
    TRG_ATTORNEY_CNT,
    MATCH_ATTORNEY_CNT,
    SRC_ATTORNEY_LST,
    TRG_ATTORNEY_LST,
    MATCH_ATTORNEY_LST,
    SRC_SC_FRGN_TAX_DOM_CNT,
    TRG_SC_FRGN_TAX_DOM_CNT,
    MATCH_SC_FRGN_TAX_DOM_CNT,
    SRC_SC_NMBRD_ACCNT_CNT,
    TRG_SC_NMBRD_ACCNT_CNT,
    MATCH_SC_NMBRD_ACCNT_CNT,
    SRC_SC_SHELL_CMPNY_CNT,
    TRG_SC_SHELL_CMPNY_CNT,
    MATCH_SC_SHELL_CMPNY_CNT,
    SRC_SC_XTN_DVRY_XPNS_CNT,
    TRG_SC_XTN_DVRY_XPNS_CNT,
    MATCH_SC_XTN_DVRY_XPNS_CNT,
    SRC_SC_NO_CNTCT_NWS_CNT,
    TRG_SC_NO_CNTCT_NWS_CNT,
    MATCH_SC_NO_CNTCT_NWS_CNT,
    SRC_SPCL_CNDTN_LST,
    TRG_SPCL_CNDTN_LST,
    MATCH_SPCL_CNDTN_LST,
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
    :new.SRC_CLIENT_ID, 
    :new.TRG_CLIENT_ID, 
    :new.MATCH_CLIENT_ID, 
    :new.SRC_CLIENT_TYPE, 
    :new.TRG_CLIENT_TYPE, 
    :new.SRC_CLIENT_CREATE_DT, 
    :new.TRG_CLIENT_CREATE_DT, 
    :new.MATCH_CLIENT_CREATE_DT, 
    :new.SRC_FISCAL_DOMICILE, 
    :new.TRG_FISCAL_DOMICILE, 
    :new.MATCH_FISCAL_DOMICILE, 
    :new.SRC_REF_CURRENCY, 
    :new.TRG_REF_CURRENCY, 
    :new.MATCH_REF_CURRENCY, 
    :new.SRC_NOGA_2008_CD, 
    :new.TRG_NOGA_2008_CD, 
    :new.MATCH_NOGA_2008_CD, 
    :new.SRC_BLOCK_CNT, 
    :new.TRG_BLOCK_CNT, 
    :new.MATCH_BLOCK_CNT, 
    :new.SRC_BLOCK_DETAIL,
    :new.TRG_BLOCK_DETAIL,
    :new.MATCH_BLOCK_DETAIL,
    :new.SRC_RGSTR_OWN_CNT,
    :new.TRG_RGSTR_OWN_CNT,
    :new.MATCH_RGSTR_OWN_CNT,
    :new.SRC_ACCNT_OWN_CNT,
    :new.TRG_ACCNT_OWN_CNT,
    :new.MATCH_ACCNT_OWN_CNT,
    :new.SRC_BNFCL_OWN_CNT,
    :new.TRG_BNFCL_OWN_CNT,
    :new.MATCH_BNFCL_OWN_CNT,
    :new.SRC_PRSN_REL_LST,
    :new.TRG_PRSN_REL_LST,
    :new.MATCH_PRSN_REL_LST,
    :new.SRC_ATTORNEY_CNT,
    :new.TRG_ATTORNEY_CNT,
    :new.MATCH_ATTORNEY_CNT,
    :new.SRC_ATTORNEY_LST,
    :new.TRG_ATTORNEY_LST,
    :new.MATCH_ATTORNEY_LST,
    :new.SRC_SC_FRGN_TAX_DOM_CNT,
    :new.TRG_SC_FRGN_TAX_DOM_CNT,
    :new.MATCH_SC_FRGN_TAX_DOM_CNT,
    :new.SRC_SC_NMBRD_ACCNT_CNT,
    :new.TRG_SC_NMBRD_ACCNT_CNT,
    :new.MATCH_SC_NMBRD_ACCNT_CNT,
    :new.SRC_SC_SHELL_CMPNY_CNT,
    :new.TRG_SC_SHELL_CMPNY_CNT,
    :new.MATCH_SC_SHELL_CMPNY_CNT,
    :new.SRC_SC_XTN_DVRY_XPNS_CNT,
    :new.TRG_SC_XTN_DVRY_XPNS_CNT,
    :new.MATCH_SC_XTN_DVRY_XPNS_CNT,
    :new.SRC_SC_NO_CNTCT_NWS_CNT,
    :new.TRG_SC_NO_CNTCT_NWS_CNT,
    :new.MATCH_SC_NO_CNTCT_NWS_CNT,
    :new.SRC_SPCL_CNDTN_LST,
    :new.TRG_SPCL_CNDTN_LST,
    :new.MATCH_SPCL_CNDTN_LST,
    l_root_fnd_id,                       -- may have a reference to the same finding in a previous RECON run 
    l_root_run_rank                      -- may have a sequence number of a previous RECON run in the same migration, 
                                         -- where the same finding occurs first (root) and get already rated 
  );   
END;
/

