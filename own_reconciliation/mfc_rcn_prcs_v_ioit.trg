CREATE OR REPLACE TRIGGER MFC_RCN_PRCS_V_IOIT
INSTEAD OF INSERT ON MFC_RCN_PRCS_V 
FOR EACH ROW 
BEGIN  
  INSERT INTO MFC_RCN_PRCS 
  ( RCN_PRCS_ID, 
    RCN_PRCS_STATUS, 
    RCN_PRCS_START_TIME, 
    RCN_PRCS_END_TIME, 
    RCN_PRCS_FINDING, 
    MIGR_RUN_ID, 
    RCN_PRGM_NAME, 
    RCN_SCOPE_TYP, 
    RCN_FND_CNT, 
    RCN_NO_CMNT_CNT, 
    RCN_LOAD_CNT, 
    PRCS_TYPE
  )
  VALUES 
  ( MFC_RCN_PRCS_RCN_PRCS_ID_SEQ.NEXTVAL, 
    :new.RCN_PRCS_STATUS, 
    :new.RCN_PRCS_START_TIME, 
    :new.RCN_PRCS_END_TIME, 
    :new.RCN_PRCS_FINDING, 
    :new.MIGR_RUN_ID, 
    :new.RCN_PRGM_NAME, 
    :new.RCN_SCOPE_TYP, 
    :new.RCN_FND_CNT, 
    CASE 
      WHEN :new.PRCS_TYPE IN ('MFCCSDP','MFCCPNP') 
        THEN :new.RCN_FND_CNT -- for check process on static data or position all findings have no comment
      WHEN :new.PRCS_TYPE = 'MFCCGLP' AND :new.RCN_PRGM_NAME IN ('LDG No D2K Mapping','LDG No D2K Account','LDG Mismatch','LDG No ACS Mapping','LDG No ACS Account',
                                                                 'LDG_ALT No D2K Mapping','LDG_ALT No D2K Account','LDG_ALT Mismatch','LDG_ALT No ACS Mapping','LDG_ALT No ACS Account') 
        THEN :new.RCN_FND_CNT -- for check process on general ledger all findings have no comment
      WHEN :new.PRCS_TYPE = 'MFCCGLP' AND :new.RCN_PRGM_NAME IN ('LDG Match','LDG ACS Account Only',
                                                                 'LDG_ALT Match','LDG_ALT ACS Account Only') 
        THEN 0 -- for match or ACS_ONLY check process on general ledger all findings do not need any comment, i.e. no finding has no comment 
      ELSE NULL -- for load process 
    END,
    :new.RCN_LOAD_CNT, 
    :new.PRCS_TYPE
  );
END;
/

