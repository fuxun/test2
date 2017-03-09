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
		var fileName = "<%=request.getParameter("fileName")%>";
		var context="<%=request.getContextPath()%>";
		$(function(){
			//加载路径 
			$("#rename-path").text(path);
			//原文件名 
			$("#fileName").val(fileName).focus();
			
			//校验 
			 var dialog = parent.dialog.get(window);
			 $("#saveForm").Validform({
				btnSubmit: "#save",
				tiptype:function(msg,o,cssctl){
					if(!o.obj.is("form")){
						var objtip=o.obj.siblings(".Validform_checktip"); //下拉框
						//根据单复选框的DOM结构查找其验证结果框
						if(objtip.length == 0){
							if(o.obj.parent("div").length != 0){   //普通文本框
								objtip=o.obj.parents("div").siblings(".Validform_checktip");
							}
						}
						cssctl(objtip,o.type);
						objtip.text(msg);
					} else{
						var objtip=o.obj.find("#msgdemo");
						cssctl(objtip,o.type);
						objtip.text(msg);
					} 
				},
				datatype: {
					"fileName": function(gets,obj,curform,regxp){
						//参数gets是获取到的表单元素值，obj为当前表单元素，curform为当前验证的表单，regxp为内置的一些正则表达式的引用;
						var reg1 = /^[^\s]{1,255}$/,
						reg2 = /[/:]+/;
						if(reg2.test(gets)){return false;}
						if(reg1.test(gets)){return true;}
	    				return false;
					}
				},
				callback: function(){
					var new_fileName = $("#fileName").val();
					if(new_fileName == fileName) {
						$("#error").html('<lable class="errorMsg">文件名称未发生变化!</label>');
						return;
					}
					new_fileName = checkString(new_fileName);
					$.ajax({
						type: "GET",
						url: context + "/service/hdfs/existPath",
						data: "parentPath=" + parentPath + "&newFileName=" + new_fileName + "&clusterId=" + clusterId,
						success: function(data) {
							if(data) {
								var message = "修改失败，名称为"+new_fileName+"的文件已经存在";
								$("#error").html('<lable class="errorMsg">'+message+'</label>');
							} else{
								renameFile();
							}
						}
					});
				}
			 });
			//重命名文件 
			function renameFile() {
				var new_fileName = $("#fileName").val();
				new_fileName = checkString(new_fileName);
				$.ajax({
					type: "GET",
					url: context + "/service/hdfs/rename",
					data: "parentPath=" + parentPath + "&newFileName=" + new_fileName + "&clusterId=" + clusterId+"&oldPath="+path,
					success: function(data) {
						if(data){
							dialog.close();
						    var url = context + "/service/hdfs/data?path="+parentPath+"&clusterId="+clusterId;
							parent.grid.reload(url);
						}
					}
				});
			};
			$("#cancel").on('click',function() {
				dialog.close();
				dialog.remove();
			});
		});
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
		<div id="error"></div>
		<div class="form-group">
			<label class="col-xs-3 col-md-3 control-label text-right">正在重命名：</label>
			<div class="col-xs-8 col-md-8" class="rename-path">
				<span id="rename-path"></span>						
			</div>
			<div class="Validform_checktip Validform_span"></div>
		</div>
		<div class="form-group">
			<label for="fileName" class="col-xs-3 col-md-3 control-label text-right">新命名：</label>
			<div class="col-xs-8 col-md-8">
				<input type="text" class="form-control ue-form Validform_input" id="fileName"
						name="fileName" value=""  datatype="fileName" errormsg="名称不符合规范！" nullmsg="名称不能为空" />	
				<span class="Validform_checktip Validform_span"></span>					
			</div>
			<div class="col-xs-8 col-md-8">
      			<label class="name-promp">名称不能包含“/”、“:”字符；长度在1~255字符之间</label>
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