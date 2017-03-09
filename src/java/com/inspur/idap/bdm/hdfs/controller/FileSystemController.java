package com.inspur.idap.bdm.hdfs.controller;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;

import com.inspur.idap.bdm.config.data.Cluster;
import com.inspur.idap.bdm.config.service.IClusterService;
import com.inspur.idap.bdm.hdfs.service.IFileSystemService;
import com.inspur.idap.bdm.hdfs.util.FileSystemUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.multipart.commons.CommonsMultipartFile;

@Controller
@RequestMapping(value = "/hdfs")
public class FileSystemController {

	private static Log log = LogFactory.getLog(FileSystemController.class);

	@Autowired
	IFileSystemService fileSystemService;
	
	@Autowired
	IClusterService clusterService;

	/**
	 * 跳转文件列表页面
	 * 
	 * @return 文件列表页面
	 */
	@RequestMapping
	public String queryFiles() {
		return "bdm/hdfs/fileSystem";
	}
	// 文件列表信息的查询
	@RequestMapping(value = "/data")
	@ResponseBody
	public Map getData(HttpServletRequest request) {
		Map<String, Object> filedata = new HashMap<String, Object>();
		String clusterId = request.getParameter("clusterId");
		String path = request.getParameter("path");
		String fileName = request.getParameter("fileName");
		if (path == null || "".equals(path))
			path = "/";
		List files = new ArrayList();
		try {
			files = fileSystemService.listFileStatuses(clusterId, path,
					fileName);
		} catch (Exception e) {
			log.error("获取文件列表信息出错：",e);
		}
		filedata.put("data", files);
		return filedata;
	}

	// 创建文件
	@RequestMapping(value = "/createFile")
	@ResponseBody
	public boolean createFile(HttpServletRequest request) {
		boolean res = false;
		String clusterId = request.getParameter("clusterId");
		String path = request.getParameter("path");
		int str_user = Integer.parseInt(request.getParameter("str_user")) ;
		int str_group = Integer.parseInt(request.getParameter("str_group"));
		int str_other =  Integer.parseInt(request.getParameter("str_other"));
		if (path == null || path.equals(""))
			path = "/";
		try {
			String fileName = request.getParameter("fileName");
			String dir;
			if (path.endsWith("/"))
				dir = path + fileName;
			else
				dir = path + "/" + fileName;
			res = fileSystemService.createFile(clusterId, dir);
			if(str_user!=0 && str_group!=0 && str_other!=0){
				fileSystemService.changeFileAllRight(clusterId, dir, str_user, str_group,str_other);
			}
			return res;
		} catch (Exception e) {
			res = false;
			log.error("创建文件出错：",e);
		}
		return res;
	}

	// 创建目录
	@RequestMapping(value = "/makeDir")
	@ResponseBody
	public boolean makeDir(HttpServletRequest request) {
		boolean res = false;
		String path = request.getParameter("path");
		String clusterId = request.getParameter("clusterId");
		int str_user = Integer.parseInt(request.getParameter("str_user")) ;
		int str_group = Integer.parseInt(request.getParameter("str_group"));
		int str_other =  Integer.parseInt(request.getParameter("str_other"));
		if (path == null || path.equals(""))
			path = "/";
		try {
			String dirName = request.getParameter("dirName");
			String dir;
			if (path.endsWith("/"))
				dir = path + dirName;
			else
				dir = path + "/" + dirName;
			res = fileSystemService.makeDir(clusterId, dir);
			if(str_user!=0 && str_group!=0 && str_other!=0){
				fileSystemService.changeDirAllRight(clusterId, dir, str_user, str_group, str_other);
			}
		} catch (Exception e) {
			res = false;
			log.error("创建目录出错：",e);
		}
		return res;
	}

