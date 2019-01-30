<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>

<div class="bigPictureWrapper">
	<div class="bigPicture">
	
	</div>
</div>

<style>
	.uploadResult {
		width: 100%;
		background-color: gray;
	}
	
	.uploadResult ul {
		display: flex;
		flex-flow: row;
		justify-content: center;
		align-items: center;
	}
	
	.uploadResult ul li {
		list-style: none;
		padding: 10px;
		align-content: center;
		text-align: center;
	}
	
	.uploadResult ul li img {
		width: 100px;
	}
	
	.uploadResult ul li span {
		color: white;
	}
	
	.bigPictureWrapper {
		position: absolute;
		display: none;
		justify-content: center;
		align-items: center;
		top: 0%;
		width: 100%;
		height: 100%;
		background-color: gray;
		z-index: 100;
		background: rgba(255,255,255,0,5);
	}
	
	.bigPicture {
		position: relative;
		display: flex;
		justify-content: center;
		align-items: center;
	}
	
	.bigPicture img {
		width: 600px;
	}
	
</style>

<body>
	<h1>Upload with Ajax</h1>
	<div class="uploadDiv">
		<input type="file" name="uploadFile" multiple>
	</div>
	
	<div class="uploadResult">
		<ul>
		
		</ul>
	</div>
	
	<button id="uploadBtn">Upload</button>
</body>

<script type="text/javascript">

function showImage(fileCallPath) {
	// alert("fileCallPath: " + fileCallPath);
	
	$(".bigPictureWrapper").css("display", "flex").show();
	
	$(".bigPicture").html("<img src='/display?fileName=" + encodeURI(fileCallPath) + "'>")
					.animate({width: "100%", height: "100%"}, 1000);
	
}

$(document).ready(function() {
	var regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
	var maxSize = 5242880; // 5MB
	
	function checkExtenson(fileName, fileSize) {
		if (fileSize >= maxSize) {
			alert("파일 사이즈 초과");
			return false;
		}
		
		if (regex.test(fileName)) {
			alert("해당 종류의 파일은 업로드할 수 없습니다.");
			return false;
		}
		return true;
	}
	
	var cloneObj = $(".uploadDiv").clone();
	
	$("#uploadBtn").on("click", function(e) {
		// jQuery를 이용하는 경우에 파일 업로드는 FormData라는 객체를 이용하게 된다. (브라우저의 제약이 있으므로 주의) - 쉽게 말해 가상의 form 태그와 같다고 생각하면 된다.
		var formData = new FormData();
		var inputFile = $("input[name='uploadFile']");
		var files = inputFile[0].files;
		
		console.log(files);
		
		// add filedate to formdata
		for (var i = 0; i < files.length; i++) {
			if (!checkExtenson(files[i].name, files[i].size)) {
				return false;
			}
			
			formData.append("uploadFile", files[i]);
		}
		
		$.ajax({
			url: "/uploadAjaxAction",
			processData: false,
			contentType: false,
			data: formData,
			type: "POST",
			dataType: "json",
			success: function(result) {
				alert("Uploaded: " + result);
				console.log("result: ", result);
				
				// 응답 결과 보기 - 파일 이름, 썸네일 등
				showUploadedFile(result);
				
				// 파일 초기화
				$(".uploadDiv").html(cloneObj.html());
			}
		});
	
	});
	
	var uploadResult = $(".uploadResult ul");
	
	function showUploadedFile(uploadResultArr) {
		var str = "";
		
		$(uploadResultArr).each(function(i, obj) {
			if (!obj.image) {
				// str += "<li><img src='/resources/img/test-image.jpg'>" + obj.fileName + "</li>";
				var fileCallPath = encodeURIComponent(obj.uploadPath + "/" + obj.uuid + "_" + obj.fileName);
				
				var fileLink = fileCallPath.replace(new RegExp(/\\/g), "/");
				
				str += "<li><div><a href='/download?fileName=" + fileCallPath + "'>"
					 + "<img src='/resources/img/test-image.jpg'>" + obj.fileName 
					 + "</a><span data-file=\'" + fileCallPath + "\' data-type='file'> X </span></div></li>";
			
			} else {
				// encodeURIComponent: GET 방식 첨부 파일의 이름에 포함된 공백 문자나 한글 이름등이 문제가 될 수 있다.
				// -> 이를 수정하기 위해 URI 호출에 적합한 문자열로 인코딩 처리해야한다. (크롬과 IE의 경우 서로 다르게 처리되어 첨부파일에 문제가 생길 수 있다.)
				/* str += "<li>" + obj.fileName + "</li>"; */
				var fileCallPath = encodeURIComponent(obj.uploadPath + "/s_" + obj.uuid + "_" + obj.fileName);
				var originPath = obj.uploadPath + "\\" + obj.uuid + "_" + obj.fileName;
				originPath = originPath.replace(new RegExp(/\\/g), "/");
				
				str += "<li><a href=\"javascript:showImage(\'" + originPath + "\')\"><img src='/display?fileName=" + fileCallPath 
					 + "'></a><span data-file=\'" + fileCallPath + "\' data-type='image'> X </span></li>";
				
			}
		});
		
		uploadResult.append(str);
	}
	
	$(".bigPictureWrapper").on("click", function(e) {
		$(".bigPicture").animate({width: "0%", height: "0%"}, 1000);
		// ES6의 화살표 함수 (=>)는 크롬에서는 정상 작동하지만, IE 11에서는 제대로 동작하지 않는다.
		/* setTimeout(() => {
			$(this).hide();
		}, 1000);  */
		
		setTimeout(function() {
			$(".bigPictureWrapper").hide();
		}, 1000);
		
	});
	
	$(".uploadResult").on("click", "span", function(e) {
		var targetFile = $(this).data("file");
		var type = $(this).data("type");
		console.log(targetFile);
		
		$.ajax({
			url: "/deleteFile",
			data: {
				fileName: targetFile,
				type: type
			},
			dataType: "text",
			type: "POST",
			success: function(result) {
				alert("result: " + result);
			}
		});
	});
	
});
</script>

</html>