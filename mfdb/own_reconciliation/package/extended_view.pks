CREATE OR REPLACE PACKAGE extended_view AUTHID CURRENT_USER AS
   -- oddgen PL/SQL data types
   SUBTYPE string_type IS VARCHAR2(2500 CHAR);
   TYPE t_string IS TABLE OF string_type;
   SUBTYPE param_type IS VARCHAR2(30 CHAR);
   TYPE t_param IS TABLE OF string_type INDEX BY param_type;
 
   FUNCTION get_name RETURN VARCHAR2;
 
   FUNCTION get_description RETURN VARCHAR2;
 
   FUNCTION get_object_types RETURN t_string;
 
   FUNCTION get_object_names(in_object_type IN VARCHAR2) RETURN t_string;
 
   FUNCTION get_params RETURN t_param;
 
   FUNCTION generate(
      in_object_type IN VARCHAR2,
      in_object_name IN VARCHAR2,
      in_params      IN t_param
   ) RETURN CLOB;
END extended_view;
/

