CREATE OR REPLACE PACKAGE BODY mfr_report_capturing_api AS
   -- ----------------------------------------------------------------------------
   -- Project      : BLUE - Migrationsfabrik
   --
   -- Description  : Package works as API for handling 
   --                Reporting-Information within Migration Process 
   --
   -- Author       : Martin Moll, uex8121
   --
   -- History
   -- V1.1 09.09.2015 MMAR/uex8121   Error No 20000 changed to 20501
   -- V1.3 07.12.2015 MMAR/uex8121   Declaration %TYPE entfernt;
   --                 mfr_compare_process_results erweitert um Program_Name_4
   -- V1.4 11.02.2016 DRGI/uex8120   migration run must exists, but need not be in status 'opn' 
   --                                when mfr_start_process() or mfr_report_scope_finding() is called
   --
   -- -----------------------------------------------------------------------------
   -- Copyright (c) 2015 Arizon, Raiffeisen Group
   -- All rights reserved.
   --------------------------------------------------------------------------------

/******************************************************/

  FUNCTION mfr_start_process
    ( v_run_id NUMBER
      , v_program_name VARCHAR2
      , v_process_start_time TIMESTAMP
    ) RETURN INTEGER IS

    v_counter INTEGER := 0;
    v_process_id mfr_process.process_id%TYPE;
    
    -- Deklaration als autonome Transaktion, da ansonsten Commit- / Rollback-Verhalten des aufrufenden Programms übersteuert wird
    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    -- Checks **********************************************************************
    
    -- RUN_ID, PROGRAM_NAME und PROCESS_START_TIME dürfen nicht leer sein
    IF v_run_id IS NULL
       OR v_program_name IS NULL
       OR v_process_start_time IS NULL
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Fehlender notwendiger Übergabeparameter');
    END IF;

    -- Log-Eintrag muss für diese RUN_ID muss existieren
    SELECT COUNT(*)
    INTO v_counter
    FROM mfl_migr_run_rpt_v v
    WHERE v.run_id = v_run_id;

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Kein Eintrag in Logging-DB für RUN_ID '''||v_run_id||''' gefunden');
    END IF; 
    
    -- Programm Name muss schon bekannt sein
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_program p
    WHERE p.program_name = v_program_name;

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Kein Eintrag in Tabelle MFR_PROGRAM für PROGRAM_NAME '''||v_program_name||''' gefunden');
    END IF; 

    -- Verarbeitung **********************************************************************

    INSERT INTO mfr_process p
      (p.process_id
       , p.process_start_time
       , p.run_id
       , p.program_name
      )
    VALUES
      (mfr_process_process_id_seq.NEXTVAL
       , v_process_start_time
       , v_run_id
       , v_program_name
      )
    RETURNING p.process_id INTO v_process_id;
           
    COMMIT;
    
    RETURN v_process_id;
 
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);
  
  END mfr_start_process;

