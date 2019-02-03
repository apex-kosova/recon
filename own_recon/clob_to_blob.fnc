create or replace function clob_to_blob (p_clob in clob) return blob
as
 l_returnvalue   blob;
 l_dest_offset   integer := 1;
 l_source_offset integer := 1;
 l_lang_context  integer := dbms_lob.default_lang_ctx;
 l_warning       integer := dbms_lob.warn_inconvertible_char;
BEGIN

  /*
  Purpose: convert clob to blob
  */
  dbms_lob.createtemporary (l_returnvalue, true);
  
  dbms_lob.converttoblob
  (
   dest_lob    => l_returnvalue,
   src_clob    => p_clob,
   amount      => dbms_lob.getlength(p_clob),
   dest_offset => l_dest_offset,
   src_offset  => l_source_offset,
   blob_csid   => dbms_lob.default_csid,
   lang_context=> l_lang_context,
   warning     => l_warning
  );

  return l_returnvalue;
  
end clob_to_blob;
/

