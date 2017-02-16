setlocal

set GF_HOME=D:\Users\Nancarrowg\Work\glassfish5\glassfish4
set JAVA_HOME=c:\Program Files\Java\jdk1.8.0_101

set APPCPATH=genericra.jar
call %GF_HOME%\glassfish\bin\appclient -jar client/TestRAEARClient.jar

endlocal