	// 判断文件是否可以被删除
	@RequestMapping(value = "/canBeDeleted")
	@ResponseBody
	public Map canBeDeleted(HttpServletRequest request) {
		String paths = request.getParameter("paths");
		String clusterId = request.getParameter("clusterId");
		Map res = new HashMap();
		try {
			String[] filePathArr = paths.split(",");
			res = fileSystemService.canBeDeleted(clusterId, filePathArr);
		} catch (Exception e) {
			res.put("result", false);
			log.error("判断文件是否可被删除时出错：",e);
		}
		return res;
	}
	// 判断文件是否是文件
		@RequestMapping(value = "/isDir")
		@ResponseBody
		public Map isDir(HttpServletRequest request) {
			Map map = new HashMap();
			boolean res = false;
			String permission = null;
			String path = request.getParameter("path");
			String clusterId = request.getParameter("clusterId");
			try {
				res = fileSystemService.isDirectory(clusterId, path);
				permission = fileSystemService.obtainPermission(clusterId, path);
			} catch (Exception e) {
				log.error("判断文件是否可被删除时出错：",e);
			}
			map.put("result", res);
			map.put("permission",permission);
			return map;
		}

	// 删除文件
	@RequestMapping(value = "/deleteFile")
	@ResponseBody
	public String deleteFile(HttpServletRequest request) {
		String paths = request.getParameter("paths");
		String clusterId = request.getParameter("clusterId");
		String message = "";
		try {
			String[] filePathArr = paths.split(",");
			message = fileSystemService.deleteFile(clusterId, filePathArr);
		} catch (Exception e) {
			message = "删除文件出现异常，请查看日志!";
			log.error("删除文件出错：",e);
		}
		return message;
	}

	// 上传文件
	@RequestMapping(value = "/uploadFile")
	@ResponseBody
	public boolean uploadFile(HttpServletRequest request) {
		String clusterId = request.getParameter("clusterId");
		String path = request.getParameter("path");
		if (path == null || path.equals(""))
			path = "/";
		MultipartHttpServletRequest multipartRequest = (MultipartHttpServletRequest) request;
		Map<String, MultipartFile> files = multipartRequest.getFileMap();
		Iterator<String> fileNames = multipartRequest.getFileNames();
		boolean res = false;
		while (fileNames.hasNext()) {
			InputStream is = null;
			try {
				path = new String(path.getBytes("iso-8859-1"), "utf-8");
				String name = fileNames.next();
				CommonsMultipartFile file = (CommonsMultipartFile) files
						.get(name);

				is = file.getInputStream();
				String dir;
				if (path.endsWith("/"))
					dir = path + file.getOriginalFilename();
				else
					dir = path + "/" + file.getOriginalFilename();
				res = FileSystemUtil.uploadFile(clusterId, is, dir);
			} catch (Exception e) {
				res = false;
				log.error("uploadFile出错：",e);
			} finally {
				if (is != null) {
					try {
						is.close();
					} catch (IOException e) {
						log.error("uploadFile中关闭流出错：",e);
					}
				}
			}
		}
		return res;
	}

	// 下载文件
	@RequestMapping("/downloadFile")
	public void downloadFile(HttpServletRequest request,
			HttpServletResponse response) {
		try {
			String filepath = request.getParameter("path");
			String fileName = request.getParameter("fileName");
			String clusterId = request.getParameter("clusterId");
			String lenth = request.getParameter("length");
			FileSystem fs = FileSystemUtil.getFileSystem(clusterId);
			// 以流的形式下载文件。
			FSDataInputStream fis = fs.open(new Path(filepath));// 读取文件
			// FileStatus stat = fs.getFileStatus(new Path(filepath));
			byte[] buffer = new byte[fis.available()];
			fis.readFully(0, buffer);
			fis.close();
		//	fs.close();
			// 清空response
			response.reset();
			String fname = encodeFileName(request, fileName);
			response.setHeader("Content-Disposition", "attachment; filename="
					+ fname);
			response.setContentType("application/octet-stream");
			response.setHeader("Content-Length", "" + lenth);
			OutputStream toClient = new BufferedOutputStream(
					response.getOutputStream());
			toClient.write(buffer);
			toClient.flush();
			toClient.close();
		} catch (Exception e) {
			log.error("downloadFile出错：",e);
		}
	}

	// 根据浏览器判断返回文件名的格式
	private String encodeFileName(HttpServletRequest request, String name)
			throws UnsupportedEncodingException {
		String agent = request.getHeader("USER-AGENT");
		if (null != agent && -1 != agent.indexOf("MSIE")) {
			return URLEncoder.encode(name, "UTF-8");
		} else if (null != agent && -1 != agent.indexOf("Mozilla")) {
			return new String(name.getBytes("GBK"), "iso8859-1");
		} else if (null != agent && -1 != agent.indexOf("HttpClient")) {
			return URLEncoder.encode(name, "UTF-8");
		} else {
			return name;
		}
	}

