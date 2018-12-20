<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../includes/header.jsp" %>

<div class="row">
	<div class="col-lg-12">
		<h1 class="page-header">Board Register</h1>
	</div>
</div>

<div class="row">
	<div class="col-lg-12">
		<div class="panel panel-default">
			<div class="panel-heading">Board Read Page</div>
			<div class="panel-body">
				
				<form role="form" action="/board/modify" method="post">
					<input type="hidden" name="pageNum" value="<c:out value='${cri.pageNum }'/>">
					<input type="hidden" name="amount" value="<c:out value='${cri.amount }'/>">
					<input type="hidden" name="keyword" value="<c:out value='${cri.keyword }'/>">
					<input type="hidden" name="type" value="<c:out value='${cri.type }'/>">
					
					<div class="form-group">
						<label>Bno</label>
						<input class="form-control" name="bno" value="${board.bno }" readonly>
					</div>
					<div class="form-group">
						<label>Title</label>
						<input class="form-control" name="title" value="${board.title }">
					</div>
					<div class="form-group">
						<label>Text area</label>
						<textarea class="form-control" rows="3" name="content">${board.content }</textarea>
					</div>
					<div class="form-group">
						<label>Writer</label>
						<input class="form-control" name="writer" value="${board.writer }" readonly />
					</div>
					<button type="submit" data-oper="modify" class="btn btn-default">Modify</button>
					<button type="submit" data-oper="remove" class="btn btn-danger">Remove</button>
					<button type="submit" data-oper="list" class="btn btn-info">List</button>
				</form>
			</div>
		</div>
	</div>
</div>
<%@ include file="../includes/footer.jsp" %>
 
<script type="text/javascript">
$(document).ready(function() {
	var formObj = $("form");	
	
	$("button").on("click", function(e) {
		e.preventDefault();
		
		var operation = $(this).data("oper")
		
		alert("operation:" + operation);
		
		if (operation === 'remove') {
			formObj.attr("action", "/board/delete");
		} else if (operation === 'list') {
			// move to list
			/* self.location = "/board/list";
			return; */
			formObj.attr("action", "/board/list").attr("method", "get");
			var pageNumTag = $("input[name='pageNum']").clone();
			var amountTag = $("input[name='amount']").clone();
			var keywordTag = $("input[name='keywordTag']").clone();
			var typeTag = $("input[name='typeTag']").clone();
			
			
			formObj.empty();
			formObj.append(pageNumTag);
			formObj.append(amountTag);
			formObj.append(keywordTag);
			formObj.append(typeTag);
		}
		formObj.submit();
	});
});
</script>