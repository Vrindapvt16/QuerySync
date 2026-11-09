@echo off
docker exec -i mariadb-oracle-mode mariadb -uroot -p%MYPW% -e "DROP DATABASE IF EXISTS hr; CREATE DATABASE hr;"
docker exec -i mariadb-oracle-mode mariadb -uroot -p%MYPW% --force --init-command="SET sql_mode='ORACLE'" hr < sql\mariadb\human_resources_migrated\hr_create.sql 2> logs\%1.err
echo Done: logs\%1.err
find /c "ERROR" logs\%1.err