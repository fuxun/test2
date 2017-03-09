<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib uri="/tags/loushang-web" prefix="l"%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>HDFS文件管理</title>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/bootstrap.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/ui.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/form.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='hdfs/css/hdfs.css'/>"/>
	
	<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="<l:asset path='html5shiv.js'/>"></script>
      <script src="<l:asset path='respond.js'/>"></script>
    <![endif]-->
    
	<script  type="text/javascript" src="<l:asset path='jquery.js'/>"></script>
	<script  type="text/javascript" src="<l:asset path='bootstrap.js'/>"></script>
	<script  type="text/javascript" src="<l:asset path='form.js'/>"></script>
	<script type="text/javascript">
		var clusterId = "<%=request.getParameter("clusterId")%>";
		var path = "<%=request.getParameter("path")%>";
		var parentPath = "<%=request.getParameter("parentPath")%>";
		var context = "<%=request.getContextPath()%>";
		var isdirectory = "<%=request.getParameter("isdirectory")%>";
		var permission = "<%=request.getParameter("permission")%>";
		$(function(){
			//加载路径 
			$("#rename-path").text(path);
			//原文件名 
			isDirectory(isdirectory);
			ischecked(permission);
			//校验 
			 var dialog = parent.dialog.get(window);
			 $("#saveForm").Validform({
				btnSubmit: "#save",
				callback: function(){
					var str_user=""; 
					var str_group=""; 
					var str_other=""; 
					var temp=0;
					$('input[name="checkbox_all"]:checked').each(function(){ 
						temp+=parseInt($(this).val()); 
						}); 
					str_user += temp;
					temp = 0;
					$('input[name="checkbox_group"]:checked').each(function(){ 
						temp+=parseInt($(this).val()); 
						}); 
					str_group += temp;
					temp = 0;
					$('input[name="checkbox_other"]:checked').each(function(){ 
						temp+=parseInt($(this).val()); 
						}); 
					str_other += temp;
					path = checkString(path);
					$.ajax({
						type: "GET",
						url: context + "/service/hdfs/modifypermission",
						data: "parentPath=" + parentPath + "&str_user=" + str_user+ "&str_group=" + str_group+ "&str_other=" + str_other +"&clusterId=" + clusterId+"&path=" + path,
						success: function(data) {
							if(data){
								dialog.close();
							    var url = context + "/service/hdfs/data?path="+parentPath+"&clusterId="+clusterId;
								parent.grid.reload(url);
							}
						}
					});
				}
			 });
			$("#cancel").on('click',function() {
				dialog.close();
				dialog.remove();
			});
		});
		function isDirectory(isdirectory){
			if(isdirectory=="true"){
				$(".isdir").parent().show();
			}else{
				$(".isdir").parent().hide();
			}
		}
		function ischecked(permission){
			var i=0;
			for(var j=0;j<3;j++){
				if(permission.charAt(i++)!="-")
				$("input[name='checkbox_all']:eq("+j+")").attr("checked", true);
			}
			for(var j=0;j<3;j++){
				if(permission.charAt(i++)!="-")
				$("input[name='checkbox_group']:eq("+j+")").attr("checked", true);
			}
			for(var j=0;j<3;j++){
				if(permission.charAt(i++)!="-")
				$("input[name='checkbox_other']:eq("+j+")").attr("checked", true);
			}
		}
		function checkString(str){
			str = str.replace(/\+/g,"%2B");
			str = str.replace(/\&/g,"%26");
			return str;
		}
	</script>
</head>
<body>
	<form class="form-horizontal"  id="saveForm" onsubmit="return false">
	<div class="rename-body">
		<div class="form-group">
			 <label class="col-xs-3 col-md-3 control-label text-right">所属用户</label>
	         <div class="col-xs-8 col-md-8 text-left checkbox" id = "alluser">&nbsp;&nbsp;
	                <label><input name="checkbox_all" type="checkbox" value="4">r</label>&nbsp;&nbsp;
	                <label><input name="checkbox_all" type="checkbox" value="2">w</label>&nbsp;&nbsp;
	                <label><input name="checkbox_all" class="isdir" type="checkbox" value="1">x</label>
	         </div>
		</div>
		<div class="form-group">
			 <label class="col-xs-3 col-md-3 control-label text-right" id = "groupuser">所在分组</label>
	         <div class="col-xs-8 col-md-8 text-left checkbox">&nbsp;&nbsp;
	                <label><input name="checkbox_group" type="checkbox" value="4">r</label>&nbsp;&nbsp;
	                <label><input name="checkbox_group" type="checkbox" value="2">w</label>&nbsp;&nbsp;
	                <label><input name="checkbox_group"  class="isdir" type="checkbox" value="1">x</label>
	         </div>
		</div>
		<div class="form-group">
			 <label class="col-xs-3 col-md-3 control-label text-right" id = "otheruser">其他</label>
	         <div class="col-xs-8 col-md-8 text-left checkbox">&nbsp;&nbsp;
	                <label><input name="checkbox_other" type="checkbox" value="4">r</label>&nbsp;&nbsp;
	                <label><input name="checkbox_other" type="checkbox" value="2">w</label>&nbsp;&nbsp;
	                <label><input name="checkbox_other"  class="isdir" type="checkbox" value="1">x</label>
	         </div>
		</div>
      	<div class="form-group" style="padding-left: 10%;margin-top: 25px;">
			<label class="col-xs-3 col-md-3 control-label text-right" ></label>
	        <div class="col-xs-8 col-md-8">
	           <button id="save" class="btn ue-btn-primary" >保存</button>
	           <button id="cancel" class="btn ue-btn">取消</button>
	           <span id="msgdemo"></span>
	        </div>
      	</div>
	</div>
	</form>
</body>
</html>