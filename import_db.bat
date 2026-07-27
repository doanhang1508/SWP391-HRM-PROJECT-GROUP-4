@echo off
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p1234 --default-character-set=utf8mb4 < "database\HRM_database.sql"
echo HRM_database.sql: %errorlevel%
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p1234 hrm_system --default-character-set=utf8mb4 < "database\migration_remove_type6.sql"
echo migration_remove_type6.sql: %errorlevel%
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p1234 hrm_system --default-character-set=utf8mb4 < "database\SQL_gan ca cho nhan vien.sql"
echo SQL_gan_ca: %errorlevel%
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p1234 hrm_system --default-character-set=utf8mb4 < "insert_payroll_may2026.sql"
echo insert_payroll: %errorlevel%
echo DONE!
