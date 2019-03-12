<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>    
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
	<!-- all or member or admin -->
	<h1>/sample/admin page</h1>
	
	<p>principal : <sec:authentication property="principal" /></p>
	<p>MemberVO : <sec:authentication property="principal.member" /></p>
	<p>사용자 이름 : <sec:authentication property="principal.member.userName" /></p>
	<p>사용자 아이디 : <sec:authentication property="principal.username" /></p>
	<p>사용자 권한 리스트 : <sec:authentication property="principal.member.authList" /></p>
	
	
	<a href="/customLogout">Logout</a>
</body>
</html>