create or replace force view v_cockpit_position as
select
a.MIGR_RUN_ID, RECON_SCOPE_TYPE, RECON_SCOPE_GROUP, RECON_SCOPE_NAME, RECON_SRC_LOAD_CNT, RECON_TRG_LOAD_CNT, RECON_FND_CNT, RECON_SRC_MAP_MISS_CNT, RECON_TRG_MAP_MISS_CNT, RECON_SRC_MISS_CNT, RECON_TRG_MISS_CNT, RECON_MISMATCH_CNT, RECON_ACS_ONLY_CNT, RECON_MATCH_CNT, RECON_PROCESS_FINDING, RUN_ID, UC4_RUN_ID, RUN_STATUS, RUN_START_TIME, RUN_END_TIME, JOB_NETWORK_BUILD_ID, BANK_LOCATION_CODE, FACTORY_NAME,
max(c.bank_run_id) bank_run_id, max(v.migr_run_id/v.migr_run_id) as rb_visible,
max((select max(v.member_run_id) 
           from mfr_run_chain_v v 
           inner join mfr_migr_run_v20 m on v.member_run_id =  m.run_id 
           where v.bank_run_id = c.bank_run_id
           and wft_name = 'RECON_POSTRX')) as max_run_id
from
    (
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'BIMTN' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'BP_POS' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'FXTR' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'REALTY' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'LOAN' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'MINSTR_POS' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'MMKT' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'MMKT_PFAND' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'MMKT_ALM' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'GUARCRED' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'LIMIT' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'OTHSEC' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'POS_SEC' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'POS_SEC_GA' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'POS_SEC_SV' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'POS_MON_AI' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'POS_MON_CF' union ALL
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'POS_MON_OP' union all    
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'POS_MON' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'POS_CERT' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'PROV_IN_SP' union all
    select * from mfr_recon_scope_fnd_v where recon_scope_type = 'REALSEC'
    ) a
    INNER JOIN mfr_migr_run_v13 r ON A.migr_run_id = r.run_id
    INNER JOIN mfr_run_chain_v  c ON A.migr_run_id = c.member_run_id 
    left outer join mfc_mr_rcn_rb_visible_v v on v.migr_run_id = c.bank_run_id
    where RUN_START_TIME > sysdate-120
    AND   run_status = 'cls'
    GROUP BY
    A.MIGR_RUN_ID, RECON_SCOPE_TYPE, RECON_SCOPE_GROUP, RECON_SCOPE_NAME, RECON_SRC_LOAD_CNT, RECON_TRG_LOAD_CNT, RECON_FND_CNT, RECON_SRC_MAP_MISS_CNT, RECON_TRG_MAP_MISS_CNT, RECON_SRC_MISS_CNT, RECON_TRG_MISS_CNT, RECON_MISMATCH_CNT, RECON_ACS_ONLY_CNT, RECON_MATCH_CNT, RECON_PROCESS_FINDING, RUN_ID, UC4_RUN_ID, RUN_STATUS, RUN_START_TIME, RUN_END_TIME, JOB_NETWORK_BUILD_ID, BANK_LOCATION_CODE, FACTORY_NAME;

