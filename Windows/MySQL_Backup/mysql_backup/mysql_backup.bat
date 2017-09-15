@echo off

REM ------GENERAL SETTINGS-----------------
set mysqlserver=127.0.0.1
set mysqldump="C:\Program Files\FOSS\FossDoc Application server\MySQL\bin\mysqldump.exe"
set databasename=FossDoc
set mysqluser=root
set mysqlpass="123"
set backupfolder=C:\Backup folder

REM ------EMAIL NOTIFICATION SETTINGS------

set youremail=minecraft00z@gmail.com
set emailto=license@fosslook.com
set emailpassword=minecraftnerd

REM ------------------------------------------------

FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET B=%%A

set logfile="log.log"
set gzippath="gzip\gzip"
set dumpfilename="%backupfolder%\%B:~0,4%-%B:~4,2%-%B:~6,2%_%B:~8,2%-%B:~10,2%-%B:~12,2%.sql"

echo %date% %time:~0,8% Starting backup procedure... >> %logfile%
echo %date% %time:~0,8% Creating backup in: %dumpfilename% >> %logfile%

REM if your MySQL user has password, you need to use the following command: 
REM %mysqldump% -h%mysqlserver% -u%mysqluser% -p%mysqlpass% %databasename% -r %dumpfilename%

%mysqldump% -h%mysqlserver% -u%mysqluser% %databasename% -r %dumpfilename%
if errorlevel 1 goto bad

echo %date% %time:~0,8% Archiving backup file... >> %logfile% 
%gzippath% %dumpfilename%
echo %date% %time:~0,8% Finished! >> %logfile%
echo. >> %logfile%


REM ------REMOVING OLD BACKUPS------
forfiles /p "%backupfolder%" /s /m *.gz /D -30 /C "cmd /c del @path"
REM forfiles /p "%backupfolder%" /s /m *.gz /D -30 /C "cmd /c del @path"
exit

:bad
set errormessage="An error occured while creating the backup file!! Error level %errorlevel%"
echo %date% %time:~0,8% %errormessage% >> %logfile%
eventcreate /ID 100 /SO "BackupMySQL" /L APPLICATION /T ERROR /D %errormessage%
echo %date% %time:~0,8% Sending notification email... >> %logfile%
echo. >> %logfile%
sendEmail -o tls=yes -f %youremail% -t %emailto% -s smtp.gmail.com:587 -xu %youremail% -xp %emailpassword% -u "Notification from MySQLBackup" -m %errormessage%

