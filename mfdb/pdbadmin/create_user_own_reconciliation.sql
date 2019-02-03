-- USER SQL
CREATE USER own_reconciliation IDENTIFIED BY "own_reconciliation"  
DEFAULT TABLESPACE "RECON_DATA01"
TEMPORARY TABLESPACE "TEMP";

-- QUOTAS
ALTER USER own_reconciliation QUOTA UNLIMITED ON RECON_DATA01;

-- ROLES
GRANT "CONNECT" TO own_reconciliation ;
GRANT "ROL_OWNER" TO own_reconciliation ;
ALTER USER own_reconciliation DEFAULT ROLE "CONNECT","ROL_OWNER";

-- SYSTEM PRIVILEGES
GRANT CREATE JOB TO own_reconciliation ;
GRANT DEBUG CONNECT SESSION TO own_reconciliation ;
GRANT DEBUG ANY PROCEDURE TO own_reconciliation ;
GRANT CREATE DATABASE LINK TO own_reconciliation ;
GRANT DROP PUBLIC SYNONYM TO own_reconciliation ;

