@echo off
if not exist logs\final mkdir logs\final
docker exec -i mariadb-oracle-mode mariadb -uroot -p%MYPW% -e "DROP DATABASE IF EXISTS hr; CREATE DATABASE hr;"
docker exec -i mariadb-oracle-mode mariadb -uroot -p%MYPW% --force --init-command="SET sql_mode='ORACLE'" hr < sql\mariadb\human_resources_migrated\hr_create.sql 2> logs\final\prereq_create.err
docker exec -i mariadb-oracle-mode mariadb -uroot -p%MYPW% --force --init-command="SET sql_mode='ORACLE'" hr < sql\mariadb\human_resources_migrated\hr_populate.sql 2> logs\final\prereq_populate.err
docker exec -i mariadb-oracle-mode mariadb -uroot -p%MYPW% --force --init-command="SET sql_mode='ORACLE'" hr < sql\mariadb\human_resources_migrated\hr_code.sql 2> logs\final\%1.err
echo Done: logs\final\%1.err
find /c "ERROR" logs\final\%1.err