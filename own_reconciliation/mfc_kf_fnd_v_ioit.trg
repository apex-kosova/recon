CREATE OR REPLACE TRIGGER MFC_KF_FND_V_IOIT
INSTEAD OF INSERT ON MFC_KF_FND_V
FOR EACH ROW 
  BEGIN  
    INSERT INTO MFC_KF_FND
    ( FND_ID, 
    	ACS_ASSET_SUM, 
    	ACS_LIABILITY_SUM, 
    	ACS_MORTGAGE_CLAIM_SUM, 
    	ACS_EBANK_CONTRACT_CNT, 
    	MIGR_RUN_ID, 
    	RCN_PRCS_ID
    ) VALUES 
    ( MFC_RCN_FND_FND_ID_SEQ.NEXTVAL, 
      :new.ACS_ASSET_SUM, 
    	:new.ACS_LIABILITY_SUM, 
    	:new.ACS_MORTGAGE_CLAIM_SUM, 
    	:new.ACS_EBANK_CONTRACT_CNT, 
    	:new.MIGR_RUN_ID, 
    	:new.RCN_PRCS_ID
    );   
  END;
/

