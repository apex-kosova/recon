create or replace function l (p_text in varchar2) return varchar2
as
BEGIN
  return lower(p_text);
  
end l;
/

