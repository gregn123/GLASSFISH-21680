Appclient embedded-RA accessibility check on RA lookup is incorrect and is bypassed anyway on subsequent lookups


If a Glassfish appclient program invokes an Embedded Resource Adapter, Glassfish performs an accessibility check on lookup() of the RA, to ensure that "only the application that has the embedded resource adapter can access the resource adapter".
Problem is, this check doesn't work properly. For such an application, it causes (the first) lookup() of the RA to fail, reporting that the application is not allowed to access the RA.
Worse, if a subsequent lookup() of the RA is attempted, it works fine (so the check is bypassed anyway).

I believe that this issue has existed in GlassfishV3 onwards.

I have created a JavaEE application that reproduces the problem. I have tried to keep it as simple as possible.

The following files are provided:

TestRAEAR.ear: EAR file which includes appclient program and embedded resource adapter
setup.bat:     Batch file to deploy the application, create necessary RA resources, retrieve client stubs etc.
runclient.bat: Runs the appclient program
cleanup.bat:   Batch file to undeploy the application and cleanup etc.



The client application source code (included within the client in the EAR file) is simply:


import javax.naming.InitialContext;
import javax.jms.ConnectionFactory;

public class Main {
	public static void main(String[] args) {
		ConnectionFactory cf = null;
		try {
			InitialContext context = new InitialContext();
			cf = (ConnectionFactory)context.lookup("eis/genericra");
		} catch (Exception ex) {
			ex.printStackTrace();
			System.exit(1);
		} finally {
			/* nothing, yet */
		}
		return;
	}

	public Main() {
		super();
	}
}




Follow the steps below to reproduce the issue:

1) Edit each of the batch files and make sure GF_HOME and JAVA_HOME are set correctly to match your environment.
2) Make sure that Glassfish application server is running (e.g. "asadmin start-domain")
3) Run "setup.bat"
4) Run "runclient.bat" to run the appclient application. A stacktrace like the following is produced:


