create or replace package rch_ldap as

    ldap_host       VARCHAR2(512) := 'ad.raiffeisen.ch'; 
    ldap_port       VARCHAR2(512) := '389'; 
    ldap_baseDN     VARCHAR2(512) := 'DC=ad,DC=raiffeisen,DC=ch';    
    ldap_user       VARCHAR2(512);  
    ldap_passwd     VARCHAR2(512); 
    dn_rb           VARCHAR2(512);
    dn_rch          VARCHAR2(512);   
    retval          PLS_INTEGER := -1;      -- Used for all API return values.
    ldap_session    DBMS_LDAP.SESSION;      -- Used to store the LDAP Session
    
    c_ad_base       CONSTANT VARCHAR2(512) := 'A_2001_MIFABRIK_';
    c_code_rch      CONSTANT VARCHAR2(10)  := '80000';
    
  function get_data
  ( p_user varchar2, 
    p_password varchar2, 
    p_role_category varchar2, -- e.g. A_2001_MIFABRIK_A_RCH_DQS_
    p_attr varchar2
  ) return varchar2;
    
  function login
  ( p_username varchar2, 
    p_password varchar2
  ) return boolean;

  function login_simple
  ( p_username varchar2, 
    p_password varchar2
  ) return boolean;
  
  function get_role
  ( p_user varchar2, 
    p_password varchar2
  ) return varchar2;
  
  function check_role
  ( p_user varchar2, 
    p_password varchar2,
    p_role varchar2
  ) return varchar2;  
  
  function get_loc
  ( p_user varchar2, 
    p_password varchar2
  ) return varchar2;  

  function get_name
  ( p_user varchar2, 
    p_password varchar2
  ) return varchar2;  
  
  function get_initials
  ( p_user varchar2, 
    p_password varchar2
  ) return varchar2;  
  
  function get_app
  ( p_loc varchar2 default c_code_rch
  )   return varchar2;

END rch_ldap;
/

