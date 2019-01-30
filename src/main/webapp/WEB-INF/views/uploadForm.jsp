<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
</head>
<body>
	<form action="uploadFormAction" method="post" enctype="multipart/form-data">
		<!-- multiple: input 태그로 한꺼번에 여러 개의 파일을 업로드할 수 있다.
			이 속성은 IE의 경우 10 이상에서만 사용할 수 있다. -->
		<input type="file" name="uploadFile" multiple>
		<button>Submit</button>
	</form>
</body>
</html>