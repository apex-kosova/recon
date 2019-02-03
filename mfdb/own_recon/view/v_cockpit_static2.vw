create or replace force view v_cockpit_static2 as
select "MIGR_RUN_ID","RECON_SCOPE_TYPE","RECON_SCOPE_GROUP","RECON_SCOPE_NAME","RECON_SRC_LOAD_CNT","RECON_TRG_LOAD_CNT","RECON_FND_CNT","RECON_SRC_MAP_MISS_CNT","RECON_TRG_MAP_MISS_CNT","RECON_SRC_MISS_CNT","RECON_TRG_MISS_CNT","RECON_MISMATCH_CNT","RECON_ACS_ONLY_CNT","RECON_MATCH_CNT","RECON_PROCESS_FINDING","NOT_DOCUMENTED","RUN_ID","UC4_RUN_ID","RUN_STATUS","RUN_START_TIME","RUN_END_TIME","JOB_NETWORK_BUILD_ID","BANK_LOCATION_CODE","FACTORY_NAME" from
    (
    select v.*, (select count(*) from mfr_recon_bp_fnd_v where migr_run_id = v.migr_run_id and std_fnd_migr_error is null) not_documented
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'BP' union all
    select v.*, (select count(*) from mfr_recon_cont_fnd_v where migr_run_id = v.migr_run_id and std_fnd_migr_error is null) not_documented
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'CONT' union all
    select v.*, (select count(*) from mfr_recon_person_fnd_v where migr_run_id = v.migr_run_id and std_fnd_migr_error is null) not_documented
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'PERSON' union all
    select v.*, (select count(*) from mfr_recon_addr_fnd_v where migr_run_id = v.migr_run_id and std_fnd_migr_error is null) not_documented
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'ADDR' union all
    select v.*, (select count(*) from mfr_recon_macc_fnd_v where migr_run_id = v.migr_run_id and std_fnd_migr_error is null) not_documented
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'MACC' union all
    select v.*, (select count(*) from mfr_recon_minstr_fnd_v where migr_run_id = v.migr_run_id and std_fnd_migr_error is null) not_documented
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'MINSTR'
    ) a
    inner join mfr_migr_run_v13 r on  a.migr_run_id = r.run_id
    where run_start_time > sysdate-60
    and   run_status = 'cls';

