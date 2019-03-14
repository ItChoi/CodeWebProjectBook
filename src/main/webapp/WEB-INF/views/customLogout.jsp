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
	
	<div class="col-md-4 col-md-offset-4">
		<div class="login-panel panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">Logout Page</h3>
			</div>
			
			<div class="panel-body">
				<form role="form" method="post" action="/customLogout">
					<fieldset>
						<a href="index.html" class="btn btn-lg btn-success btn-block">Logout</a>
					</fieldset>
					<input type="hidden" name="${_csrf.parameterName }" value="${_csrf.token }" />
				</form>
			</div>
		</div>
	</div>

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
	<c:if test="${param.logout != null }">
		<script>
			$(document).ready(function() {
				alert("로그아웃하였습니다.");
			});
		</script>
	</c:if>
	
</body>
</html>