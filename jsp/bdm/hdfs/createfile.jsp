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
	var path ="<%=request.getParameter("path")%>";
	var context="<%=request.getContextPath()%>";
	 $(function() {
		 var dialog = parent.dialog.get(window);
		 $("#saveForm").Validform({
			btnSubmit: "#save",
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
				var fileName = $("#fileName").val();
				$.ajax({
					type: "GET",
					url: context + "/service/hdfs/existPath",
					data: "parentPath=" + path + "&newFileName=" + fileName + "&clusterId=" + clusterId,
					success: function(data) {
						if(data) {
							var message = "增加失败，名称为"+fileName+"的文件已经存在";
							$("#error").html('<lable class="errorMsg">'+message+'</label>');
						} else{
							createFile(fileName);
						}
					}
				});
			}
		});
		 function createFile(fileName){
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
				fileName = checkString(fileName);
			 $.ajax({
					type: "GET",
					url: context + "/service/hdfs/createFile",
					data: "clusterId="+clusterId+"&path="+path+"&fileName="+fileName+"&str_user=" + str_user+ "&str_group=" + str_group+"&str_other="+str_other,
					success: function(data) {
						if(data) {
							dialog.close();
							var url = context + "/service/hdfs/data?path="+path+"&clusterId="+clusterId;
							parent.grid.reload(url);
						} else{
							$("#error").html('<lable class="errorMsg">修改失败，请重新添加</label>');
						}
					},
				});
		 };
		$("#cancel").on('click',function() {
			dialog.close();
			dialog.remove();
		});
		$(".self_define_calue").hide();
		$("#selfdefine").on('click',function(){
			$(".self_define_calue").show();
		});
		$("#defaultvalue").on('click',function(){
			$(".self_define_calue").hide();
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
		<div id="error"></div>
			<div class="form-group">
				<label for="fileName" class="col-xs-3 col-md-3 control-label text-right"><span class="required">*</span>文件名称：</label>
				<div class="col-xs-8 col-md-8">
					<input type="text" class="form-control ue-form Validform_input" id="fileName"
							name="fileName" value=""  datatype="fileName" errormsg="名称不符合规范！" nullmsg="名称不能为空" />						
					<span class="Validform_checktip Validform_span"></span>
				</div>
			</div>
			<div class="form-group">
				<label class="col-xs-3 col-md-3 control-label text-right">权限</label>
				<div class="col-xs-8 col-md-8 control-label">&nbsp;&nbsp;
					<input type="radio" id="defaultvalue" name="isCustomed" value="0" checked="checked" />&nbsp;&nbsp;默认 
					<input type="radio" id="selfdefine" name="isCustomed" value="1"/>&nbsp;&nbsp;自定义
				</div>
			</div>
			<div class="form-group self_define_calue">
		         <label class="col-xs-3 col-md-3 control-label text-right">所属用户</label>
		         <div class="checkbox col-xs-8 col-md-8 text-left">&nbsp;&nbsp;
		                <label><input name="checkbox_all" type="checkbox" value="4">r</label>
		                &nbsp;&nbsp;&nbsp;&nbsp;
		                <label><input name="checkbox_all" type="checkbox" value="2">w</label>
		          </div>
			</div>
			<div class="form-group self_define_calue">
		         <label class="col-xs-3 col-md-3 control-label text-right">所在分组</label>
		         <div class="checkbox col-xs-8 col-md-8 text-left">&nbsp;&nbsp;
		                <label><input name="checkbox_group" type="checkbox" value="4">r</label>
		                  &nbsp;&nbsp;&nbsp;&nbsp;
		                <label><input name="checkbox_group" type="checkbox" value="2">w</label>
		          </div>
			</div>
			<div class="form-group self_define_calue">
		         <label class="col-xs-3 col-md-3 control-label text-right">其他</label>
		         <div class="checkbox col-xs-8 col-md-8 text-left">&nbsp;&nbsp;
		                <label><input name="checkbox_other" type="checkbox" value="4">r</label>
		                &nbsp;&nbsp;&nbsp;&nbsp;
		                <label><input name="checkbox_other" type="checkbox" value="2">w</label>
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