/******************************************************/

  PROCEDURE mfr_report_process_result
    ( v_process_id NUMBER
      , v_result_count NUMBER
    ) IS

    v_counter INTEGER := 0;
    
    -- Deklaration als autonome Transaktion, da ansonsten Commit- / Rollback-Verhalten des aufrufenden Programms übersteuert wird
    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    -- Checks **********************************************************************

    -- RROCESS_ID und RESULT_COUNT dürfen nicht leer sein
    IF v_process_id IS NULL
       OR v_result_count IS NULL
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Fehlender notwendiger Übergabeparameter');
    END IF;
    
    -- Eintrag in MFR_PROCESS mit dieser PROCESS_ID muss existiern
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_process p
    WHERE p.process_id = v_process_id;

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Kein Eintrag in Tabelle MFR_RUN für PROCESS_ID '''||v_process_id||''' gefunden');
    END IF; 

    -- Zugehöriges PROGRAM muss vom Typ 'MFR_TECH_QLTY_CHK_RST_PROG' sein
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_process o
      , mfr_program p
    WHERE o.process_id = v_process_id
      AND o.program_name = p.program_name
      AND p.program_type = 'MFRRST';

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Zugehöriges Programm ist nicht vom Typ ''MFR_TECH_QLTY_CHK_RST_PROG (MFRRST)''');
    END IF; 
    
    -- Es darf noch kein Eintrag vom Typ 'MFR_TECH_QLTY_CHK_RST_PROG' zu dieser Prozess ID existieren
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_process_result p
    WHERE p.process_id = v_process_id;

    IF v_counter > 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Es darf kein zweites Prozessresultat zu PROCESS_ID '||v_process_id||' erfasst werden');
    END IF; 

    -- Verarbeitung **********************************************************************

    INSERT INTO mfr_process_result p
      (p.result_count
       , p.process_id
      )
    VALUES
      (v_result_count
       , v_process_id
      );
           
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);

  END mfr_report_process_result;

/******************************************************/

  PROCEDURE mfr_report_process_finding
    ( v_process_id NUMBER
      , v_finding_description VARCHAR2
      , v_finding_record_key VARCHAR2
      , v_finding_record_count NUMBER
      , v_finding_severity VARCHAR2
      , v_finding_supports_readiness CHAR
    ) IS

    -- Deklaration als autonome Transaktion, da ansonsten Commit- / Rollback-Verhalten des aufrufenden Programms übersteuert wird
    PRAGMA AUTONOMOUS_TRANSACTION;

    v_counter INTEGER := 0;
    
  BEGIN

    -- Checks **********************************************************************

    -- RROCESS_ID, FINDING_DESCRIPTION, FINDING_SEVERITY und FINDING_SUPPORTS_READINESS dürfen nicht leer sein
    IF v_process_id IS NULL
       OR v_finding_description IS NULL
       OR v_finding_severity IS NULL
       OR v_finding_supports_readiness IS NULL
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Fehlender notwendiger Übergabeparameter');
    END IF;

    -- Genau 1 der beiden Parameter FINDING_RECORD_KEY und FINDING_RECORD_COUNT darf und muss gefüllt sein
    IF (v_finding_record_key IS NOT NULL
        AND v_finding_record_count IS NOT NULL)
      OR (v_finding_record_key IS NULL
        AND v_finding_record_count IS NULL)
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: FINDING_RECORD_KEY und FINDING_RECORD_COUNT schliessen sich gegenseitig aus.Genau 1 dieser Werte muss gesetzt sein');
    END IF;

    -- Eintrag in MFR_PROCESS mit dieser PROCESS_ID muss existiern
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_process p
    WHERE p.process_id = v_process_id;

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Kein Eintrag in Tabelle MFR_PROCESS für PROCESS_ID '''||v_process_id||''' gefunden');
    END IF; 

    -- Zugehöriges PROGRAM muss vom Typ 'MFR_TECH_QLTY_CHK_FND_PROG' sein
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_process o
      , mfr_program p
    WHERE o.process_id = v_process_id
      AND o.program_name = p.program_name
      AND p.program_type = 'MFRFND';

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Zugehöriges Programm ist nicht vom Typ ''MFR_TECH_QLTY_CHK_FND_PROG (MFRFND)''');
    END IF; 

    -- FINDING_SEVERITY muss in Tabelle MFR_DOM_TQC_FINDING_SEVERITY eingetragen sein
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_dom_finding_severity d
    WHERE d.short_name = v_finding_severity;

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Die FINDING_SEVERITY '''||v_finding_severity||''' ist ungültig');
    END IF; 
    
    -- Verarbeitung **********************************************************************

    INSERT INTO mfr_process_finding f
      (f.fnd_id
       , f.fnd_description
       , f.fnd_record_key
       , f.fnd_record_count
       , f.fnd_severity
       , f.fnd_supports_readiness
       , f.process_id
      )
    VALUES
      (mfr_process_finding_fnd_id_seq.NEXTVAL
       , v_finding_description
       , v_finding_record_key
       , v_finding_record_count
       , v_finding_severity
       , v_finding_supports_readiness
       , v_process_id
      );
    
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);

  END mfr_report_process_finding;

