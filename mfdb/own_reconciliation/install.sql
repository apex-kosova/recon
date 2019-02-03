prompt PL/SQL Developer Export User Objects for user OWN_RECONCILIATION@PMLOG01
prompt Created by UEX7250 on Sonntag, 3. Februar 2019
set define off
spool install.log

prompt
prompt Creating table MFC_RCN_PRGM
prompt ===========================
prompt
@@mfc_rcn_prgm.tab
prompt
prompt Creating table MFC_RCN_SCP
prompt ==========================
prompt
@@mfc_rcn_scp.tab
prompt
prompt Creating table MFC_RCN_PRCS
prompt ===========================
prompt
@@mfc_rcn_prcs.tab
prompt
prompt Creating table MFC_ADR_FND
prompt ==========================
prompt
@@mfc_adr_fnd.tab
prompt
prompt Creating table MFC_ADR_TMN_FND
prompt ==============================
prompt
@@mfc_adr_tmn_fnd.tab
prompt
prompt Creating table MFC_BP_FND
prompt =========================
prompt
@@mfc_bp_fnd.tab
prompt
prompt Creating table MFC_BP_POS_FND
prompt =============================
prompt
@@mfc_bp_pos_fnd.tab
prompt
prompt Creating table MFC_BP_TMN_FND
prompt =============================
prompt
@@mfc_bp_tmn_fnd.tab
prompt
prompt Creating table MFC_CLIENT_SAMPLE
prompt ================================
prompt
@@mfc_client_sample.tab
prompt
prompt Creating table MFC_CLIENT_SUBJECT
prompt =================================
prompt
@@mfc_client_subject.tab
prompt
prompt Creating table MFC_CTN_FND
prompt ==========================
prompt
@@mfc_ctn_fnd.tab
prompt
prompt Creating table MFC_CTN_TMN_FND
prompt ==============================
prompt
@@mfc_ctn_tmn_fnd.tab
prompt
prompt Creating table MFC_DOM_LDG_ERR_VAL_TYP
prompt ======================================
prompt
@@mfc_dom_ldg_err_val_typ.tab
prompt
prompt Creating table MFC_DOM_LDG_FND_TYP
prompt ==================================
prompt
@@mfc_dom_ldg_fnd_typ.tab
prompt
prompt Creating table MFC_DOM_RCN_PRCS_TYP
prompt ===================================
prompt
@@mfc_dom_rcn_prcs_typ.tab
prompt
prompt Creating table MFC_DOM_RCN_PRGM_TYP
prompt ===================================
prompt
@@mfc_dom_rcn_prgm_typ.tab
prompt
prompt Creating table MFC_DOM_RCN_SCP_GRP
prompt ==================================
prompt
@@mfc_dom_rcn_scp_grp.tab
prompt
prompt Creating table MFC_DOM_RCN_SCP_TYP
prompt ==================================
prompt
@@mfc_dom_rcn_scp_typ.tab
prompt
prompt Creating table MFC_GUI_HELP
prompt ===========================
prompt
@@mfc_gui_help.tab
prompt
prompt Creating table MFC_KF_FND
prompt =========================
prompt
@@mfc_kf_fnd.tab
prompt
prompt Creating table MFC_LDG_ALT_FND
prompt ==============================
prompt
@@mfc_ldg_alt_fnd.tab
prompt
prompt Creating table MFC_LDG_ALT_MAP
prompt ==============================
prompt
@@mfc_ldg_alt_map.tab
prompt
prompt Creating table MFC_LDG_ERR_VAL
prompt ==============================
prompt
@@mfc_ldg_err_val.tab
prompt
prompt Creating table MFC_LDG_FND
prompt ==========================
prompt
@@mfc_ldg_fnd.tab
prompt
prompt Creating table MFC_LDG_MAP
prompt ==========================
prompt
@@mfc_ldg_map.tab
prompt
prompt Creating table MFC_MACC_FND
prompt ===========================
prompt
@@mfc_macc_fnd.tab
prompt
prompt Creating table MFC_MACC_TMN_FND
prompt ===============================
prompt
@@mfc_macc_tmn_fnd.tab
prompt
prompt Creating table MFC_MI_FND
prompt =========================
prompt
@@mfc_mi_fnd.tab
prompt
prompt Creating table MFC_MI_POS_FND
prompt =============================
prompt
@@mfc_mi_pos_fnd.tab
prompt
prompt Creating table MFC_MISC_ORDER
prompt =============================
prompt
@@mfc_misc_order.tab
prompt
prompt Creating table MFC_MO_FND
prompt =========================
prompt
@@mfc_mo_fnd.tab
prompt
prompt Creating table MFC_MR_RCN_RB_VISIBLE
prompt ====================================
prompt
@@mfc_mr_rcn_rb_visible.tab
prompt
prompt Creating table MFC_POS_FND
prompt ==========================
prompt
@@mfc_pos_fnd.tab
prompt
prompt Creating table MFC_POS_TMN_FND
prompt ==============================
prompt
@@mfc_pos_tmn_fnd.tab
prompt
prompt Creating table MFC_PSN_FND
prompt ==========================
prompt
@@mfc_psn_fnd.tab
prompt
prompt Creating table MFC_PSN_TMN_FND
prompt ==============================
prompt
@@mfc_psn_tmn_fnd.tab
prompt
prompt Creating table MFC_RCN_PRCS_BACKUP_20171022
prompt ===========================================
prompt
@@mfc_rcn_prcs_backup_20171022.tab
prompt
prompt Creating table MFC_SCP_GRP_CLMN
prompt ===============================
prompt
@@mfc_scp_grp_clmn.tab
prompt
prompt Creating table MFC_ZP_FND
prompt =========================
prompt
@@mfc_zp_fnd.tab
prompt
prompt Creating table MFC_ZP_FND_BACKUP_20171022
prompt =========================================
prompt
@@mfc_zp_fnd_backup_20171022.tab
prompt
prompt Creating sequence MFC_CLIENT_SAMPLE_SMPL_ID_SEQ
prompt ===============================================
prompt
@@mfc_client_sample_smpl_id_seq.seq
prompt
prompt Creating sequence MFC_MISC_ORDER_ORDER_ID_SEQ
prompt =============================================
prompt
@@mfc_misc_order_order_id_seq.seq
prompt
prompt Creating sequence MFC_RCN_FND_FND_ID_SEQ
prompt ========================================
prompt
@@mfc_rcn_fnd_fnd_id_seq.seq
prompt
prompt Creating sequence MFC_RCN_PRCS_RCN_PRCS_ID_SEQ
prompt ==============================================
prompt
@@mfc_rcn_prcs_rcn_prcs_id_seq.seq
prompt
prompt Creating view MFC_ADR_FND_V
prompt ===========================
prompt
@@mfc_adr_fnd_v.vw
prompt
prompt Creating view MFC_ADR_TMN_FND_V
prompt ===============================
prompt
@@mfc_adr_tmn_fnd_v.vw
prompt
prompt Creating view MFC_BP_FND_V
prompt ==========================
prompt
@@mfc_bp_fnd_v.vw
prompt
prompt Creating view MFC_BP_POS_FND_V
prompt ==============================
prompt
@@mfc_bp_pos_fnd_v.vw
prompt
prompt Creating view MFC_BP_TMN_FND_V
prompt ==============================
prompt
@@mfc_bp_tmn_fnd_v.vw
prompt
prompt Creating view MFC_CLIENT_SAMPLE_V
prompt =================================
prompt
@@mfc_client_sample_v.vw
prompt
prompt Creating view MFC_CLIENT_SUBJECT_V
prompt ==================================
prompt
@@mfc_client_subject_v.vw
prompt
prompt Creating view MFC_CTN_FND_V
prompt ===========================
prompt
@@mfc_ctn_fnd_v.vw
prompt
prompt Creating view MFC_CTN_TMN_FND_V
prompt ===============================
prompt
@@mfc_ctn_tmn_fnd_v.vw
prompt
prompt Creating view MFC_DOM_LDG_ERR_VAL_TYP_V
prompt =======================================
prompt
@@mfc_dom_ldg_err_val_typ_v.vw
prompt
prompt Creating view MFC_DOM_LDG_FND_TYP_V
prompt ===================================
prompt
@@mfc_dom_ldg_fnd_typ_v.vw
prompt
prompt Creating view MFC_DOM_RCN_PRCS_TYP_V
prompt ====================================
prompt
@@mfc_dom_rcn_prcs_typ_v.vw
prompt
prompt Creating view MFC_DOM_RCN_PRGM_TYP_V
prompt ====================================
prompt
@@mfc_dom_rcn_prgm_typ_v.vw
prompt
prompt Creating view MFC_DOM_RCN_SCP_GRP_V
prompt ===================================
prompt
@@mfc_dom_rcn_scp_grp_v.vw
prompt
prompt Creating view MFC_DOM_RCN_SCP_TYP_V
prompt ===================================
prompt
@@mfc_dom_rcn_scp_typ_v.vw
prompt
prompt Creating view MFC_GUI_HELP_V
prompt ============================
prompt
@@mfc_gui_help_v.vw
prompt
prompt Creating view MFC_KF_FND_V
prompt ==========================
prompt
@@mfc_kf_fnd_v.vw
prompt
prompt Creating view MFC_LDG_ACS_FND_V
prompt ===============================
prompt
@@mfc_ldg_acs_fnd_v.vw
prompt
prompt Creating view MFC_LDG_ALT_ACS_FND_V
prompt ===================================
prompt
@@mfc_ldg_alt_acs_fnd_v.vw
prompt
prompt Creating view MFC_LDG_ALT_D2K_FND_V
prompt ===================================
prompt
@@mfc_ldg_alt_d2k_fnd_v.vw
prompt
prompt Creating view MFC_LDG_ALT_MAP_V
prompt ===============================
prompt
@@mfc_ldg_alt_map_v.vw
prompt
prompt Creating view MFC_LDG_D2K_FND_V
prompt ===============================
prompt
@@mfc_ldg_d2k_fnd_v.vw
prompt
prompt Creating view MFC_LDG_ERR_VAL_V
prompt ===============================
prompt
@@mfc_ldg_err_val_v.vw
prompt
prompt Creating view MFC_LDG_MAP_V
prompt ===========================
prompt
@@mfc_ldg_map_v.vw
prompt
prompt Creating view MFC_MACC_FND_V
prompt ============================
prompt
@@mfc_macc_fnd_v.vw
prompt
prompt Creating view MFC_MACC_TMN_FND_V
prompt ================================
prompt
@@mfc_macc_tmn_fnd_v.vw
prompt
prompt Creating view MFC_MI_FND_V
prompt ==========================
prompt
@@mfc_mi_fnd_v.vw
prompt
prompt Creating view MFC_MI_POS_FND_V
prompt ==============================
prompt
@@mfc_mi_pos_fnd_v.vw
prompt
prompt Creating view MFC_MISC_ORDER_V
prompt ==============================
prompt
@@mfc_misc_order_v.vw
prompt
prompt Creating view MFC_MO_FND_V
prompt ==========================
prompt
@@mfc_mo_fnd_v.vw
prompt
prompt Creating view MFC_MR_RCN_RB_VISIBLE_V
prompt =====================================
prompt
@@mfc_mr_rcn_rb_visible_v.vw
prompt
prompt Creating view MFC_POS_FND_V
prompt ===========================
prompt
@@mfc_pos_fnd_v.vw
prompt
prompt Creating view MFC_POS_TMN_FND_V
prompt ===============================
prompt
@@mfc_pos_tmn_fnd_v.vw
prompt
prompt Creating view MFC_PSN_FND_V
prompt ===========================
prompt
@@mfc_psn_fnd_v.vw
prompt
prompt Creating view MFC_PSN_TMN_FND_V
prompt ===============================
prompt
@@mfc_psn_tmn_fnd_v.vw
prompt
prompt Creating view MFC_RCN_PRCS_V
prompt ============================
prompt
@@mfc_rcn_prcs_v.vw
prompt
prompt Creating view MFC_RCN_PRGM_V
prompt ============================
prompt
@@mfc_rcn_prgm_v.vw
prompt
prompt Creating view MFC_RCN_SCP_V
prompt ===========================
prompt
@@mfc_rcn_scp_v.vw
prompt
prompt Creating view MFC_SCP_GRP_CLMN_V
prompt ================================
prompt
@@mfc_scp_grp_clmn_v.vw
prompt
prompt Creating view MFC_ZP_FND_V
prompt ==========================
prompt
@@mfc_zp_fnd_v.vw
prompt
prompt Creating package EXTENDED_VIEW
prompt ==============================
prompt
@@extended_view.spc
prompt
prompt Creating package MFC_RECON_PURGE
prompt ================================
prompt
@@mfc_recon_purge.spc
prompt
prompt Creating package body EXTENDED_VIEW
prompt ===================================
prompt
@@extended_view.pks
prompt
prompt Creating package body MFC_RECON_PURGE
prompt =====================================
prompt
@@mfc_recon_purge.pks
prompt
prompt Creating trigger MFC_ADR_FND_V_IOIT
prompt ===================================
prompt
@@mfc_adr_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_ADR_FND_V_IOUT
prompt ===================================
prompt
@@mfc_adr_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_ADR_TMN_FND_V_IOIT
prompt =======================================
prompt
@@mfc_adr_tmn_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_ADR_TMN_FND_V_IOUT
prompt =======================================
prompt
@@mfc_adr_tmn_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_BP_FND_V_IOIT
prompt ==================================
prompt
@@mfc_bp_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_BP_FND_V_IOUT
prompt ==================================
prompt
@@mfc_bp_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_BP_POS_FND_V_IOIT
prompt ======================================
prompt
@@mfc_bp_pos_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_BP_POS_FND_V_IOUT
prompt ======================================
prompt
@@mfc_bp_pos_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_BP_TMN_FND_V_IOIT
prompt ======================================
prompt
@@mfc_bp_tmn_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_BP_TMN_FND_V_IOUT
prompt ======================================
prompt
@@mfc_bp_tmn_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_CLIENT_SAMPLE_V_IOIT
prompt =========================================
prompt
@@mfc_client_sample_v_ioit.trg
prompt
prompt Creating trigger MFC_CTN_FND_V_IOIT
prompt ===================================
prompt
@@mfc_ctn_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_CTN_FND_V_IOUT
prompt ===================================
prompt
@@mfc_ctn_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_CTN_TMN_FND_V_IOIT
prompt =======================================
prompt
@@mfc_ctn_tmn_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_CTN_TMN_FND_V_IOUT
prompt =======================================
prompt
@@mfc_ctn_tmn_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_KF_FND_V_IOIT
prompt ==================================
prompt
@@mfc_kf_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_LDG_ACS_FND_V_IOIT
prompt =======================================
prompt
@@mfc_ldg_acs_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_LDG_ACS_FND_V_IOUT
prompt =======================================
prompt
@@mfc_ldg_acs_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_LDG_ALT_ACS_FND_V_IOIT
prompt ===========================================
prompt
@@mfc_ldg_alt_acs_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_LDG_ALT_D2K_FND_V_IOIT
prompt ===========================================
prompt
@@mfc_ldg_alt_d2k_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_LDG_D2K_FND_V_IOIT
prompt =======================================
prompt
@@mfc_ldg_d2k_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_LDG_D2K_FND_V_IOUT
prompt =======================================
prompt
@@mfc_ldg_d2k_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_LDG_ERR_VAL_V_IOIT
prompt =======================================
prompt
@@mfc_ldg_err_val_v_ioit.trg
prompt
prompt Creating trigger MFC_MACC_FND_V_IOIT
prompt ====================================
prompt
@@mfc_macc_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_MACC_FND_V_IOUT
prompt ====================================
prompt
@@mfc_macc_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_MACC_TMN_FND_V_IOIT
prompt ========================================
prompt
@@mfc_macc_tmn_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_MACC_TMN_FND_V_IOUT
prompt ========================================
prompt
@@mfc_macc_tmn_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_MI_FND_V_IOIT
prompt ==================================
prompt
@@mfc_mi_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_MI_FND_V_IOUT
prompt ==================================
prompt
@@mfc_mi_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_MI_POS_FND_V_IOIT
prompt ======================================
prompt
@@mfc_mi_pos_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_MI_POS_FND_V_IOUT
prompt ======================================
prompt
@@mfc_mi_pos_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_MISC_ORDER_V_IOIT
prompt ======================================
prompt
@@mfc_misc_order_v_ioit.trg
prompt
prompt Creating trigger MFC_MO_FND_V_IOIT
prompt ==================================
prompt
@@mfc_mo_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_POS_FND_V_IOIT
prompt ===================================
prompt
@@mfc_pos_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_POS_FND_V_IOUT
prompt ===================================
prompt
@@mfc_pos_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_POS_TMN_FND_V_IOIT
prompt =======================================
prompt
@@mfc_pos_tmn_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_POS_TMN_FND_V_IOUT
prompt =======================================
prompt
@@mfc_pos_tmn_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_PSN_FND_V_IOIT
prompt ===================================
prompt
@@mfc_psn_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_PSN_FND_V_IOUT
prompt ===================================
prompt
@@mfc_psn_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_PSN_TMN_FND_V_IOIT
prompt =======================================
prompt
@@mfc_psn_tmn_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_PSN_TMN_FND_V_IOUT
prompt =======================================
prompt
@@mfc_psn_tmn_fnd_v_iout.trg
prompt
prompt Creating trigger MFC_RCN_PRCS_V_IOIT
prompt ====================================
prompt
@@mfc_rcn_prcs_v_ioit.trg
prompt
prompt Creating trigger MFC_RCN_PRCS_V_IOUT
prompt ====================================
prompt
@@mfc_rcn_prcs_v_iout.trg
prompt
prompt Creating trigger MFC_RCN_SCP_V_IOUT
prompt ===================================
prompt
@@mfc_rcn_scp_v_iout.trg
prompt
prompt Creating trigger MFC_ZP_FND_V_IOIT
prompt ==================================
prompt
@@mfc_zp_fnd_v_ioit.trg
prompt
prompt Creating trigger MFC_ZP_FND_V_IOUT
prompt ==================================
prompt
@@mfc_zp_fnd_v_iout.trg

prompt Done
spool off
set define on
