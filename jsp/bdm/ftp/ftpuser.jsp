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
	
<%-- 	var context="<%=request.getContextPath()%>";
	 $(function() {
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
					reg2 = /[/:<>]+/;
					if(reg2.test(gets)){return false;}
					if(reg1.test(gets)){return true;}
    				return false;
				}
			},
			callback: function(){
				var dirName = $("#dirName").val();
				dirName = dirName.replace(/\n|\r\n/g,"<br>").replace(/[$]/g,"＄").replace(/[%]/g,"％").replace(/[#]/g,"＃").replace(/[&]/g,"＆").replace(/[ ]/g,"　");
				$.ajax({
					type: "GET",
					url: context + "/service/hdfs/existPath",
					data: "parentPath=" + path + "&newFileName=" + dirName + "&clusterId=" + clusterId,
					success: function(data) {
						if(data) {
							var message = "增加失败，名称为"+dirName+"的文件已经存在";
							$("#error").html('<lable class="errorMsg">'+message+'</label>');
						} else{
							makeDir(dirName);
						}
					}
				});
			}
		});
		$("#cancel").on('click',function() {
			dialog.close();
			dialog.remove();
		});
	}); --%>
	</script>
</head>
<body>
	<form class="form-horizontal"  id="saveForm" onsubmit="return false">
		<div id="error"></div>
		<div class="form-group">
			<label for="dirName" class="col-xs-3 col-md-3 control-label text-right">用户名</label>
			<div class="col-xs-8 col-md-8">
				<input type="text" class="form-control ue-form Validform_input" id="dirName"
						name="dirName" value=""  datatype="fileName" errormsg="用户名不符合规范！" nullmsg="用户名不能为空" />
				<span class="Validform_checktip Validform_span"></span>						
			</div>
		</div>
		<div class="form-group">
			<label for="dirName" class="col-xs-3 col-md-3 control-label text-right">密码</label>
			<div class="col-xs-8 col-md-8">
				<input type="text" class="form-control ue-form Validform_input" id="dirName"
						name="dirName" value=""  datatype="fileName" errormsg="密码不符合规范！" nullmsg="密码不能为空" />
				<span class="Validform_checktip Validform_span"></span>						
			</div>
		</div>
		<div class="form-group">
			<label for="dirName" class="col-xs-3 col-md-3 control-label text-right">目录</label>
			<div class="col-xs-8 col-md-8">
				<input type="text" class="form-control ue-form Validform_input" id="dirName"
						name="dirName" value=""  datatype="fileName" errormsg="目录不符合规范！" nullmsg="目录不能为空" />
				<span class="Validform_checktip Validform_span"></span>						
			</div>
		</div>
		<div class="form-group">
			<label for="dirName" class="col-xs-3 col-md-3 control-label text-right">用户组</label>
			<div class="col-xs-8 col-md-8">
				<input type="text" class="form-control ue-form Validform_input" id="dirName"
						name="dirName" value=""  datatype="fileName" errormsg="用户组不符合规范！" nullmsg="用户组不能为空" />
				<span class="Validform_checktip Validform_span"></span>						
			</div>
		</div>
		<div class="form-group" style="padding-left: 10%">
			<label class="col-xs-3 col-md-3 control-label text-right" ></label>
	        <div class="col-xs-8 col-md-8">
	           <button id="save" class="btn ue-btn-primary" >创建</button>
	           <button id="cancel" class="btn ue-btn">取消</button>
	           <span id="msgdemo"></span>
	        </div>
      	</div>
	</form>
</body>
</html>