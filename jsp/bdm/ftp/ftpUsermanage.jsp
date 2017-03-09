<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib uri="/tags/loushang-web" prefix="l"%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>任务定义</title>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/bootstrap.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/font-awesome.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/ui.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/form.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/datatables.css'/>"/>
	<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="<l:asset path='html5shiv.js'/>"></script>
      <script src="<l:asset path='respond.js'/>"></script>
    <![endif]-->
	<script  type="text/javascript" src="<l:asset path='jquery.js'/>"></script>
	<script  type="text/javascript" src="<l:asset path='bootstrap.js'/>"></script>
	<script  type="text/javascript" src="<l:asset path='form.js'/>"></script>
	<script  type="text/javascript" src="<l:asset path='datatables.js'/>"></script>	
	<script  type="text/javascript" src="<l:asset path='ui.js'/>"></script>	
	<script  type="text/javascript" src="<l:asset path='loushang-framework.js'/>"></script>	
		<script type="text/javascript">
	var context="<%=request.getContextPath()%>";
	$(document).ready(function() {
	  //初始化表格
	   var options = {
			 "ordering": false
	    };	   
		var url = context+"/service/hdfs/ftp/data";
		grid = new L.FlexGrid("taskDefList",url); 
		var oTable = grid.init(options); //初始化datatable
	    //修改
	    $("#taskDefList tbody").on("click","#modify",function(){
	    	var url = context+"/service/bde/task/edit";
			var id = oTable.row($(this).parents("tr")).data().id;
			var type = oTable.row($(this).parents("tr")).data().program_type;
			  var job_schedule = oTable.row($(this).parents("tr")).data().task_rule_text;
			if(id){
				url += "?id=" + id;
			}
			window.location.href = url;
	   });
	   //删除
	   $("#taskDefList tbody").on("click","#del",function(){
			var recordIds = oTable.row($(this).parents("tr")).data().id;
			$.dialog({
				type: 'confirm',
				content: '确认删除该任务?',
			    autofocus: true,
				ok: function(){window.location.href=context+"/service/bde/task/delete?id="+recordIds;},
				cancel: function(){}
			});
	   });
	   //发布
	   $("#taskDefList tbody").on("click","#execute",function(){
			var recordIds = oTable.row($(this).parents("tr")).data().id;
			$.dialog({
				type: 'confirm',
				content: '确认启用该任务?',
			    autofocus: true,
				ok: function(){window.location.href=context+"/service/bde/task/start?id="+recordIds;},
				cancel: function(){}
			});
	   });
	   //取消发布
	   $("#taskDefList tbody").on("click","#cancel",function(){
			var recordIds = oTable.row($(this).parents("tr")).data().id;
			$.dialog({
				type: 'confirm',
				content: '确认停止该任务?',
			    autofocus: true,
				ok: function(){window.location.href=context+"/service/bde/task/stop?id="+recordIds;},
				cancel: function(){}
			});
	   });
	   //增加
	  $("#adduser").bind("click",function(){
		  $.dialog({
				type: "iframe",
				url: context + "/jsp/bdm/ftp/ftpuser.jsp",
				title: "用户新建与修改",
				width: 400,
				height: 300,
			});
	  });
		//返回
	  $("#ret").on("click",function(){
		  window.location.href= context + "/jsp/bdm/hdfs/fileSystem.jsp";
	  });
	   
	});
	 function operation(data, type, full){
			if(full.isDirectory) {
	  			return "<a onclick='modify("+JSON.stringify(full)+")'>修改</a>"+
	  					"<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>"+
	  					"<a onclick='del("+JSON.stringify(full)+")'>删除</a>";
	  		}else {
	  			return "<a onclick='modify("+JSON.stringify(full)+")'>修改</a>"+
	  			"<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>"+
				"<a onclick='del("+JSON.stringify(full)+")'>删除</a>";
	  		}
		}
		// 获取选中的复选框的记录
		function getCheckBoxValue(attrKey) {
			var confCheckBox = $("input:checkbox[name=" + attrKey + "]");
			var selectedValue = "";
			for ( var i = 0; i < confCheckBox.length; i++) {
				if (confCheckBox[i].checked) {
					if ("" == selectedValue) {
						selectedValue = confCheckBox[i].value;
					} else {
						selectedValue = selectedValue + "," + confCheckBox[i].value;
					}
				}
			}
			return selectedValue;
		} 
		 //checkbox全选
		function selectAll(obj, iteName) {
			if (obj.checked) {
				$("input[name='checkboxlist']").each(function() {
					this.checked = true;
				});
			} else {
				$("input[name='checkboxlist']").each(function() {
					this.checked = false;
				});
			}
		}
		//复选框
		function rendercheckbox(data, type, full) {
	   	 	return '<input type="checkbox" value="' + data + '" title="' + data + '" id="checkbox" name="checkboxlist"/>';
		}
	</script>
</head>
<body>
	<div class="container">
	 <div class="row">
		     <div class="form-inline header-form">
		      <div class="btn-group pull-right">
					<button id="del" type="button" class="btn ue-btn">删除</button>
				 </div>
				 <div class="btn-group pull-right">
					<button id="adduser" type="button" class="btn ue-btn">新增</button>
				 </div>
				  <div class="btn-group pull-right">
					<button id="ret" type="button" class="btn ue-btn">返回</button>
				 </div>
			 </div>
		</div>
		<div class="row">
			<table id="taskDefList" class="table table-bordered table-hover">
				<thead>
					<tr>
						<th width="8%" data-field="path" data-sortable= "false" data-render="rendercheckbox">
							<input type="checkbox" id="selectAll" onchange="selectAll(this,'checkList')"/>
						</th>
						<th width="19%" data-field="task_name">用户名</th>
						<th width="19%" data-field="job_id">目录</th>
						<th width="" data-field="cron_text">操作时间</th>
						<th width="15%" data-field="id" data-render="operation">操作</th>
					</tr>
				</thead>
			</table>
		</div>
		<div></div>	 
	</div>
</body>
</html>