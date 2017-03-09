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
		var context="<%=request.getContextPath()%>";
	 	$(function() {
	 		var dialog = parent.dialog.get(window);
	 		//上传的路径 
			$("#upload-path").text(path);		
	 		//点击按钮上传文件 
			var $r = $('#uploader'); 
			var uploader = new plupload.Uploader({
				runtimes: 'html5,flash,silverlight,html4',//用来指定上传方式,指定多个上传方式请使用逗号隔开,默认即为此,可不写
				browse_button: 'rpickfiles',
				url: context+"/service/hdfs/uploadFile?path="+path+"&clusterId="+clusterId,
				max_file_size: '1024mb',
	            flash_swf_url: '<l:asset path="Moxie.swf"/>', //flash地址,swf文件,当需要使用swf方式进行上传时需要配置该参数
	            silverlight_xap_url: '<l:asset path="Moxie.xap"/>',//silverlight文件,当需要使用silverlight方式进行上传时需要配置该参数
	            init: {
	    			FilesAdded: function(up, files) {
	    				var uploadForbid;
	    				plupload.each(files, function(file){
	    					var len = file.name.length;
	    					if(file.name.indexOf(',') != -1){
	    						document.getElementById('rresult').innerHTML = '名字不能包含逗号';
	    						uploadForbid="no";
	    					}else if(len < 1 || len > 255) {
	    						document.getElementById('rresult').innerHTML = '名字长度不在1-255之间';
	    						uploadForbid="no";
	    					} else {
	    						if(uploadForbid != "no") {
	    							 document.getElementById('rresult').innerHTML += '<div style="position: relative"><div id="' + file.id + '" class="upload-progress">' + file.name + ' (' + plupload.formatSize(file.size) + ') <div class="progress"><div class="progress-bar progress-bar-success"><span></span></div></div></div></div>';
	    						}
	    					}
	    				});
	    				if(uploadForbid != 'no'){
	    					uploader.start();
	    				}
	    			},
	    			UploadProgress: function(up, file) {
	    				var len = file.name.length;
	    				if(len<1 || len>255){
	    				}else {
	    					if(window.navigator.userAgent.toLowerCase().indexOf("firefox")!=-1){
	    	        			$("#" + file.id).find('.progress-bar')[0].style.width = $("#" + file.id).find('.progress-bar')[0].textContent = file.percent-1 + "%";
	    	        		 }	else{
	    	              		$("#" + file.id).find('.progress-bar')[0].style.width = $("#" + file.id).find('.progress-bar')[0].innerText = file.percent-1 + "%";
	    	        		 } 
	    				}
	    			},
	    			FileUploaded: function(up,file, responseObject){
	    	       		serverData = responseObject.response;
	    	       		data = eval('(' + serverData + ')');
	    	       		/* serverData = responseObject.response;
       					result = eval('(' + serverData + ')');
       					if(result == "true"){ */
	    	  	 		if(data){ 
	    	       			if(window.navigator.userAgent.toLowerCase().indexOf("firefox")!=-1){
	    	       				$("#" + file.id).find('.progress-bar')[0].style.width = $("#" + file.id).find('.progress-bar')[0].textContent = 100+ "%";
	    	       			} else{
	    	       				$("#" + file.id).find('.progress-bar')[0].style.width = $("#" + file.id).find('.progress-bar')[0].innerText = 100+ "%";
	    	       			}
	    	       		 	var progressBar = $(".progress-bar");
	    	       			if($(progressBar[progressBar.length-1]).text() == "100%"){
	    	       				document.getElementById('rresult').innerHTML = '上传成功！';
	    	       			} 
	    	       		}
	    	        
	    	       },
	    			//当发生错误时触发
	    			Error: function(up, err) {
	    				document.getElementById('rresult').appendChild(document.createTextNode("\nError #" + err.code + ": " + err.message));
	    			}
	    		}
			});
			//初始化Plupload实例
			uploader.init();
			//自定义滚动条 
			$(".upload-ready").slimscroll({
				height: 370,
				size: "10px",
				color: "#949faa",
				distance: "2px",
				wheelStep: "12px",
				railVisible: true,
				railColor: "#ecf0f6",
				railOpacity: 1,
				allowPageScroll: true	
			});
			//关闭按钮 
			$(document).on("click","#resBtn",function(){
				dialog.close();
				dialog.remove();
			});
		}); 
	</script>
</head>
<body>
	<div id="uploader">
		<div class="upload-file" id="#rpick">
        	<button type="button" class="btn ue-btn-primary" id="rpickfiles">选择文件</button>
        	<label class="upload-address">上传到 ：<span id="upload-path"></span></label>
		</div>
		<div class="upload-ready">
			<div class="upload-body">
				<div class="name-promp">1：上传文件类型不限。</div>
				<div class="name-promp">2：单次上传文件大小不超过<font color="red">1G</font>。</div>
				<div class="name-promp">3：支持批量上传文件（可按住ctrl键进行多选）。</div>
			</div>
			<div id="rresult"></div>
		</div>
		<div class="upload-bottom">
			<button type="button" class="btn ue-btn" id="resBtn">关闭</button>
		</div>
	</div>
</body>
</html>