	// 判断文件路径是否已经存在
	@RequestMapping(value = "/existPath")
	@ResponseBody
	public boolean existPath(HttpServletRequest request) {
		String clusterId = request.getParameter("clusterId");
		String parentPath = request.getParameter("parentPath");
		if (parentPath == null || parentPath.equals(""))
			parentPath = "/";
		String newFileName = request.getParameter("newFileName");
		boolean result = false;
		try {
			String dir = parentPath;
			if (newFileName != null && !newFileName.equals("")) {
				if (parentPath.endsWith("/"))
					dir = parentPath + newFileName;
				else
					dir = parentPath + "/" + newFileName;
			}
			result = fileSystemService.existPath(clusterId, dir);
		} catch (Exception e) {
			log.error("existPath中path转码出错：",e);
		}
		return result;
	}
	//修改文件权限
	@RequestMapping(value = "/modifypermission")
	@ResponseBody
	public boolean modifypermission(HttpServletRequest request) {
		String clusterId = request.getParameter("clusterId");
		String parentPath = request.getParameter("parentPath");
		int str_user = Integer.parseInt(request.getParameter("str_user")) ;
		int str_group = Integer.parseInt(request.getParameter("str_group"));
		int str_other =  Integer.parseInt(request.getParameter("str_other"));
		String dir = request.getParameter("path");
		if (parentPath == null || parentPath.equals(""))
			parentPath = "/";
		boolean result = true;
		try {
			if(fileSystemService.isDirectory(clusterId, dir)){
				result = fileSystemService.changeDirAllRight(clusterId,dir,str_user,str_group,str_other);
			}else{
				result = fileSystemService.changeFileAllRight(clusterId, dir, str_user, str_group, str_other);
			}
			
		} catch (Exception e) {
			log.error("modifyPermission失败", e);
		}
		return result;
	}
	// 重命名文件
	@RequestMapping(value = "/rename")
	@ResponseBody
	public boolean rename(HttpServletRequest request) {
		String clusterId = request.getParameter("clusterId");
		String parentPath = request.getParameter("parentPath");
		if (parentPath == null || parentPath.equals(""))
			parentPath = "/";
		String newFileName = request.getParameter("newFileName");
		String oldPath = request.getParameter("oldPath");
		boolean result = false;
		try {
			String dir;
			if (parentPath.endsWith("/"))
				dir = parentPath + newFileName;
			else
				dir = parentPath + "/" + newFileName;
			result = fileSystemService.rename(clusterId, oldPath, dir);
		} catch (Exception e) {
			log.error("rename中path转码出错：", e);
		}
		return result;
	}
	