javax.naming.CommunicationException: Communication exception for SerialContext[myEnv={java.naming.factory.initial=com.sun.enterprise.naming.impl.SerialInitConte
xtFactory, java.naming.factory.url.pkgs=com.sun.enterprise.naming, java.naming.factory.state=com.sun.corba.ee.impl.presentation.rmi.JNDIStateFactoryImpl} [Root
exception is java.rmi.ServerException: RemoteException occurred in server thread; nested exception is:
        java.rmi.RemoteException: ; nested exception is:
        javax.naming.NamingException: Unable to lookup resource : eis/genericra [Root exception is javax.naming.NamingException: Lookup failed for 'eis/genericr
a' in SerialContext[myEnv={java.naming.factory.initial=com.sun.enterprise.naming.impl.SerialInitContextFactory, java.naming.factory.state=com.sun.corba.ee.impl.
presentation.rmi.JNDIStateFactoryImpl, java.naming.factory.url.pkgs=com.sun.enterprise.naming} [Root exception is javax.naming.NamingException: Only the applica
tion that has the embedded resource adapter [ TestRAEAR#genericra ] can access the resource adapter]]]
        at com.sun.enterprise.naming.impl.SerialContext.lookup(SerialContext.java:513)
        at com.sun.enterprise.naming.impl.SerialContext.lookup(SerialContext.java:438)
        at javax.naming.InitialContext.lookup(InitialContext.java:417)
        at Main.main(Main.java:10)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.glassfish.appclient.client.acc.AppClientContainer.launch(AppClientContainer.java:446)
        at org.glassfish.appclient.client.AppClientFacade.launch(AppClientFacade.java:184)
        at org.glassfish.appclient.client.AppClientGroupFacade.main(AppClientGroupFacade.java:65)
Caused by: java.rmi.ServerException: RemoteException occurred in server thread; nested exception is:
        java.rmi.RemoteException: ; nested exception is:
        javax.naming.NamingException: Unable to lookup resource : eis/genericra [Root exception is javax.naming.NamingException: Lookup failed for 'eis/genericr
a' in SerialContext[myEnv={java.naming.factory.initial=com.sun.enterprise.naming.impl.SerialInitContextFactory, java.naming.factory.state=com.sun.corba.ee.impl.
presentation.rmi.JNDIStateFactoryImpl, java.naming.factory.url.pkgs=com.sun.enterprise.naming} [Root exception is javax.naming.NamingException: Only the applica
tion that has the embedded resource adapter [ TestRAEAR#genericra ] can access the resource adapter]]
        at com.sun.corba.ee.impl.javax.rmi.CORBA.Util.mapSystemException(Util.java:230)
        at com.sun.corba.ee.impl.presentation.rmi.StubInvocationHandlerImpl.privateInvoke(StubInvocationHandlerImpl.java:211)
        at com.sun.corba.ee.impl.presentation.rmi.StubInvocationHandlerImpl.invoke(StubInvocationHandlerImpl.java:150)
        at com.sun.corba.ee.impl.presentation.rmi.codegen.CodegenStubBase.invoke(CodegenStubBase.java:226)
        at com.sun.enterprise.naming.impl._SerialContextProvider_DynamicStub.lookup(com/sun/enterprise/naming/impl/_SerialContextProvider_DynamicStub.java)
        at com.sun.enterprise.naming.impl.SerialContext.lookup(SerialContext.java:478)
        ... 10 more
Caused by: java.rmi.RemoteException: ; nested exception is:
        javax.naming.NamingException: Unable to lookup resource : eis/genericra [Root exception is javax.naming.NamingException: Lookup failed for 'eis/genericr
a' in SerialContext[myEnv={java.naming.factory.initial=com.sun.enterprise.naming.impl.SerialInitContextFactory, java.naming.factory.state=com.sun.corba.ee.impl.
presentation.rmi.JNDIStateFactoryImpl, java.naming.factory.url.pkgs=com.sun.enterprise.naming} [Root exception is javax.naming.NamingException: Only the applica
tion that has the embedded resource adapter [ TestRAEAR#genericra ] can access the resource adapter]]
        at com.sun.enterprise.naming.impl.RemoteSerialContextProviderImpl.lookup(RemoteSerialContextProviderImpl.java:146)
        at sun.reflect.GeneratedMethodAccessor69.invoke(Unknown Source)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at com.sun.corba.ee.impl.presentation.rmi.ReflectiveTie.dispatchToMethod(ReflectiveTie.java:143)
        at com.sun.corba.ee.impl.presentation.rmi.ReflectiveTie._invoke(ReflectiveTie.java:173)
        at com.sun.corba.ee.impl.protocol.ServerRequestDispatcherImpl.dispatchToServant(ServerRequestDispatcherImpl.java:528)
        at com.sun.corba.ee.impl.protocol.ServerRequestDispatcherImpl.dispatch(ServerRequestDispatcherImpl.java:199)
        at com.sun.corba.ee.impl.protocol.MessageMediatorImpl.handleRequestRequest(MessageMediatorImpl.java:1549)
        at com.sun.corba.ee.impl.protocol.MessageMediatorImpl.handleRequest(MessageMediatorImpl.java:1425)
        at com.sun.corba.ee.impl.protocol.MessageMediatorImpl.handleInput(MessageMediatorImpl.java:930)
        at com.sun.corba.ee.impl.protocol.giopmsgheaders.RequestMessage_1_2.callback(RequestMessage_1_2.java:213)
        at com.sun.corba.ee.impl.protocol.MessageMediatorImpl.handleRequest(MessageMediatorImpl.java:694)
        at com.sun.corba.ee.impl.protocol.MessageMediatorImpl.dispatch(MessageMediatorImpl.java:496)
        at com.sun.corba.ee.impl.protocol.MessageMediatorImpl.doWork(MessageMediatorImpl.java:2222)
        at com.sun.corba.ee.impl.threadpool.ThreadPoolImpl$WorkerThread.performWork(ThreadPoolImpl.java:497)
        at com.sun.corba.ee.impl.threadpool.ThreadPoolImpl$WorkerThread.run(ThreadPoolImpl.java:540)
Caused by: javax.naming.NamingException: Unable to lookup resource : eis/genericra [Root exception is javax.naming.NamingException: Lookup failed for 'eis/gener
icra' in SerialContext[myEnv={java.naming.factory.initial=com.sun.enterprise.naming.impl.SerialInitContextFactory, java.naming.factory.state=com.sun.corba.ee.im
pl.presentation.rmi.JNDIStateFactoryImpl, java.naming.factory.url.pkgs=com.sun.enterprise.naming} [Root exception is javax.naming.NamingException: Only the appl
ication that has the embedded resource adapter [ TestRAEAR#genericra ] can access the resource adapter]]
        at org.glassfish.resourcebase.resources.api.ResourceProxy.throwResourceNotFoundException(ResourceProxy.java:113)
        at org.glassfish.resourcebase.resources.api.ResourceProxy.create(ResourceProxy.java:89)
        at com.sun.enterprise.naming.impl.RemoteSerialContextProviderImpl.lookup(RemoteSerialContextProviderImpl.java:137)
        ... 16 more
Caused by: javax.naming.NamingException: Lookup failed for 'eis/genericra' in SerialContext[myEnv={java.naming.factory.initial=com.sun.enterprise.naming.impl.Se
rialInitContextFactory, java.naming.factory.state=com.sun.corba.ee.impl.presentation.rmi.JNDIStateFactoryImpl, java.naming.factory.url.pkgs=com.sun.enterprise.n
aming} [Root exception is javax.naming.NamingException: Only the application that has the embedded resource adapter [ TestRAEAR#genericra ] can access the resou
rce adapter]
        at com.sun.enterprise.naming.impl.SerialContext.lookup(SerialContext.java:491)
        at com.sun.enterprise.naming.impl.SerialContext.lookup(SerialContext.java:438)
        at javax.naming.InitialContext.lookup(InitialContext.java:417)
        at javax.naming.InitialContext.lookup(InitialContext.java:417)
        at org.glassfish.resourcebase.resources.naming.ResourceNamingService.lookup(ResourceNamingService.java:236)
        at org.glassfish.resourcebase.resources.api.ResourceProxy.create(ResourceProxy.java:87)
        ... 17 more
Caused by: javax.naming.NamingException: Only the application that has the embedded resource adapter [ TestRAEAR#genericra ] can access the resource adapter
        at com.sun.enterprise.resource.naming.ConnectorObjectFactory.getObjectInstance(ConnectorObjectFactory.java:123)
        at javax.naming.spi.NamingManager.getObjectInstance(NamingManager.java:321)
        at com.sun.enterprise.naming.impl.SerialContext.getObjectInstance(SerialContext.java:527)
        at com.sun.enterprise.naming.impl.SerialContext.lookup(SerialContext.java:487)
        ... 22 more


5) Run "runclient.bat" to run the appclient application AGAIN. Output like the following is produced (i.e. runs without error):


Mmm DD, 2017 H:MM:SS XX org.hibernate.validator.internal.util.Version <clinit>
INFO: HV000001: Hibernate Validator 5.2.4.Final
Mmm DD, 2017 H:MM:SS XX com.sun.enterprise.connectors.service.ResourceAdapterAdminServiceImpl sendStopToResourceAdapter
INFO: RAR7094: TestRAEAR#genericra shutdown successful.


You can run the application again and again, and it runs without the error seen on the first lookup().

If you stop and restart the application server and re-run the client application, the stacktrace occurs again when it's run the first time.


e.g.

   asadmin restart-domain
   runclient.bat


6) Run "cleanup.bat" to undeploy the application and cleanup etc.



Possible Resolution:

I tracked down the cause of this problem in the app server, to the "checkAccessibility()" method in the "com.sun.enterprise.connectors.service.ConnectorService" class (connectors-runtime.jar). It's checking the classloader of the accessing class against the classloaders in the classloader hierarchy of the parent of the classloader that loaded that RAR file, hoping to find match. I can't see how it could ever find a match (and thus allow access) because we're comparing classloaders used at runtime against those used at deployment. Maybe it used to work on an old version of Glassfish - maybe.
Anyway, it is interesting that there is a commented-out condition in the source code, in the accessibility check:


    public boolean checkAccessibility(String rarName, ClassLoader loader) {
        ActiveResourceAdapter ar = _registry.getActiveResourceAdapter(rarName);
        if (ar != null && loader != null) { // If RA is deployed

            ClassLoader rarLoader = ar.getClassLoader();

            //If the RAR is not standalone.
            if (rarLoader != null && ConnectorAdminServiceUtils.isEmbeddedConnectorModule(rarName)
                /*&& (!(rarLoader instanceof ConnectorClassFinder))*/) {
                ClassLoader rarLoaderParent = rarLoader.getParent();
                ClassLoader parent = loader;
                while (true) {
                ...



If this is uncommented and the class re-built, then the accessibility check succeeds (at least in the case of this test program) and the error doesn't occur.

So, given that the commented-out code should actually be enabled, we have the following patch:



Index: ConnectorService.java
===================================================================
--- ConnectorService.java	(revision 64551)
+++ ConnectorService.java	(working copy)
@@ -43,6 +43,7 @@
 import com.sun.appserv.connectors.internal.api.ConnectorConstants;
 import com.sun.appserv.connectors.internal.api.ConnectorRuntimeException;
 import com.sun.appserv.connectors.internal.api.ConnectorsUtil;
+import com.sun.appserv.connectors.internal.api.ConnectorClassFinder;
 import com.sun.enterprise.config.serverbeans.Resource;
 import com.sun.enterprise.config.serverbeans.ResourcePool;
 import com.sun.enterprise.connectors.ActiveResourceAdapter;
@@ -380,7 +381,7 @@
 
             //If the RAR is not standalone.
             if (rarLoader != null && ConnectorAdminServiceUtils.isEmbeddedConnectorModule(rarName)
-                /*&& (!(rarLoader instanceof ConnectorClassFinder))*/) {
+                && (!(rarLoader instanceof ConnectorClassFinder))) {
                 ClassLoader rarLoaderParent = rarLoader.getParent();
                 ClassLoader parent = loader;
                 while (true) {




I looked back at the history of the ConnectorService class. It seems like the code above was checked-in for GlassfishV3 with the "&& (!(rarLoader instanceof ConnectorClassFinder))" commented-out. No explanation as to why. So it's been like this for a long time.



