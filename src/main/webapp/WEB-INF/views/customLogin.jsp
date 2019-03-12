<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>

<!-- Bootstrap Core CSS -->
<link rel="stylesheet" href="/resources/vendor/bootstrap/css/bootstrap.min.css">

<!-- MetisMenu CSS -->
<link rel="stylesheet" href="/resources/vendor/metisMenu/metisMenu.min.css">

<!-- Custom CSS -->
<link rel="stylesheet" href="/resources/dist/css/sb-admin-2.css">

<!-- Custom Fonts -->
<link rel="stylesheet" type="text/css" href="/resources/vendor/font-awesome/css/font-awesome.min.css">


</head>
<body>
	<h1>Custom Login Page</h1>
	<h2><c:out value="${error }" /></h2>
	<h2><c:out value="${logout }" /></h2>

	<form role="form" action="/login" method="post">
		<fieldset>
			<div class="form-group">
				<input class="form-control" placeholder="userid" name="username" type="text" autofocus>
			</div>
		
			<div class="form-group">
				<input class="form-control" placeholder="password" name="password" type="password" value="">
			</div>
			
			<div class="checkbox">
				<label>
					<input name="remember-me" type="checkbox">Remember Me
				</label>
			</div>
		
			<a href="index.html" class="btn btn-lg btn-success btn-block">Login</a>
		</fieldset>
		
		<input type="hidden" name="${_csrf.parameterName }" value="${_csrf.token }" />
	</form>
	
	<!-- jQuery -->
	<script src="/resources/vendor/jquery/jquery.min.js"></script>
	
	<!-- Bootstrap Core JavaScript -->
	<script src="/resources/vendor/bootstrap/js/bootstrap.min.js"></script>
	
	<!-- Metis Menu Plugin JavaScript -->
	<script src="/resources/vendor/metisMenu/metisMenu.min.js"></script>
	
	<!-- Custom Theme JavaScript -->
	<script src="/resources/dist/js/sb-admin-2.js"></script>
	
	<script type="text/javascript">
		$(".btn-success").on("click", function(e) {
			e.preventDefault();
			$("form").submit();
		});
	</script>
	
</body>
</html>