/******************************************************/

  PROCEDURE mfr_report_scope_finding
    ( v_run_id NUMBER
      , v_scope_name VARCHAR2
      , v_scope_supports_readiness CHAR
    ) IS

    v_counter INTEGER := 0;
    
    -- Deklaration als autonome Transaktion, da ansonsten Commit- / Rollback-Verhalten des aufrufenden Programms übersteuert wird
    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    -- Checks **********************************************************************

    -- RUN_ID, SCOPE_NAME und SCOPE_SUPPORTS_READINESS dürfen nicht leer sein
    IF v_run_id IS NULL
       OR v_scope_name IS NULL
       OR v_scope_supports_readiness IS NULL
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Fehlender notwendiger Übergabeparameter');
    END IF;

    -- Log-Eintrag muss für diese RUN_ID muss existieren
    SELECT COUNT(*)
    INTO v_counter
    FROM mfl_migr_run_rpt_v v
    WHERE v.run_id = v_run_id;

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Kein Eintrag in Logging-DB für RUN_ID '''||v_run_id||''' gefunden');
    END IF; 

    -- Eintrag in Tabelle MFR_TECH_QLTY_CHK_SCOPE muss existieren
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_tech_qlty_chk_scope t
    WHERE t.scope_name = v_scope_name;

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Der SCOPE_NAME '||v_scope_name||' ist ungültig');
    END IF; 
    
    -- Verarbeitung **********************************************************************

    INSERT INTO mfr_scope_finding
      (scope_supports_readiness
        , run_id
        , scope_name
      )
      VALUES
      (v_scope_supports_readiness
        , v_run_id
        , v_scope_name
      );
    
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);

  END mfr_report_scope_finding;

