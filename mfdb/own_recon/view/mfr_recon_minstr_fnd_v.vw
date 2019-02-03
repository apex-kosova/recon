CREATE OR REPLACE FORCE VIEW MFR_RECON_MINSTR_FND_V
(fnd_id, std_fnd_comment, std_fnd_migr_error, std_fnd_sign_off_fg, std_fnd_bug_fix_itil_no, migr_run_id, rcn_prcs_id, src_adr_key, src_bp_key, src_ctn_key, src_macc_key, src_minstr_tmpl, src_mail_action, src_smp_key, match_minstr, trg_adr_key, trg_bp_key, trg_ctn_key, trg_macc_key, trg_minstr_tmpl, trg_mail_action, trg_smp_key, rcn_prgm_name, rcn_scope_type, inherit_fnd_id, inherit_run_rank)
AS
SELECT 
  FND.FND_ID,
  FND.STD_FND_COMMENT,
  FND.STD_FND_MIGR_ERROR,
  FND.STD_FND_SIGN_OFF_FG, 
	FND.STD_FND_BUG_FIX_ITIL_NO,
  FND.MIGR_RUN_ID,
  FND.RCN_PRCS_ID,
  FND.SRC_ADR_KEY,
  FND.SRC_BP_KEY,
  FND.SRC_CTN_KEY,
  FND.SRC_MACC_KEY,
  FND.SRC_MINSTR_TMPL,
  FND.SRC_MAIL_ACTION,
  FND.SRC_SMP_KEY,
  FND.MATCH_MINSTR,
  FND.TRG_ADR_KEY,
  FND.TRG_BP_KEY,
  FND.TRG_CTN_KEY,
  FND.TRG_MACC_KEY,
  FND.TRG_MINSTR_TMPL,
  FND.TRG_MAIL_ACTION,
  FND.TRG_SMP_KEY,
  PRCS.RCN_PRGM_NAME,
  PRCS.RCN_SCOPE_TYP,
  FND.INHERIT_FND_ID,
  FND.INHERIT_RUN_RANK
FROM MFC_MI_FND_V FND
JOIN MFC_RCN_PRCS_V PRCS ON FND.RCN_PRCS_ID = PRCS.RCN_PRCS_ID;

