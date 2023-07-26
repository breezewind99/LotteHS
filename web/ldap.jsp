<%@ page import="javax.naming.ldap.InitialLdapContext" %>
<%@ page import="javax.naming.ldap.LdapContext" %>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.NamingEnumeration" %>
<%@ page import="javax.naming.AuthenticationException" %>
<%@ page import="com.sun.jndi.toolkit.dir.ContextEnumerator" %>
<%@ page import="javax.naming.NamingException" %>
<%@ page import="javax.naming.directory.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/common/common.jsp" %>
<%
	String ntUserId = "cn=breeze,dc=cnettech,dc=local";//(예: cn=Administrator,cn=admin,dc=admin,dc=com)

	String ntPasswd = "cnet2580";

	String url = "LDAP://192.168.0.118";//(예: LDAP://127.0.0.0)




try {
		Hashtable<String, String> environment = new Hashtable<String, String>();

		environment.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		environment.put(Context.PROVIDER_URL, "LDAP://192.168.0.118");
		environment.put(Context.SECURITY_AUTHENTICATION, "simple");
		environment.put(Context.SECURITY_PRINCIPAL, "uid=user,ou=users,dc=cnettech,dc=local");
		environment.put(Context.SECURITY_CREDENTIALS, "cnet2580");
		DirContext context = new InitialDirContext(environment);
		context.close();
		System.out.println("Active Directory Connection: CONNECTED 1");

		Hashtable<String, String> env = new Hashtable<String, String>();
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		env.put(Context.PROVIDER_URL, "LDAP://192.168.0.118");
		env.put(Context.SECURITY_AUTHENTICATION, "simple");
		env.put(Context.SECURITY_PRINCIPAL, "cn=breeze,dc=cnettech,dc=local");
		env.put(Context.SECURITY_CREDENTIALS, "cnet2580");
		LdapContext ctx = new InitialLdapContext(env, null);

		String usrId   = "user";//------------------------------------(예: test001)
		String usrPw   = "cnet2580";//----------------------(예: test001!)
		String baseRdn = "ou=users,dc=cnettech,dc=local";//----------------예시입니다.

		SearchControls ctls = new SearchControls();
		ctls.setSearchScope(SearchControls.SUBTREE_SCOPE);
		ctls.setReturningAttributes(new String[] {"uid"});
		// 인증이 확인 됬다면 usrId, usrPw, baseRdn(유저가 등록된 위치)으로 Admin에서 등록한 유저를 찾아봅시다!
		String searchFilter = String.format("(uid=%s)", usrId);
		NamingEnumeration results = ctx.search(baseRdn, searchFilter, ctls);
		ctx.close();
		System.out.println("Active Directory Connection: CONNECTED 2");

		Hashtable<String, String> usrEnv = new Hashtable<String, String>();
		usrEnv.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		usrEnv.put(Context.PROVIDER_URL, url);
		usrEnv.put(Context.SECURITY_AUTHENTICATION, "simple");
		usrEnv.put(Context.SECURITY_PRINCIPAL, String.format("%s=%s,%s", "uid", usrId, baseRdn));
		usrEnv.put(Context.SECURITY_CREDENTIALS, usrPw);
		LdapContext user = new InitialLdapContext(usrEnv, null);
		System.out.println("작업 성공");

		// 아래는 Active Directory에서 발생한 에러처리 입니다.

	}catch(AuthenticationException e){

		String msg = e.getMessage();

		if (msg.indexOf("data 525") > 0) {

			System.out.println("사용자를 찾을 수 없음.");

		} else if (msg.indexOf("data 773") > 0) {

			System.out.println("사용자는 암호를 재설정해야합니다.");

		} else if (msg.indexOf("data 52e") > 0) {

			System.out.println("ID와 비밀번호가 일치하지 않습니다.확인 후 다시 시도해 주십시오.");

		} else if (msg.indexOf("data 533") > 0) {

			System.out.println("입력한 ID는 비활성화 상태 입니다.");

		} else if(msg.indexOf("data 532") > 0){

			System.out.println("암호가 만료되었습니다.");

		} else if(msg.indexOf("data 701") > 0){

			System.out.println("AD에서 계정이 만료됨");

		} else {
			System.out.println(msg);
		}

	// 이 부분은 Active Directory와 JAVA가 연결 되지 않을 때의 예외처리입니다. 연결이 안되면 FAILED를 출력합니다.

	}catch(Exception nex){

	System.out.println("Active Directory Connection: FAILED");

	nex.printStackTrace();

	}


%>