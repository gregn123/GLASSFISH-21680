setlocal

set GF_HOME=D:\Users\Nancarrowg\Work\glassfish5\glassfish4
set GF_BIN=%GF_HOME%\glassfish\bin

set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_121

call %GF_BIN%\asadmin deploy TestRAEAR.ear
call %GF_BIN%\asadmin create-connector-connection-pool --raname TestRAEAR#genericra --connectiondefinition javax.jms.ConnectionFactory TestRAPool
call %GF_BIN%\asadmin create-connector-resource --poolname TestRAPool eis/genericra
call %GF_BIN%\asadmin get-client-stubs --appname TestRAEAR client
call "%JAVA_HOME%"\bin\jar xvf TestRAEAR.ear genericra.rar
call "%JAVA_HOME%"\bin\jar xvf genericra.rar genericra.jar


endlocal

