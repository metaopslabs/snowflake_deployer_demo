# snowflake_deployer_demo

Demo project for the snowflake-deployer.  Use this script to walk through a sample of the capabilities.


# INITIAL SET UP
#######################################################

Follow the guide below for initial install and config

https://metaopslabs.github.io/snowflake_deployer/set_up/install/

Check out the docs!


# SNOWFLAKE RESET
#######################################################

Only needed to reset a demo already ran

```
USE ROLE INSTANCEADMIN;

DROP DATABASE IF EXISTS DEMO_CONTROL;
DROP DATABASE IF EXISTS DEMO_ANALYTICS;

DROP WAREHOUSE IF EXISTS DEMO_ANALYTICS_WH;
DROP ROLE IF EXISTS DEMO_ACCOUNT_EXEC;
DROP ROLE IF EXISTS DEMO_DATA_ENGINEER;
DROP ROLE IF EXISTS DEMO_HR_MANAGER;
DROP ROLE IF EXISTS DEMO_DOMAIN_HR;
DROP ROLE IF EXISTS DEMO_DOMAIN_SALES;
```


# First Test
#######################################################

1. Copy directory "snowflake_demo_start" to "snowflake" (keep a copy of orig to reset)

2. Look at config files
- deploy_config_demo.yml config
- Jinja references
- jinja variables
- Parrallelization

3. Deploy initial code
snowflake-deployer deploy -c deploy_config_demo.yml

4. 
Run a second time to show objects ignored 

5. 
change a comment somewhere and redeploy to show object 


# Create procedure in Snowflake
#######################################################

1. Run in Snowflake

```
USE ROLE INSTANCEADMIN;

CREATE OR REPLACE PROCEDURE DEMO_CONTROL.CODE.PI() 
RETURNS FLOAT 
LANGUAGE JAVASCRIPT 
COMMENT='some comment to add for this proc' 
EXECUTE AS OWNER AS 
$$
var tst = 2; 
tst += 2; 
return 3.1415926;
$$
;                             ';
```

2. Import Object
snowflake-deployer import -c deploy_config_demo.yml

3. Add tag & grant to procedure

4. Redeploy
snowflake-deployer deploy -c deploy_config_demo.yml



# Create tables & classify
#######################################################

1. Create tables and insert dummy data in Snowflake 

```
--DROP TABLE DEMO_ANALYTICS.HR.EMPLOYEES;
CREATE OR REPLACE TABLE DEMO_ANALYTICS.HR.EMPLOYEES(
    EMPLOYEE_ID int
    , FIRST_NAME text 
    , LAST_NAME text 
    , BIRTH_DATE date 
    , SSN varchar(9) 
    , DEPARTMENT text
    , USERNAME text 
);
INSERT INTO DEMO_ANALYTICS.HR.EMPLOYEES VALUES (1, 'Holly', 'Flax', '1980-08-14','111223333','HR','holly.flax');
INSERT INTO DEMO_ANALYTICS.HR.EMPLOYEES VALUES (2, 'Toby', 'Flenderson', '1990-07-14','222334444','HR', 'toby.flenderson');
INSERT INTO DEMO_ANALYTICS.HR.EMPLOYEES VALUES (3, 'Jim', 'Halper', '1970-09-14','333445555','SALES','jim.halper');
INSERT INTO DEMO_ANALYTICS.HR.EMPLOYEES VALUES (4, 'Dwight', 'Schrute', '2000-02-14','444556666','SALES','dwight.schrute');
INSERT INTO DEMO_ANALYTICS.HR.EMPLOYEES VALUES (5, 'Angela', 'Martin', '1985-01-14','555667777','FINANCE','angela.martin');
INSERT INTO DEMO_ANALYTICS.HR.EMPLOYEES VALUES (6, 'Stanley', 'Hudson', '1987-04-14','666778888','SALES', 'standley.hudson');
INSERT INTO DEMO_ANALYTICS.HR.EMPLOYEES VALUES (7, 'Michael', 'Scott', '1980-06-14','666778888','SALES', 'michael.scott');


-- SALES 
CREATE OR REPLACE TABLE DEMO_ANALYTICS.SALES.TEAM(
    EMPLOYEE_ID int
    , TEAM_NAME string
);
INSERT INTO DEMO_ANALYTICS.SALES.TEAM VALUES (3,'HIGH FIVE');
INSERT INTO DEMO_ANALYTICS.SALES.TEAM VALUES (4,'HIGH FIVE');
INSERT INTO DEMO_ANALYTICS.SALES.TEAM VALUES (7,'FIST BUMP');

CREATE OR REPLACE TABLE DEMO_ANALYTICS.SALES.SALES_ORDER(
    ORDER_ID int
    , SELLER_EMPLOYEE_ID int
    , CLIENT_NAME text 
    , AMT number
);
INSERT INTO DEMO_ANALYTICS.SALES.SALES_ORDER VALUES (1,3,'Donna Smith',45);
INSERT INTO DEMO_ANALYTICS.SALES.SALES_ORDER VALUES (2,3,'Jack Johnson',50);
INSERT INTO DEMO_ANALYTICS.SALES.SALES_ORDER VALUES (3,4,'Brett Favre',24);
INSERT INTO DEMO_ANALYTICS.SALES.SALES_ORDER VALUES (4,4,'Jane Doe',55);
INSERT INTO DEMO_ANALYTICS.SALES.SALES_ORDER VALUES (5,6,'Carol Foster',25);
INSERT INTO DEMO_ANALYTICS.SALES.SALES_ORDER VALUES (6,6,'Dan Bennett',43);
```

2. Import objects
snowflake-deployer import -c deploy_config_demo.yml

3. Classify objects
snowflake-deployer classify -c deploy_config_demo.yml

4. Deploy objects
snowflake-deployer deploy -c deploy_config_demo.yml

5. Confirm tags deployed
SELECT get_ddl('table','DEMO_ANALYTICS.SALES.TEAM');

6. Change tags Snowflake side
ALTER TABLE DEMO_ANALYTICS.SALES.TEAM ALTER COLUMN EMPLOYEE_ID UNSET TAG DEMO_CONTROL.GOVERNANCE.SENSITIVITY;
ALTER TABLE DEMO_ANALYTICS.SALES.TEAM ALTER COLUMN TEAM_NAME UNSET TAG DEMO_CONTROL.GOVERNANCE.SENSITIVITY;
ALTER TABLE DEMO_ANALYTICS.SALES.TEAM ALTER COLUMN TEAM_NAME UNSET TAG DEMO_CONTROL.GOVERNANCE.SEMANTIC;
ALTER TABLE DEMO_ANALYTICS.SALES.TEAM ALTER COLUMN TEAM_NAME UNSET TAG DEMO_CONTROL.GOVERNANCE.CLASSIFICATION_CATEGORY;
ALTER TABLE DEMO_ANALYTICS.SALES.TEAM ALTER COLUMN TEAM_NAME UNSET TAG DEMO_CONTROL.GOVERNANCE.CLASSIFICATION_CATEGORY;

SELECT get_ddl('table','DEMO_ANALYTICS.SALES.TEAM');

7. Run deployer (will detect changes occured in Snowflake)

snowflake-deployer deploy -c deploy_config_demo.yml

8. Config tags re-applied
SELECT get_ddl('table','DEMO_ANALYTICS.SALES.TEAM');
