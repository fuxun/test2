<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" isELIgnored="false"%>
<%@ taglib uri="/tags/loushang-web" prefix="l"%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>HDFS文件管理</title>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/bootstrap.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/font-awesome.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/ui.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/form.css'/>"/>
	<link rel="stylesheet" type="text/css" href="<l:asset path='css/datatables.css'/>"/>
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
	<script  type="text/javascript" src="<l:asset path='datatables.js'/>"></script>
	<script  type="text/javascript" src="<l:asset path='loushang-framework.js'/>"></script>
	<script  type="text/javascript" src="<l:asset path='ui.js'/>"></script>
	<script  type="text/javascript" src="<l:asset path='arttemplate.js'/>"></script>
	<script type="text/html" id="option">
	{{each options as option i}}
		<option value="{{option.clusterId}}">{{option.clusterName}}</option>
	{{/each}}
	</script>
	<script type="text/javascript">
		var context="<%=request.getContextPath()%>";
		var clusterId = "<%=request.getParameter("clusterId")%>";
		$(document).ready(function() {
			//初始下拉框 
			initSelect();
			if(clusterId == "null"||clusterId ==""){
				$("#clusterName option:first").prop("selected", 'selected');
			}else{
				$("#clusterName").val(clusterId);
			}
			clusterId = $("#clusterName").val();
			var url = context+"/service/hdfs/data?clusterId="+clusterId;
			init(url);
			
			//根据文件名和集群进行查询 
			$("#query").bind("click",function() {
				var clusterId = $("#clusterName").val();
				var fileName = $("#fileName").val();
				var tempFileName = encodeURI(fileName);
				var path = $("#breadNav")[0].lastElementChild.id;
				path = checkString(path);
				fileName = checkString(fileName);
				var url = context + "/service/hdfs/data?path=" +path + "&clusterId=" + clusterId+"&fileName=" + tempFileName;
				grid.reload(url);
			});
			
			//点击回车事根据文件名称和集群进行查询 
			$("#fileName").keydown(function(event) {
				if(event.keyCode == 13)
				{
					var clusterId = $("#clusterName").val();
					var fileName = $("#fileName").val();
					var path = $("#breadNav")[0].lastElementChild.id;
					path = checkString(path);
					fileName = checkString(fileName);
					var url = context + "/service/hdfs/data?path=" +path + "&clusterId=" + clusterId+"&fileName=" + fileName;
					grid.reload(url);
			   	}
			});
			
			//面包屑
			$("#fileList tbody").on("click",".aname",function() {
				var data = grid.oTable.row($(this).parents("tr")).data();
				var fileName = data.fileName;
				var path = data.path;
				var isDirectory = data.isDirectory;
				if(!isDirectory)//如果不是文件夹则返回
					return;
				var clusterId = $("#clusterName").val();
				path = checkString(path);
				fileName = checkString(fileName);
				$("#breadNav").append("<li class='active fileName' id="+path+"><a onclick=menuClick('" + path + "')>"+ fileName +"</a></li>");
				var url = context + "/service/hdfs/data?path=" +path + "&clusterId=" + clusterId;
				grid.reload(url); 
			});
			
			//路径形式转为input框的形式 
			$("#filepath").bind("click",function() {
				$(".input-path").show().css("display","inline");
				$(".pencil-path").hide();
				var path = $(".fileName");
				var _path = "";
				for(var i = 1; i < path.length; i++) {
					_path = _path + path[i].textContent+"/";
				} 
				$("#path-writer").val("/" + _path).focus().blur(function(event){
					var relatedTarget = event.relatedTarget;
					if(relatedTarget!=null&&relatedTarget.id=="path-go")
						return false;
					$(".pencil-path").show();
					$(".input-path").hide();
				});
			});
			
			//input框中的路径，点击go按钮进行查询 
			$("#path-go").bind("click", function() {
				searchByPath();
			});
			
			//路径查询的键盘事件 
			$("#path-writer").keydown(function(event) {
				if(event.keyCode == 13)
				{
					searchByPath();
			   	}
			});
			
			//新建文件
			$("#createFile").bind("click",function() {
				var clusterId = $("#clusterName").val();
				var path = $("#breadNav")[0].lastElementChild.id;
				path = checkString(path);
				$.dialog({
					type: "iframe",
					url: "createfile.jsp?path="+path+"&&clusterId="+clusterId,
					title: "新建文件",
					width: 570,
					height: 300,
				});
			});
			//ftp文件管理
			$("#ftpUsermanage").bind("click",function() {
				var clusterId = $("#clusterName").val();
				var path = $("#breadNav")[0].lastElementChild.id;
				var url = context+ "/service/hdfs/ftp/toftpUsermanage";
				window.location.href = url;
			});
			
			//新建目录 
			$("#makeDir").bind("click",function() {
				var clusterId = $("#clusterName").val();
				var path = $("#breadNav")[0].lastElementChild.id;
				path = checkString(path);
				$.dialog({
					type: "iframe",
					url: "makeDir.jsp?path="+path+"&&clusterId="+clusterId,
					title: "新建目录",
					width: 570,
					height: 300,
				});
			}); 
			
			//上传文件 
			$("#upload").bind("click", function() {
				var clusterId = $("#clusterName").val();
				var path = $("#breadNav")[0].lastElementChild.id;
				path = checkString(path);
				$.dialog({
					type: "iframe",
					url: "upload.jsp?path=" + path + "&&clusterId=" + clusterId, //避免出现中文乱码 
					title: "上传文件",
					width: 400,
					height: 450,
					onclose: function () {
						var url = context + "/service/hdfs/data?path=" +path + "&clusterId=" + clusterId;
						grid.reload(url); 
					}
				});
			});
			
			//批量删除 
			$("#delete").bind("click", function() {
				var clusterId = $("#clusterName").val();
				var path = getCheckBoxValue("checkboxlist");
				path = checkString(path);
				if (path.length < 1) {
					$.dialog({
						autofocus:true,
						type : "alert",
						content : "请至少选择一条记录!"
					});
					return;
				}else{
				$.dialog({
					autofocus: true,
					type : 'confirm',
					content : '确认删除该记录?',
					ok : function() {
						$.ajax({
							type: "GET",
							url: context + "/service/hdfs/canBeDeleted?paths=" + path + "&clusterId=" + clusterId,
							success: function(dataobj) {
								var data = dataobj.result;
								var message = dataobj.message;
								if(data) {
									deleteFile(path, clusterId);//删除文件 
								}else {
									$.dialog({
										type: "alert",
										content: message
									});
								}
							}
						});
					},
					cancel : function() {
					}
				});
				}
			});
		});
		
		function init(url){
			var options = {
			  	"info": false, 
			  	"paging": false,
			  	"serverSide": false,
			  };
			grid = new L.FlexGrid("fileList",url); 
			grid.init(options); //初始化datatable
		}
		
		//根据指定路径进行查询 
		function searchByPath(){
			var path = $("#path-writer").val();
			if(path==null||path=="")
				return;
			var clusterId = $("#clusterName").val();
			path = checkString(path);
			$.ajax({
				type: "GET",
				url: context + "/service/hdfs/existPath",
				data: "clusterId=" + clusterId + "&parentPath=" + path,
				success: function(data) {
					if(data) {
						var url = context + "/service/hdfs/data?path=" + path + "&clusterId=" + clusterId;
						grid.reload(url); 
						$(".pencil-path").show();
						$(".input-path").hide();
						generateBreadNav(path);
					} else {
						$.dialog({
							type : 'confirm',
							autofocus: true,
							content : '路径不存在！',
							ok : function() {
								$(".pencil-path").show();
								$(".input-path").hide();
							},
							cancel : function() {
							}
						});
					}
				}
			});
			
		}
		//根据给定路径生成面包屑导航
		function generateBreadNav(path){
			var lis = path.split('/');
			$("#breadNav").empty();
			$("#breadNav").append("<li class='active fileName' id='/'><a href='#' onclick=menuClick('/')>/</a></li>");
			var id = "";
			for(var i=1;i<lis.length;i++){
				if(lis[i]=="")
					continue;
				id=id+"/"+lis[i];
				$("#breadNav").append("<li class='active fileName' id="+id+"><a onclick=menuClick('" + id + "')>"+ lis[i] +"</a></li>");
			}
		}
		
		//重命名
		function rename(full) {
			var clusterId = $("#clusterName").val();
			var fileName = full.fileName;
			var path = full.path;
			var parentPath = $("#breadNav")[0].lastElementChild.id;
			path = checkString(path);
			fileName = checkString(fileName);
		 	$.dialog({
		 		type: "iframe",
				url: "rename.jsp?parentPath="+ parentPath+"&path=" + path + "&fileName=" + fileName + "&clusterId=" + clusterId, //避免出现中文乱码 
				title: "重命名",
				width: 570,
				height: 200
		 	});
		}
		//权限管理
		function manage(full) {
			var clusterId = $("#clusterName").val();
			var fileName = full.fileName;
			var path = full.path;
			var parentPath = $("#breadNav")[0].lastElementChild.id;
			path = checkString(path);
			fileName = checkString(fileName);
			$.ajax({
				type: "GET",
				url: context + "/service/hdfs/isDir",
				data: "parentPath=" + parentPath +"&clusterId=" + clusterId+"&path=" + path,
				success: function(data) {
					$.dialog({
				 		type: "iframe",
						url: "manage.jsp?parentPath="+ parentPath+"&path=" + path + "&fileName=" + fileName + "&clusterId=" + clusterId+"&isdirectory="+data.result+ "&permission="+data.permission, //避免出现中文乱码 
						title: "权限管理",
						width: 360,
						height: 180
				 	});
				}
			});
		 	
		}
		//下载数据 
		function down(full) {
			var clusterId = $("#clusterName").val();
			var path = full.path;
			var fileName = full.fileName;
			path = checkString(path);
			fileName = checkString(fileName);
			window.location.href = context + "/service/hdfs/downloadFile?path="+path+"&fileName="+fileName+"&clusterId="+clusterId+"&length="+full.length;
		}
		
		//判断数据是否能删除 
		function del(full) {
			var path = full.path;
			var clusterId = $("#clusterName").val();
			path = checkString(path);
			$.dialog ({
				autofocus: true,
				type : 'confirm',
				content : '确认删除该记录?',
				ok : function() {
					$.ajax({
						type: "GET",
						url: context + "/service/hdfs/canBeDeleted",
						data: "paths=" + path + "&clusterId=" + clusterId,
						success: function(dataobj) {
							var data = dataobj.result;
							var message = dataobj.message;
							if(data) {
								deleteFile(path,clusterId);//删除文件 
							}else {
								$.dialog({
									type: "alert",
									content: message
								});
							}
						},
						error: function() {}
					});
				},
				cancel : function() {
				}
			});
		}
		//删除一条数据 
		function deleteFile(path,clusterId) {
			var path1 = $("#breadNav")[0].lastElementChild.id;
			path1 = checkString(path1);
			$.ajax({
				type: "GET",
				url: context + "/service/hdfs/deleteFile",
				data: "paths=" + path + "&clusterId=" + clusterId,
				success: function(dataObj) {
					var message = dataObj;
					if (message == "") {
						var url = context + "/service/hdfs/data?path=" + path1 + "&clusterId=" + clusterId;
						grid.reload(url);
					} else {
						$.dialog({
							type: "alert",
							content: message
						});
					}
				},
				error: function() {}
			});
		}
		//复选框
		function rendercheckbox(data, type, full) {
       	 	return '<input type="checkbox" value="' + data + '" title="' + data + '" id="checkbox" name="checkboxlist"/>';
    	}
		//初始select下拉框 
		function initSelect() {
			$.ajax({
				type: "GET",
				url: context + "/service/hdfs/getOptions",
				dataType: "json",
				async: false,
				success: function(dataobj) {
					var temp = template("option", {
						options : dataobj.data
					});
					$("#clusterName").append(temp);
				},
				error: function(){}
			});
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
		//将文件名称改为连接形式的 
		function alink(data,type,full) {
			return "<a class='aname'>"+ data +"</a>";
		}
		//给文件名增加图标  
		function icon(data,type,full) {
			if(data) {
				return "<span class='fa fa-folder'></span>";
			} else {
				return "<span class='fa fa-file'></span>";
			}
		}
		//选择面包屑中的一个路径 
		function menuClick(path) {
			var clusterId = $("#clusterName").val();
			$("#"+path.replace(/\//g, '\\/').replace(/\:/g,'\\\:').replace(/\./g,'\\.')).nextUntil('ol').remove();
			path = checkString(path);
			var url = context + "/service/hdfs/data?path=" + path + "&clusterId=" + clusterId;
			grid.reload(url);
		}
		
		function operation(data, type, full){
			if(full.isDirectory) {
	  			return "<a onclick='rename("+JSON.stringify(full)+")'>重命名</a>"+
	  					"<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>"+
	  					"<a onclick='del("+JSON.stringify(full)+")'>删除</a>"+
	  					"<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>"+
	  					"<a onclick='manage("+JSON.stringify(full)+")'>权限管理</a>";
	  		}else {
	  			return "<a onclick='rename("+JSON.stringify(full)+")'>重命名</a>"+
	  			"<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>"+
				"<a onclick='del("+JSON.stringify(full)+")'>删除</a>"+
				"<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>"+
				"<a onclick='manage("+JSON.stringify(full)+")'>权限管理</a>"+
				"<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>"+
				"<a onclick='down("+JSON.stringify(full)+")'>下载</a>";
	  		}
		}
		//改变集群 
		function changeClusterName() {
			var clusterId = $("#clusterName").val();
			var url = context + "/service/hdfs/data?clusterId="+clusterId;
			grid.reload(url);
		}
		function checkString(str){
			str = str.replace(/\+/g,"%2B");
			str = str.replace(/\&/g,"%26");
			return str;
		}
	</script>
</head>
<body class="body">
	<div class="list-top">
		<div class="list-title">HDFS文件管理</div>
		<form class="form-inline pull-right" onsubmit="return false">
			<div class="list-select"> 
				<label class="control-label">选择集群：</label>
				<select class="form-control ue-form" name="" id="clusterName" onchange="changeClusterName()">
					
				</select>
			</div>
			<div class="input-group" >
				<input class="form-control ue-form" type="text" id="fileName" placeholder="请输入文件名称" style="font-size: 12px;width:120px"/>
				<div class="input-group-addon ue-form-btn" id="query" >
				    <span class="fa fa-search"></span>
				</div>
			</div>
			<button type="button" id="upload" class="btn ue-btn btns">
				<span class="fa fa-upload"></span>上传文件
			</button>
			<div class="dropdown">
				<button class="btn ue-btn dropdown-toggle btns" type="button" id="dropdownMenu" data-toggle="dropdown">
					<span class="fa fa-plus"></span>新建<span class="fa fa-caret-down"></span>
    			</button>
    			<ul class="dropdown-menu ue-dropdown-menu">
        			<li class="ue-dropdown-angle"></li>
        			<li><a id="createFile" class="btns"><span class='fa fa-file'></span>新建文件</a></li>
        			<li><a id="makeDir" class="btns"><span class='fa fa-folder'></span>新建目录</a></li>
    			</ul>
			</div>
			<button type="button" id="delete" class="btn ue-btn btns">
				<span class="fa fa-trash"></span>删除
			</button>
			<!-- <button type="button" id="ftpUsermanage" class="btn ue-btn btns">
				<span class="fa"></span>FTP用户管理
			</button> -->
		</form>
	</div>
	<div class="file-path">
		<span class="fa fa-link"></span>
		路径：
		<div class="pencil-path" style="display: inline">
			<ol class="breadcrumb" id="breadNav">
  				<li class="active fileName" id="/"><a href="#" onclick="menuClick('/')">/</a></li>
			</ol>
			<span class="fa fa-pencil" id="filepath"></span>
		</div>
		<div class="input-path" style="display: none;">
			<input type="text" id="path-writer" style="width: 82%"/>
			<button type="button" class="btn ue-btn-primary" id="path-go">GO</button>
		</div>
	</div>
	<div class="container" style="margin-top: 5px;">
		<div class="row">
			<table id="fileList" class="table table-bordered table-hover">
				<thead>
					<tr>
						<th width="8%" data-field="path" data-sortable= "false" data-render="rendercheckbox">
							<input type="checkbox" id="selectAll" onchange="selectAll(this,'checkList')"/>
						</th>
						<th width="2%" data-field="isDirectory" data-sortable="false" data-render="icon"></th>
						<th width="14%" data-field="fileName" data-sortable="false" data-render="alink">名称</th>
						<th width="10%" data-field="length" data-sortable="false">大小（字节）</th>
						<th width="10%" data-field="owner" data-sortable="false">所属用户</th>
						<th width="9%" data-field="group" data-sortable="false">所在分组</th>
						<th width="9%" data-field="permission" data-sortable="false">权限</th>
						<th width="16%" data-field="modificationTime" data-sortable="false">修改时间</th>
						<th width="21%" data-field="path" data-sortable="false" data-render="operation">操作</th>
					</tr>
				</thead>
			</table>
		</div>
	</div>
</body>
</html>