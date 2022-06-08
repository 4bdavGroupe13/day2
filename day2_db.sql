--Exo 1
--Q1
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

--Q2
set serveroutput on;
DECLARE
    CURSOR count_number_rows
    IS
    SELECT count(EMPLOYEES.EMPLOYEE_ID) as number_employee_manager
    FROM EMPLOYEES
    JOIN JOBS ON JOBS.JOB_ID = EMPLOYEES.JOB_ID
    WHERE JOBS.JOB_TITLE like '%Manager%';
    
    nmbr_rows int;
BEGIN
    OPEN count_number_rows;
    FETCH count_number_rows INTO nmbr_rows;
    DBMS_OUTPUT.PUT_LINE('Nombre employe manager : '||nmbr_rows);
END;
/

--Q3
set serveroutput on;
DECLARE      
	nbr_total_emp INTEGER; -- Nombre total d’employés      
	nbr_man INTEGER;       -- Nombre de managers      
	percent_man REAL;      -- Proportion de managers     
BEGIN      
	SELECT COUNT(*) INTO nbr_total_emp FROM EMPLOYEES;   
	
	SELECT COUNT(*) INTO nbr_man FROM EMPLOYEES 
    JOIN JOBS ON JOBS.JOB_ID = EMPLOYEES.JOB_ID
    WHERE JOBS.JOB_TITLE like '%Manager%';      
	percent_man := ROUND((100 * nbr_man / nbr_total_emp),2);      
	DBMS_OUTPUT.PUT_LINE('La proportion de managers est : ' || percent_man || ' % sur '|| nbr_total_emp || ' employés'); 
END;

--Exo 2
set serveroutput on;
DECLARE
    x int := 1;
    CURSOR count_number_objects
    IS
    SELECT count(*)
    FROM user_objects
    WHERE object_type = 'VIEW' or object_type = 'TABLE';
    
    CURSOR list_object_table_and_view 
    IS
    SELECT object_name, object_type 
    FROM user_objects
    WHERE object_type = 'VIEW' or object_type = 'TABLE';
    
    object_name CHAR(100);
    object_type CHAR(100);
    number_objects int;
BEGIN
    OPEN count_number_objects;
    FETCH count_number_objects INTO number_objects;
    OPEN list_object_table_and_view;
    LOOP
        FETCH list_object_table_and_view INTO object_name,object_type;
        DBMS_OUTPUT.PUT_LINE('L objet : '||object_name||'est de type '||object_type);
        x := x + 1;
        EXIT WHEN x > number_objects;
    END LOOP;

END;
/

--Exo 3
set serveroutput on;
DECLARE
    r_idVOL int;
    r_date_heure_depart Date;
    r_date_heure_arrivee Date;
    r_ville_depart varchar2(100);
    r_ville_arrivee varchar2(100);
BEGIN
    INSERT INTO VOL(date_heure_depart, date_heure_arrivee,ville_depart,ville_arrivee) VALUES
    (TO_DATE('10:15:00','HH:MI:SS'),TO_DATE('12:15:00','HH:MI:SS'),'Rome','Paris');
    DBMS_OUTPUT.PUT_LINE('Values Inserted');
    SELECT idVOL,date_heure_depart, date_heure_arrivee,ville_depart,ville_arrivee INTO r_idVOL,r_date_heure_depart, r_date_heure_arrivee,r_ville_depart,r_ville_arrivee FROM VOL WHERE ROWNUM<=1;
    DBMS_OUTPUT.PUT_LINE('Numéro du vol :'||r_idVOL);
    DBMS_OUTPUT.PUT_LINE('Date de départ :'||r_date_heure_depart);
    DBMS_OUTPUT.PUT_LINE('Date d''arrivee :'||r_date_heure_arrivee);
    DBMS_OUTPUT.PUT_LINE('Ville de départ :'||r_ville_depart);
    DBMS_OUTPUT.PUT_LINE('Ville d''arrivee :'||r_ville_arrivee);
END;
/

--Exo 4
-- Q1
set serveroutput on;
DECLARE
    CURSOR salaire_moyen
    IS
    SELECT AVG(SALAIRE)
    FROM PILOTES
    WHERE AGE BETWEEN 45 and 55;
    
    salary_mean NUMERIC;
BEGIN
    OPEN salaire_moyen;
    FETCH salaire_moyen INTO salary_mean;
    DBMS_OUTPUT.PUT_LINE('Le salaire moyen est :'||salary_mean);
END;
/
-- Q2
set serveroutput on;
DECLARE
    x int := 1;
    CURSOR count_pilotes
    IS
    SELECT count(*)
    FROM PILOTES;
    CURSOR salaire_annuel
    IS
    SELECT matricule,nom,(SALAIRE*12) as salaire_annuel
    FROM PILOTES;
    
    matricule VARCHAR2(100);
    nom VARCHAR2(100);
    salary_year NUMERIC;
    number_of_rows int;
BEGIN
    OPEN count_pilotes;
    FETCH count_pilotes INTO number_of_rows;
    OPEN salaire_annuel;
    LOOP
        FETCH salaire_annuel INTO matricule, nom, salary_year;
        DBMS_OUTPUT.PUT_LINE('Le salaire annuel de '||nom||' avec le matricule '||matricule||' est de: '||salary_year);
        x := x+1;
        EXIT WHEN x > number_of_rows;
    END LOOP;
END;
/

--Exo 5
-- Q1
create or replace PROCEDURE f_augmentation_salaire (p_pourcentage numeric,p_employee_id employees.employee_id%TYPE)
AS
BEGIN
    UPDATE EMPLOYEES SET SALARY = SALARY * (p_pourcentage/100)
    WHERE employee_id = p_employee_id;
END;
/

-- Q2
create or replace PROCEDURE f_modifier_manager (p_manager_id departments.manager_id%TYPE,p_department_id departments.department_id%TYPE)
AS
BEGIN
    UPDATE DEPARTMENTS SET manager_id = p_manager_id
    WHERE department_id = p_department_id;
END;
/

-- Q3
create or replace type medianAndMean as object(v_salaire_moyen number, v_median number);
create or replace type type_medianAndMean is table of medianAndMean ;
create or replace FUNCTION f_return_salaire_moyen_median (p_department_id departments.department_id%TYPE)
RETURN type_medianAndMean
AS
    result_median_and_mean type_medianAndMean;
BEGIN
    SELECT medianAndMean(avg(salary),median(salary)) bulk collect into result_median_and_mean
    FROM EMPLOYEES
    WHERE department_id = p_department_id
    ;
RETURN result_median_and_mean;

END;
/

--Exo 6
-- Q1
create or replace TRIGGER baisse_salaire BEFORE
UPDATE OF salary ON employees
FOR EACH ROW
WHEN (new. salary< old. salary)
BEGIN 
    raise_application_error(-20002, 'Le salaire ne peut pas baisser ') ;
END ;
/

-- Q2
create or replace TRIGGER virer_manager BEFORE
UPDATE OF MANAGER_ID ON DEPARTMENTS
FOR EACH ROW
WHEN (new.MANAGER_ID = NULL)
DECLARE
    name_department varchar2(30);
BEGIN 
    name_department := :new.DEPARTMENT_NAME;
    raise_application_error(-20002, 'Le manager du département: '||name_department||' va être viré.');
END ;
/

    