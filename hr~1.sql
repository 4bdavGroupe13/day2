-- Déclaration bloc anonyme
set serveroutput on;
DECLARE
    x int := 1;
    CURSOR count_number_tables
    IS
    SELECT count(*)
    FROM user_tables;
    
    CURSOR count_rows 
    IS
    SELECT table_name,
       to_number(ExtractValue(dbms_XMLGen.GetXMLType 
       (
         'select count(*) cnt from ' || user || '.' || table_name
       ),'/ROWSET/ROW/CNT')) as rows_in_table
    FROM user_tables;
    
    name_table CHAR(100);
    nmbr_rows int;
    number_tables int;
BEGIN
    OPEN count_number_tables;
    FETCH count_number_tables INTO number_tables;
    OPEN count_rows;
    LOOP
        FETCH count_rows INTO name_table,nmbr_rows;
        DBMS_OUTPUT.PUT_LINE('Name of table : '||name_table||' Number of rows : '||nmbr_rows);
        x := x + 1;
        EXIT WHEN x > number_tables;
    END LOOP;

END;
/