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
