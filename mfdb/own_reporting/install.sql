prompt PL/SQL Developer Export User Objects for user OWN_REPORTING@PMLOG01
prompt Created by UEX7250 on Sonntag, 3. Februar 2019
set define off
spool install.log

prompt
prompt Creating table MFR_DOM_DATA_MIGR_STAGE
prompt ======================================
prompt
@@mfr_dom_data_migr_stage.tab
prompt
prompt Creating table MFR_DOM_FINDING_SEVERITY
prompt =======================================
prompt
@@mfr_dom_finding_severity.tab
prompt
prompt Creating table MFR_DOM_PROGRAM_TYPE
prompt ===================================
prompt
@@mfr_dom_program_type.tab
prompt
prompt Creating table MFR_DOM_TQC_SCOPE_TYPE
prompt =====================================
prompt
@@mfr_dom_tqc_scope_type.tab
prompt
prompt Creating table MFR_SUBJECT_MATTER
prompt =================================
prompt
@@mfr_subject_matter.tab
prompt
prompt Creating table MFR_TECH_QLTY_CHK_SCOPE
prompt ======================================
prompt
@@mfr_tech_qlty_chk_scope.tab
prompt
prompt Creating table MFR_PROGRAM
prompt ==========================
prompt
@@mfr_program.tab
prompt
prompt Creating table MFR_PROCESS
prompt ==========================
prompt
@@mfr_process.tab
prompt
prompt Creating table MFR_PROCESS_FINDING
prompt ==================================
prompt
@@mfr_process_finding.tab
prompt
prompt Creating table MFR_PROCESS_RESULT
prompt =================================
prompt
@@mfr_process_result.tab
prompt
prompt Creating table MFR_SCOPE_FINDING
prompt ================================
prompt
@@mfr_scope_finding.tab
prompt
prompt Creating sequence MFR_PROCESS_FINDING_FND_ID_SEQ
prompt ================================================
prompt
@@mfr_process_finding_fnd_id_seq.seq
prompt
prompt Creating sequence MFR_PROCESS_PROCESS_ID_SEQ
prompt ============================================
prompt
@@mfr_process_process_id_seq.seq
prompt
prompt Creating view MFR_DOM_DATA_MIGR_STAGE_V
prompt =======================================
prompt
@@mfr_dom_data_migr_stage_v.vw
prompt
prompt Creating view MFR_DOM_FINDING_SEVERITY_V
prompt ========================================
prompt
@@mfr_dom_finding_severity_v.vw
prompt
prompt Creating view MFR_DOM_PROGRAM_TYPE_V
prompt ====================================
prompt
@@mfr_dom_program_type_v.vw
prompt
prompt Creating view MFR_DOM_TQC_SCOPE_TYPE_V
prompt ======================================
prompt
@@mfr_dom_tqc_scope_type_v.vw
prompt
prompt Creating view MFR_PROCESS_FINDING_V
prompt ===================================
prompt
@@mfr_process_finding_v.vw
prompt
prompt Creating view MFR_PROCESS_RESULT_V
prompt ==================================
prompt
@@mfr_process_result_v.vw
prompt
prompt Creating view MFR_PROCESS_V
prompt ===========================
prompt
@@mfr_process_v.vw
prompt
prompt Creating view MFR_PROGRAM_V
prompt ===========================
prompt
@@mfr_program_v.vw
prompt
prompt Creating view MFR_SCOPE_FINDING_V
prompt =================================
prompt
@@mfr_scope_finding_v.vw
prompt
prompt Creating view MFR_SUBJECT_MATTER_V
prompt ==================================
prompt
@@mfr_subject_matter_v.vw
prompt
prompt Creating view MFR_TECH_QLTY_CHK_SCOPE_V
prompt =======================================
prompt
@@mfr_tech_qlty_chk_scope_v.vw
prompt
prompt Creating package MFR_REPORT_CAPTURING_API
prompt =========================================
prompt
@@mfr_report_capturing_api.spc
prompt
prompt Creating procedure DELETE_FOR_TESTING
prompt =====================================
prompt
@@delete_for_testing.prc
prompt
prompt Creating package body MFR_REPORT_CAPTURING_API
prompt ==============================================
prompt
@@mfr_report_capturing_api.pks

prompt Done
spool off
set define on
