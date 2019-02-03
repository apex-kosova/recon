CREATE OR REPLACE TRIGGER MFC_MO_FND_V_IOIT
INSTEAD OF INSERT ON MFC_MO_FND_V
FOR EACH ROW 
  BEGIN  
    INSERT INTO MFC_MO_FND
    ( FND_ID,
      ORDER_RESULT_FG,
	    ITIL_TICKET_IF_FAILED,
      ORDER_COMMENT,
      ORDER_CHECK_BY,
      ORDER_CHECK_DT,
      MIGR_RUN_ID,
      ORDER_ID,
      RCN_PRCS_ID
    ) VALUES 
    ( MFC_RCN_FND_FND_ID_SEQ.NEXTVAL, 
      :new.ORDER_RESULT_FG,
	    :new.ITIL_TICKET_IF_FAILED,
      :new.ORDER_COMMENT,
      :new.ORDER_CHECK_BY,
      :new.ORDER_CHECK_DT,
      :new.MIGR_RUN_ID,
      :new.ORDER_ID,
      :new.RCN_PRCS_ID
    );   
  END;
/