	/*private String getContentType(String returnFileName) {
		String contentType = "application/octet-stream";
		if (returnFileName.lastIndexOf(".") < 0)
			return contentType;
		returnFileName = returnFileName.toLowerCase();
		returnFileName = returnFileName.substring(returnFileName
				.lastIndexOf(".") + 1);
		if (returnFileName.equals("html") || returnFileName.equals("htm")
				|| returnFileName.equals("shtml")) {
			contentType = "text/html";
		} else if (returnFileName.equals("css")) {
			contentType = "text/css";
		} else if (returnFileName.equals("xml")) {
			contentType = "text/xml";
		} else if (returnFileName.equals("gif")) {
			contentType = "image/gif";
		} else if (returnFileName.equals("jpeg")
				|| returnFileName.equals("jpg")) {
			contentType = "image/jpeg";
		} else if (returnFileName.equals("js")) {
			contentType = "application/x-javascript";
		} else if (returnFileName.equals("atom")) {
			contentType = "application/atom+xml";
		} else if (returnFileName.equals("rss")) {
			contentType = "application/rss+xml";
		} else if (returnFileName.equals("mml")) {
			contentType = "text/mathml";
		} else if (returnFileName.equals("txt")) {
			contentType = "text/plain";
		} else if (returnFileName.equals("jad")) {
			contentType = "text/vnd.sun.j2me.app-descriptor";
		} else if (returnFileName.equals("wml")) {
			contentType = "text/vnd.wap.wml";
		} else if (returnFileName.equals("htc")) {
			contentType = "text/x-component";
		} else if (returnFileName.equals("png")) {
			contentType = "image/png";
		} else if (returnFileName.equals("tif")
				|| returnFileName.equals("tiff")) {
			contentType = "image/tiff";
		} else if (returnFileName.equals("wbmp")) {
			contentType = "image/vnd.wap.wbmp";
		} else if (returnFileName.equals("ico")) {
			contentType = "image/x-icon";
		} else if (returnFileName.equals("jng")) {
			contentType = "image/x-jng";
		} else if (returnFileName.equals("bmp")) {
			contentType = "image/x-ms-bmp";
		} else if (returnFileName.equals("svg")) {
			contentType = "image/svg+xml";
		} else if (returnFileName.equals("jar") || returnFileName.equals("var")
				|| returnFileName.equals("ear")) {
			contentType = "application/java-archive";
		} else if (returnFileName.equals("doc")) {
			contentType = "application/msword";
		} else if (returnFileName.equals("pdf")) {
			contentType = "application/pdf";
		} else if (returnFileName.equals("rtf")) {
			contentType = "application/rtf";
		} else if (returnFileName.equals("xls")) {
			contentType = "application/vnd.ms-excel";
		} else if (returnFileName.equals("ppt")) {
			contentType = "application/vnd.ms-powerpoint";
		} else if (returnFileName.equals("7z")) {
			contentType = "application/x-7z-compressed";
		} else if (returnFileName.equals("rar")) {
			contentType = "application/x-rar-compressed";
		} else if (returnFileName.equals("swf")) {
			contentType = "application/x-shockwave-flash";
		} else if (returnFileName.equals("rpm")) {
			contentType = "application/x-redhat-package-manager";
		} else if (returnFileName.equals("der") || returnFileName.equals("pem")
				|| returnFileName.equals("crt")) {
			contentType = "application/x-x509-ca-cert";
		} else if (returnFileName.equals("xhtml")) {
			contentType = "application/xhtml+xml";
		} else if (returnFileName.equals("zip")) {
			contentType = "application/zip";
		} else if (returnFileName.equals("mid")
				|| returnFileName.equals("midi")
				|| returnFileName.equals("kar")) {
			contentType = "audio/midi";
		} else if (returnFileName.equals("mp3")) {
			contentType = "audio/mpeg";
		} else if (returnFileName.equals("ogg")) {
			contentType = "audio/ogg";
		} else if (returnFileName.equals("m4a")) {
			contentType = "audio/x-m4a";
		} else if (returnFileName.equals("ra")) {
			contentType = "audio/x-realaudio";
		} else if (returnFileName.equals("3gpp")
				|| returnFileName.equals("3gp")) {
			contentType = "video/3gpp";
		} else if (returnFileName.equals("mp4")) {
			contentType = "video/mp4";
		} else if (returnFileName.equals("mpeg")
				|| returnFileName.equals("mpg")) {
			contentType = "video/mpeg";
		} else if (returnFileName.equals("mov")) {
			contentType = "video/quicktime";
		} else if (returnFileName.equals("flv")) {
			contentType = "video/x-flv";
		} else if (returnFileName.equals("m4v")) {
			contentType = "video/x-m4v";
		} else if (returnFileName.equals("mng")) {
			contentType = "video/x-mng";
		} else if (returnFileName.equals("asx") || returnFileName.equals("asf")) {
			contentType = "video/x-ms-asf";
		} else if (returnFileName.equals("wmv")) {
			contentType = "video/x-ms-wmv";
		} else if (returnFileName.equals("avi")) {
			contentType = "video/x-msvideo";
		}

		return contentType;
	}*/
	
	// 初始select下拉框中的option
	@RequestMapping(value = "/getOptions", method = RequestMethod.GET)
	@ResponseBody
	public Map<String, Object> getOptions() {
		List options = new ArrayList();
		List<Cluster> clusters = clusterService.queryAllCluster();
		for (Cluster cluster : clusters) {
			Map map = new HashMap();
			map.put("clusterId", cluster.getClusterId());
			map.put("clusterName", cluster.getClusterName());
			options.add(map);
		}
		Map<String, Object> optiondata = new HashMap<String, Object>();
		optiondata.put("data", options);
		return optiondata;
	}
}