/******************************************************/

  FUNCTION mfr_compare_process_results
    ( v_run_id NUMBER
      , v_program_name_1 VARCHAR2
      , v_program_name_2 VARCHAR2
      , v_program_name_3 VARCHAR2
      , v_program_name_4 VARCHAR2  -- neu V1.3
    ) RETURN INTEGER IS

    v_counter INTEGER := 0;
    v_scope_name_1 mfr_program.scope_name%TYPE;
    v_scope_name_2 mfr_program.scope_name%TYPE;
    v_scope_name_3 mfr_program.scope_name%TYPE;
    v_scope_name_4 mfr_program.scope_name%TYPE;  -- neu V1.3
    v_result_count_1 mfr_process_result.result_count%TYPE;
    v_result_count_2 mfr_process_result.result_count%TYPE;
    v_result_count_3 mfr_process_result.result_count%TYPE;
    v_result_count_4 mfr_process_result.result_count%TYPE;  -- neu V1.3
    v_data_migration_stage_1 mfr_program.data_migration_stage%TYPE;  -- neu V1.3
    v_data_migration_stage_2 mfr_program.data_migration_stage%TYPE;  -- neu V1.3
    v_data_migration_stage_3 mfr_program.data_migration_stage%TYPE;  -- neu V1.3
    v_data_migration_stage_4 mfr_program.data_migration_stage%TYPE;  -- neu V1.3
    
    -- Deklaration als autonome Transaktion, da ansonsten Commit- / Rollback-Verhalten des aufrufenden Programms übersteuert wird
    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    -- Checks **********************************************************************
    
    -- RUN_ID, PROGRAM_NAME_1 und PROGRAM_NAME_2 dürfen nicht leer sein
    IF v_run_id IS NULL
       OR v_program_name_1 IS NULL
       OR v_program_name_2 IS NULL
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Fehlender notwendiger Übergabeparameter');
    END IF;

    -- Log-Eintrag muss für diese RUN_ID muss existieren
    SELECT COUNT(*)
    INTO v_counter
    FROM mfl_migr_run_rpt_v v
    WHERE v.run_id = v_run_id;

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Kein Eintrag in Logging-DB für RUN_ID '''||v_run_id||''' gefunden');
    END IF; 

    -- Alle übergebenen Programme müssen vom typ 'MFRRST' sein
    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_program p
    WHERE p.program_name = v_program_name_1
      AND p.program_type = 'MFRRST';

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Programm '''||v_program_name_1||''' ist nicht vom Typ ''MFRRST''');
    END IF; 

    SELECT COUNT(*)
    INTO v_counter
    FROM mfr_program p
    WHERE p.program_name = v_program_name_2
      AND p.program_type = 'MFRRST';

    IF v_counter = 0
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Programm '''||v_program_name_2||''' ist nicht vom Typ ''MFRRST''');
    END IF; 
    
    IF v_program_name_3 IS NOT NULL
    THEN
      SELECT COUNT(*)
      INTO v_counter
      FROM mfr_program p
      WHERE p.program_name = v_program_name_3
        AND p.program_type = 'MFRRST';
        
      IF v_counter = 0
      THEN
        ROLLBACK;
        raise_application_error(-20501, 'Fehler: Programm '''||v_program_name_3||''' ist nicht vom Typ ''MFRRST''');
      END IF; 
    END IF;

    IF v_program_name_4 IS NOT NULL  -- neu V1.3
    THEN
      SELECT COUNT(*)
      INTO v_counter
      FROM mfr_program p
      WHERE p.program_name = v_program_name_4
        AND p.program_type = 'MFRRST';
        
      IF v_counter = 0
      THEN
        ROLLBACK;
        raise_application_error(-20501, 'Fehler: Programm '''||v_program_name_4||''' ist nicht vom Typ ''MFRRST''');
      END IF; 
    END IF;
    
    -- Alle Programme müssen zum selben Programmbereich gehören
    BEGIN
      SELECT p.scope_name
      INTO v_scope_name_1
      FROM mfr_program p
      WHERE p.program_name = v_program_name_1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Programm '''||v_program_name_1||''' existiert nicht in Tabelle MFR_PROGRAM');
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);
    END;
    
    BEGIN
      SELECT p.scope_name
      INTO v_scope_name_2
      FROM mfr_program p
      WHERE p.program_name = v_program_name_2;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Programm '''||v_program_name_2||''' existiert nicht in Tabelle MFR_PROGRAM');
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);
    END;
 
    IF v_program_name_3 IS NOT NULL
    THEN
      BEGIN
        SELECT p.scope_name
        INTO v_scope_name_3
        FROM mfr_program p
        WHERE p.program_name = v_program_name_3;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        raise_application_error(-20501, 'Fehler: Programm '''||v_program_name_3||''' existiert nicht in Tabelle MFR_PROGRAM');
      WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);
      END;
    END IF;

    IF v_program_name_4 IS NOT NULL   -- new V 1.3
    THEN
      BEGIN
        SELECT p.scope_name
        INTO v_scope_name_4
        FROM mfr_program p
        WHERE p.program_name = v_program_name_4;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        raise_application_error(-20501, 'Fehler: Programm '''||v_program_name_4||''' existiert nicht in Tabelle MFR_PROGRAM');
      WHEN OTHERS THEN
        ROLLBACK;
        raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);
      END;
    END IF;

    IF v_scope_name_1 <> v_scope_name_2
      OR v_scope_name_1 <> NVL(v_scope_name_3, v_scope_name_1)
      OR v_scope_name_2 <> NVL(v_scope_name_3, v_scope_name_2)
      OR v_scope_name_1 <> NVL(v_scope_name_4, v_scope_name_1)   -- new V 1.3
      OR v_scope_name_2 <> NVL(v_scope_name_4, v_scope_name_2)   -- new V 1.3
      OR NVL(v_scope_name_3,v_scope_name_1) <> NVL(v_scope_name_4,v_scope_name_1)   -- new V 1.3
    THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fehler: Die Programme gehören nicht zum selben Programmbereich');
    END IF;
     
    -- Alle übergebenen Programmnamen müssen unterschiedlichen DATA_MIGRATION_STAGE entsprechen
    -- new V 1.3
    SELECT p.data_migration_stage
    INTO v_data_migration_stage_1
    FROM mfr_program p
    WHERE p.program_name = v_program_name_1;
    
    SELECT p.data_migration_stage
    INTO v_data_migration_stage_2
    FROM mfr_program p
    WHERE p.program_name = v_program_name_2;
    
    IF v_program_name_3 IS NOT NULL
    THEN
       SELECT p.data_migration_stage
       INTO v_data_migration_stage_3
       FROM mfr_program p
       WHERE p.program_name = v_program_name_3;    
    END IF;

    IF v_program_name_4 IS NOT NULL
    THEN
       SELECT p.data_migration_stage
       INTO v_data_migration_stage_4
       FROM mfr_program p
       WHERE p.program_name = v_program_name_4; 
    END IF;

    IF v_data_migration_stage_1 = v_data_migration_stage_2
       OR v_data_migration_stage_1 = NVL(v_data_migration_stage_3,v_data_migration_stage_2)
       OR v_data_migration_stage_1 = NVL(v_data_migration_stage_4,v_data_migration_stage_2)
       OR v_data_migration_stage_2 = NVL(v_data_migration_stage_3,v_data_migration_stage_1)
       OR v_data_migration_stage_2 = NVL(v_data_migration_stage_4,v_data_migration_stage_1)
       OR NVL(v_data_migration_stage_3,v_data_migration_stage_1) = NVL(v_data_migration_stage_4,v_data_migration_stage_2)
    THEN
        ROLLBACK;
        raise_application_error(-20501, 'Fehler: Mindestens 2 Programme stammen nicht aus unterschiedlichen Data Migration Stages''');    
    END IF;
    
    -- Verarbeitung **********************************************************************

    SELECT r.result_count
    INTO v_result_count_1
    FROM mfr_process_result r
      , mfr_process p
    WHERE p.program_name = v_program_name_1
      AND p.run_id = v_run_id
      AND p.process_id = r.process_id;

    SELECT r.result_count
    INTO v_result_count_2
    FROM mfr_process_result r
      , mfr_process p
    WHERE p.program_name = v_program_name_2
      AND p.run_id = v_run_id
      AND p.process_id = r.process_id;

    IF v_program_name_3 IS NOT NULL
    THEN
      SELECT r.result_count
      INTO v_result_count_3
      FROM mfr_process_result r
        , mfr_process p
      WHERE p.program_name = v_program_name_3
        AND p.run_id = v_run_id
        AND p.process_id = r.process_id;
    END IF;

    IF v_program_name_4 IS NOT NULL   -- new V 1.3
    THEN
      SELECT r.result_count
      INTO v_result_count_4
      FROM mfr_process_result r
        , mfr_process p
      WHERE p.program_name = v_program_name_4
        AND p.run_id = v_run_id
        AND p.process_id = r.process_id;
    END IF;

    IF v_result_count_1 = v_result_count_2
      AND  v_result_count_1 = NVL(v_result_count_3, v_result_count_1)
      AND v_result_count_1 = NVL(v_result_count_4, v_result_count_1)   -- new V 1.3
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;    
 
  EXCEPTION
    -- Wenn kein zugehöriger Prozess oder kein Prozess-Result gefunden wird
    -- dann wird der Return-Code "2" zurück gegeben, was so viel heisst
    -- wie "es wurde keine Kennzahl gefunden für mindestens eines der Programme 
    WHEN NO_DATA_FOUND THEN
      RETURN 2;
    WHEN OTHERS THEN
      ROLLBACK;
      raise_application_error(-20501, 'Fatal error. '||SQLCODE||' mit '||SQLERRM);
  
  END mfr_compare_process_results;

/******************************************************/

END mfr_report_capturing_api;
/
grant execute on MFR_REPORT_CAPTURING_API to USR_LOGGING;
grant execute on MFR_REPORT_CAPTURING_API to USR_REPORTING;


