/**
 * 
 */

console.log("Reply Module...........");

var replyService = (function() {
	
	function add(reply, callback, error) {
		console.log("reply zzzzzzzzzzzzza ...............");
		console.log("test: " + JSON.stringify(reply));
		console.log("test typeof1: " + typeof JSON.stringify(reply));
		console.log("test typeof2: " + typeof reply);
		$.ajax({
			type : "post",
			url : "/replies/new",
			data : JSON.stringify(reply),
			contentType : "application/json; charset=utf-8",
			success : function(result, status, xhr) {
				if (callback) {
					callback(result);
				}
			},
			error : function(xhr, status, er) {
				if (error) {
					error(er);
				}
			}
		
		});
		
	}
	
	function getList(param, callback, error) {
		var bno = param.bno;
		var page = param.page || 1;
		
		$.getJSON("/replies/pages/" + bno + "/" + page + ".json", function(data) {
			if (callback) {
				callback(data);
			}
		}).fail(function(xhr, status, err) {
			if (error) {
				error();
			}
		});
	}
	
	function remove(rno, callback, error) {
		$.ajax({
			type : 'delete', 
			url : '/replies/' + rno,
			success : function(deleteResult, status, xhr) {
				alert("deleteResult: " + deleteResult);
				if (callback) {
					callback(deleteResult);
				}
			},
			error : function(xhr, status, er) {
				if (error) {
					error(er);
				}
			}
		});
	}
	
	function update(reply, callback, error) {
		console.log("RNO: " + reply.rno);
		
		$.ajax({
			type : 'put',
			url : '/replies/' + reply.rno,
			data : JSON.stringify(reply),
			contentType : "application/json; charset=utf-8",
			success : function(result, status, xhr) {
				alert("result: " + result);
				alert("status: " + status);
				alert("xhr: " + xhr);
				if (callback) {
					callback(result);
				}
			},
			error : function(xhr, status, er) {
				if (error) {
					error(er);
				}
			}
		});
	}
	
	function get(rno, callback, error) {
		$.get("/replies/" + rno + ".json", function(result) {
			if (callback) {
				callback(result);
			}
		}).fail(function(xhr, status, err) {
			if (error) {
				error();
			}
		});
	}
	
	function displayTime(timeValue) {
		var today = new Date();
		/*console.log("timeValue: " + timeValue);
		console.log("today.getTime(): " + today.getTime());*/
		var gap = today.getTime() - timeValue;
		/*console.log("gap: " + gap);*/
		var dateObj = new Date(timeValue);
		var str = "";
		
		if (gap < (1000 * 60 * 60 * 24)) {
			var hh = dateObj.getHours();
			var mi = dateObj.getMinutes();
			var ss = dateObj.getSeconds();
			
			/*console.log("1: " + [(hh > 9 ? '' : '0') + hh, ':', (mi > 9 ? '' : '0') + mi,
					':', (ss > 9 ? '' : '0') + ss].join(''));*/
			return [(hh > 9 ? '' : '0') + hh, ':', (mi > 9 ? '' : '0') + mi,
					':', (ss > 9 ? '' : '0') + ss].join('');
		} else {
			var yy = dateObj.getFullYear();
			var mm = dateObj.getMonth() + 1; // getMonth() is zero-based
			var dd = dateObj.getDate();
			
			/*console.log("2: " + [yy, '/', (mm > 9 ? '' : '0') + mm, '/',
					(dd > 9 ? '' : '0') + dd].join(''));*/
			return [yy, '/', (mm > 9 ? '' : '0') + mm, '/',
					(dd > 9 ? '' : '0') + dd].join('');
		}
		
	}
	
	
	return {
		add: add,
		getList : getList,
		remove : remove,
		update : update,
		get : get,
		displayTime : displayTime
	};
})();