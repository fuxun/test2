package com.inspur.idap.bdm.hdfs.controller;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.text.ParseException;
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
import org.loushang.framework.mybatis.PageUtil;

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
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping(value = "/hdfs/ftp")
public class FtpManagerController {

	private static Log log = LogFactory.getLog(FtpManagerController.class);

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
	/*toftpUdermanage*/
	@RequestMapping(value = "/toftpUsermanage")
	public ModelAndView toftpUserManage(HttpServletRequest request) throws IOException, ParseException {
		Map<String, Object> model = new HashMap<String, Object>();
		return new ModelAndView("bdm/ftp/ftpUsermanage",model);
	}
	// 文件列表信息的查询
	@RequestMapping(value = "/data")
	@ResponseBody
	public Map getData(HttpServletRequest request) {
		Map<String, Object> filedata = new HashMap<String, Object>();
		List files = new ArrayList();
		Map<String,String> map1 = new HashMap<String,String>();
		map1.put("task_name", "fx");
		map1.put("job_id", "/fx");
		map1.put("cron_text", "2016/10/1");
		files.add(map1);
		Map<String,String> map2 = new HashMap<String,String>();
		map2.put("task_name", "fxss");
		map2.put("job_id", "/root");
		map2.put("cron_text", "2016/10/4");
		files.add(map2);
		filedata.put("data", files);
		int total = PageUtil.getTotalCount();
		filedata.put("total", total != -1 ? total : files.size());
		return filedata;
	}



}
