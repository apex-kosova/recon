-- USER SQL
CREATE USER usr_reconciliation IDENTIFIED BY "usr_reconciliation"  
DEFAULT TABLESPACE "RECON_DATA01"
TEMPORARY TABLESPACE "TEMP";

-- QUOTAS

-- ROLES
GRANT "CONNECT" TO usr_reconciliation ;
ALTER USER usr_reconciliation DEFAULT ROLE "CONNECT";

-- SYSTEM PRIVILEGES
GRANT CREATE VIEW TO usr_reconciliation ;
GRANT CREATE SYNONYM TO usr_reconciliation ;

