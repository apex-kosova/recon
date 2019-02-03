CREATE OR REPLACE PACKAGE mfr_report_capturing_api AS
   -- ----------------------------------------------------------------------------
   -- Project      : BLUE - Migrationsfabrik
   --
   -- Description  : Package works as API for handling 
   --                Reporting-Information within Migration Process 
   --
   -- Author       : Martin Moll, uex8121
   --
   -- History
   -- V1.3 07.12.2015 MMAR/uex8121   Declaration %TYPE entfernt;
   --                 mfr_compare_process_results erweitert um Program_Name_4
   --
   -- -----------------------------------------------------------------------------
   -- Copyright (c) 2015 Arizon, Raiffeisen Group
   -- All rights reserved.
   --------------------------------------------------------------------------------

  FUNCTION mfr_start_process
    ( v_run_id NUMBER
      , v_program_name VARCHAR2
      , v_process_start_time TIMESTAMP
    ) RETURN INTEGER;
  
  PROCEDURE mfr_report_process_result
    ( v_process_id NUMBER
      , v_result_count NUMBER
    );
  
  PROCEDURE mfr_report_process_finding
    ( v_process_id NUMBER
      , v_finding_description VARCHAR2
      , v_finding_record_key VARCHAR2
      , v_finding_record_count NUMBER
      , v_finding_severity VARCHAR2
      , v_finding_supports_readiness CHAR
    );

  PROCEDURE mfr_report_scope_finding
    ( v_run_id NUMBER
      , v_scope_name VARCHAR2
      , v_scope_supports_readiness CHAR
    );
    
  FUNCTION mfr_compare_process_results
    ( v_run_id NUMBER
      , v_program_name_1 VARCHAR2
      , v_program_name_2 VARCHAR2
      , v_program_name_3 VARCHAR2
      , v_program_name_4 VARCHAR2
    ) RETURN INTEGER;

END mfr_report_capturing_api;
/
grant execute on MFR_REPORT_CAPTURING_API to USR_LOGGING;
grant execute on MFR_REPORT_CAPTURING_API to USR_REPORTING;


