setlocal

set GF_HOME=D:\Users\Nancarrowg\Work\glassfish5\glassfish4
set JAVA_HOME=c:\Program Files\Java\jdk1.8.0_101

del genericra.jar
del genericra.rar
rmdir/q/s client

%GF_HOME%\glassfish\bin\asadmin undeploy --cascade=true TestRAEAR

endlocal

