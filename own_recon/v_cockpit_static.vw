create or replace force view v_cockpit_static as
select 
a."MIGR_RUN_ID", "RECON_SCOPE_TYPE", "RECON_SCOPE_GROUP", "RECON_SCOPE_NAME", "RECON_SRC_LOAD_CNT", "RECON_TRG_LOAD_CNT", "RECON_FND_CNT", "RECON_SRC_MAP_MISS_CNT", "RECON_TRG_MAP_MISS_CNT", "RECON_SRC_MISS_CNT", "RECON_TRG_MISS_CNT", "RECON_MISMATCH_CNT", "RECON_ACS_ONLY_CNT", "RECON_MATCH_CNT", "RECON_PROCESS_FINDING", "RUN_ID", "UC4_RUN_ID", "RUN_STATUS", "RUN_START_TIME", "RUN_END_TIME", "JOB_NETWORK_BUILD_ID", "BANK_LOCATION_CODE", "FACTORY_NAME",
max(c.bank_run_id) as bank_run_id, max(v.migr_run_id/v.migr_run_id) as rb_visible,
max((select max(v.member_run_id) 
           from mfr_run_chain_v v 
           inner join mfr_migr_run_v20 m on v.member_run_id =  m.run_id 
           where v.bank_run_id = c.bank_run_id
           and wft_name = 'RECON_STATIC')) as max_run_id
from
(
    select v.*
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'BP' union all
    select v.*
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'CONT' union all
    select v.*
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'PERSON' union all
    select v.*
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'ADDR' union all
    select v.*
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'MACC' union all
    select v.*
    from mfr_recon_scope_fnd_v v where recon_scope_type = 'MINSTR'
) a
  INNER JOIN mfr_migr_run_v13 r ON A.migr_run_id = r.run_id
  INNER JOIN mfr_run_chain_v c ON A.migr_run_id = c.member_run_id 
  left outer join mfc_mr_rcn_rb_visible_v v on v.migr_run_id = c.bank_run_id
  where run_start_time > sysdate-120
  AND   run_status = 'cls'
  GROUP BY
  a.MIGR_RUN_ID, RECON_SCOPE_TYPE, RECON_SCOPE_GROUP, RECON_SCOPE_NAME, RECON_SRC_LOAD_CNT, RECON_TRG_LOAD_CNT, RECON_FND_CNT, RECON_SRC_MAP_MISS_CNT, RECON_TRG_MAP_MISS_CNT, RECON_SRC_MISS_CNT, RECON_TRG_MISS_CNT, RECON_MISMATCH_CNT, RECON_ACS_ONLY_CNT, RECON_MATCH_CNT, RECON_PROCESS_FINDING, RUN_ID, UC4_RUN_ID, RUN_STATUS, RUN_START_TIME, RUN_END_TIME, JOB_NETWORK_BUILD_ID, BANK_LOCATION_CODE, FACTORY_NAME;

