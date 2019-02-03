create or replace package body rch_ldap as
 
  function get_data
  ( p_user varchar2, 
    p_password varchar2, 
    p_role_category varchar2, -- e.g. A_2001_MIFABRIK_A_RCH_DQS_
    p_attr varchar2
  ) return varchar2 AS
       
    res_attrs       DBMS_LDAP.STRING_COLLECTION;    -- A String Collection used to specify which
                                                    -- attributes to return from the search.
                                                    
    search_filter   VARCHAR2(512);          -- A simple character string used to store the filter (criteria) 
    res_message     DBMS_LDAP.MESSAGE;      -- Used to store the message (results) of the search.
    temp_entry      DBMS_LDAP.MESSAGE;      -- Used to store entries retrieved from the LDAP search to print out at a later time.
    entry_index     PLS_INTEGER;            -- Used as a counter while looping through each entry.
                                            
    temp_attr_name  VARCHAR2(512);          -- After retrieving an entry from LDAP directory, we will want to walk through all of the returned attributes.
                                            -- This  variable will be used to store each attribute name as we loop through them.
    temp_ber_elmt   DBMS_LDAP.BER_ELEMENT;
    attr_index      PLS_INTEGER;            -- Used as a counter variable for each entry returned for each entry.
    temp_vals       DBMS_LDAP.STRING_COLLECTION;    -- Used to extract, store, and print each of the values from each attribute.
    v_return        VARCHAR2(256) := 'FALSE'; 
  begin
  
    DBMS_LDAP.USE_EXCEPTION := TRUE;
    ldap_passwd  := p_password;      
    
    -- initialize session
    ldap_session := DBMS_LDAP.INIT(ldap_host, ldap_port);    
    
    -- prepare Distinguished Name options
    --dn_rb    := 'CN=' || p_user || ',OU=Users,OU=RB,'  || ldap_baseDN; -- RB users
    --dn_rch   := 'CN=' || p_user || ',OU=Users,OU=RCH,' || ldap_baseDN; -- RCH users
 
    -- use userPrinicpalName instead of DN for simple binding LDAP
    ldap_user := p_user || '@' || ldap_host;
    retval := DBMS_LDAP.SIMPLE_BIND_S(ldap_session, ldap_user, ldap_passwd);
    
    
    -- try to authentice with RB DN first
    -- otherwise try to authenticate with the RCH DN
    -- if both binds fail, an ldap authentication will be raised and the function will return FALSE
    /*    old logic with DN
    begin  
      ldap_user := dn_rb;
      retval := DBMS_LDAP.SIMPLE_BIND_S(ldap_session, ldap_user, ldap_passwd);
    exception when others
    then
      ldap_user := dn_rch;
      retval := DBMS_LDAP.SIMPLE_BIND_S(ldap_session, ldap_user, ldap_passwd);
    end;
    */
        
    -- result attributes which should be returned from search
    res_attrs(1) := 'RFOID-9001-MandNr'; -- (location code)  
    res_attrs(2) := 'displayName';    
    res_attrs(3) := 'memberOf';
    res_attrs(4) := 'initials';

    search_filter   := 'sAMAccountName=' || p_user;

    retval := DBMS_LDAP.SEARCH_S(
          ld         =>  ldap_session
        , base       =>  ldap_baseDN
        , scope      =>  DBMS_LDAP.SCOPE_SUBTREE
        , filter     =>  search_filter
        , attrs      =>  res_attrs
        , attronly   =>  0
        , res        =>  res_message
    );

    -- Retrieve the first entry.
    temp_entry := DBMS_LDAP.FIRST_ENTRY(ldap_session, res_message);
    entry_index := 1;
    
    -- Loop through each of the entries
    -- only return TRUE if a valid ROLE ist found in the memberOf attribute
    while temp_entry is not null loop
        
        temp_attr_name := DBMS_LDAP.FIRST_ATTRIBUTE(
              ldap_session
            , temp_entry
            , temp_ber_elmt
        );
        attr_index := 1;
        while temp_attr_name is not null loop
        
            temp_vals := DBMS_LDAP.GET_VALUES(ldap_session, temp_entry, temp_attr_name);
            if temp_vals.COUNT > 0 then
                for i in temp_vals.first..temp_vals.last loop
                
                  if p_attr = 'LOGIN' then
                   v_return := 'TRUE';
                
                  elsif p_attr is null and temp_attr_name = 'memberOf' and instr(temp_vals(i), 'CN='||p_role_category) > 0 then
                    -- DBMS_OUTPUT.PUT_LINE(RPAD('   Gefundene Rolle:', 25, ' ') || ': ' || SUBSTR(temp_vals(i), 4, instr('CN='||p_role_category||',', ',')-4) || ' / Member Count:' || temp_vals.LAST);
                    v_return := 'TRUE';
                    
                  elsif p_attr = 'LOCATION_CODE' and temp_attr_name = 'RFOID-9001-MandNr' then 
                   v_return := temp_vals(i);
                   
                  elsif p_attr = 'NAME' and temp_attr_name = 'displayName' then 
                   v_return := temp_vals(i);                   
                   
                  elsif p_attr = 'INITIALS' and temp_attr_name = 'initials' then 
                   v_return := temp_vals(i);                   
                   
                  elsif p_attr = 'ROLE' and temp_attr_name = 'memberOf' and instr(temp_vals(i), 'CN='||p_role_category) > 0 then 
                    v_return := substr(temp_vals(i), 4, instr(temp_vals(i), ',')-4);
                    -- return temp_vals(i);
                   
                  end if;
                 
                end loop;
            end if;
            temp_attr_name := DBMS_LDAP.NEXT_ATTRIBUTE(   ldap_session
                                                        , temp_entry
                                                        , temp_ber_elmt);
            attr_index := attr_index + 1;
            
        end loop;

        temp_entry := DBMS_LDAP.NEXT_ENTRY(ldap_session, temp_entry);
        entry_index := entry_index + 1;
    end loop;


    -- Unbind from LDAP directory
    retval := DBMS_LDAP.UNBIND_S(ldap_session);
    
    return v_return;

    exception
        when others then
            --retval := DBMS_LDAP.UNBIND_S(ldap_session);
            --DBMS_OUTPUT.PUT_LINE(' Error code : ' || TO_CHAR(SQLCODE));
            --DBMS_OUTPUT.PUT_LINE(' Error Message : ' || SQLERRM);

            return 'error_' || p_attr;
          
  end get_data;
  
  ------------------------------------------------------------------------------
  
  function login
  ( p_username varchar2, 
    p_password varchar2
  ) return boolean AS
  v_loc      varchar2(40);
  v_role_cat varchar2(400);
  begin
  
  v_loc := get_loc(p_username, p_password);
  
  if v_loc = 'error' then
  return false;  
  elsif get_data(p_user => p_username, 
              p_password => p_password, 
              p_role_category => get_app(v_loc), 
              p_attr => null) = 'TRUE' 
  then return true;
  else return false;
  end if;
  
  end login;  

  ------------------------------------------------------------------------------
  
  function login_simple
  ( p_username varchar2, 
    p_password varchar2
  ) return boolean AS
  v_loc      varchar2(40);
  v_role_cat varchar2(400);
  begin

  if get_data(p_user => p_username, 
              p_password => p_password, 
              p_role_category => null, 
              p_attr => 'LOGIN') = 'TRUE' 
  then return true;
  else return false;
  end if;
  
  end login_simple;  
    
  ------------------------------------------------------------------------------
  
  function get_role
  ( p_user varchar2, 
    p_password varchar2
  ) return varchar2 AS
  v_loc      varchar2(40);
  begin
  
  begin
  v_loc := get_loc(p_user, p_password);
  exception when others then
   return 'get_loc_error';
  end;
  
  return get_data(p_user => p_user, 
                  p_password => p_password, 
                  p_role_category => get_app(v_loc), 
                  p_attr => 'ROLE');
                  
  end get_role;  
  
  ------------------------------------------------------------------------------
  
  function check_role
  ( p_user varchar2, 
    p_password varchar2,
    p_role varchar2
  ) return varchar2 
  AS
  l_role varchar2(200);
  begin
  
  -- dbms_output.put_line (get_app() || '_' || p_role);
  
  l_role := get_data(p_user => p_user, 
                  p_password => p_password, 
                  p_role_category => get_app() || '_' || p_role, 
                  p_attr => 'ROLE');

  return replace(l_role, get_app() || '_');
  
  end check_role;  
  
  ------------------------------------------------------------------------------
  
  function get_loc
  ( p_user varchar2, 
    p_password varchar2
  ) return varchar2 
  AS

  begin
  
  return get_data(p_user => p_user, 
                  p_password => p_password, 
                  p_role_category => null, 
                  p_attr => 'LOCATION_CODE');
  
  end get_loc;  
  
  ------------------------------------------------------------------------------
  
  function get_name
  ( p_user varchar2, 
    p_password varchar2
  ) return varchar2 
  AS

  begin
  
  return get_data(p_user => p_user, 
                  p_password => p_password, 
                  p_role_category => null, 
                  p_attr => 'NAME');
  
  end get_name;  
  
  ------------------------------------------------------------------------------
  
  function get_initials
  ( p_user varchar2, 
    p_password varchar2
  ) return varchar2 
  AS

  begin
  
  return get_data(p_user => p_user, 
                  p_password => p_password, 
                  p_role_category => null, 
                  p_attr => 'INITIALS');
  
  end get_initials;  
  
  ------------------------------------------------------------------------------
  
  function get_app 
  (p_loc varchar2 default c_code_rch)
  return varchar2 
  as
  l_env varchar2(4);
  l_app varchar2(40);
  l_loc_category  varchar2(400);  
  l_return varchar2(400);
  begin
  -- (Development or Production? - XMLOG01=>A / PMLOG01=>P)
  select case when substr(sys_context('userenv','instance_name'),1,1) = 'X' 
  then 'A' else 'P' end
  into l_env from dual;
  
  -- check if User is RB or RCH (loc code 80000) in AD
  if p_loc = c_code_rch then 
  l_loc_category := 'RCH';
  else
  l_loc_category := 'RB';
  end if;
  
  -- get AD Role structure depending on current APEX application and PROD or TEST environment
  l_app := v('APP_ALIAS');
  case
  when l_app = 'DQS'   then return c_ad_base || l_env || '_' || l_loc_category || '_DQS';
  when l_app = 'RECON' then return c_ad_base || l_env || '_' || l_loc_category || '_RECON';
   -- only RCH Users allowed for MFIS application
  when l_app = 'MFIS'  then return c_ad_base || l_env || '_RCH_MFIS';
  
  else return 'none';
  end case;
  
  end get_app;
  
  ------------------------------------------------------------------------------
  
end rch_ldap;
/

