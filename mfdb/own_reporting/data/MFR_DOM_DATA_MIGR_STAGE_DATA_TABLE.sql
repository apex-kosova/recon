REM INSERTING into OWN_REPORTING.MFR_DOM_DATA_MIGR_STAGE
SET DEFINE OFF;
Insert into OWN_REPORTING.MFR_DOM_DATA_MIGR_STAGE (SHORT_NAME,LONG_NAME) values ('stgtab','data at staging area table');
Insert into OWN_REPORTING.MFR_DOM_DATA_MIGR_STAGE (SHORT_NAME,LONG_NAME) values ('srcsys','data at source system');
Insert into OWN_REPORTING.MFR_DOM_DATA_MIGR_STAGE (SHORT_NAME,LONG_NAME) values ('migtab','data at migration table');
Insert into OWN_REPORTING.MFR_DOM_DATA_MIGR_STAGE (SHORT_NAME,LONG_NAME) values ('trgsys','data at target system');
