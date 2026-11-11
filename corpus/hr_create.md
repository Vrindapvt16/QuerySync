1. replace all rem to -- using regex for faster replace
^\s*rem\b  --
2. CREATE TABLE regions
    ( region_id      NUMBER 
       CONSTRAINT  region_id_nn NOT NULL 
    , region_name    VARCHAR2(25) 
    );
the CONSTRAINT region_id_nn NOT NULL - was causing an error
and  we replaced all by  NOT NULL

3. 


Step	Change	Errors
1	remove SQL*Plus commands	75
2	remove names from NOT NULL	47
3	remove ORGANIZATION INDEX	44
4	split employees ALTER	44
5	explicit column in emp_manager_fk	43
6-7	remove WITH READ ONLY and COMMENT ON	0
