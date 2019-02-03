CREATE OR REPLACE PROCEDURE recon_check_jobs
  IS
    c_dqs_id_apex constant number(6) := 1200;
    c_mail_from   constant varchar(200) := 'recon@arizon.ch'; 
    v_mail_body    varchar2(32000);
    
    v_errors_found boolean := FALSE;
  
    cursor c_job_errors is
      select to_char(log_date, 'DD.MM.RR HH24:MI') log_date, job_name, status, additional_info
      from user_scheduler_job_run_details 
      where actual_start_date > trunc(sysdate)
      and status = 'FAILED';

begin
  -- set APEX security group before using apex_mail package
  for s1 in (select workspace_id from apex_applications where application_id = c_dqs_id_apex)
  loop
     apex_util.set_security_group_id(p_security_group_id => s1.workspace_id);
  end loop;

  for r1 in c_job_errors
  loop
    v_errors_found := TRUE;
    v_mail_body := v_mail_body || r1.log_date || ' - ' || r1.job_name || ' - ' || r1.status || '</br> Fehler: </br>' || r1.additional_info || '</br> </br>';
  end loop;
    
  if v_errors_found
  then
  apex_mail.send(
            p_to        => 'jochen.zehe@@arizon.ch',
            p_cc        => 'gisbert.droege@arizon.ch',            
            p_from      => c_mail_from,
            p_subj      => 'RECON DB Job Status - Failed Job Runs',
            p_body      => null,
            p_body_html => v_mail_body
            );
   -- send all mails in the queue immediately
    apex_mail.push_queue;
    
   end if; 
        
END recon_check_jobs;
/

