package com.inspur.idap.bdm.hdfs.util;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.security.auth.Subject;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.ContentSummary;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.permission.FsAction;
import org.apache.hadoop.fs.permission.FsPermission;
import org.apache.hadoop.hdfs.DistributedFileSystem;
import org.apache.hadoop.hdfs.protocol.HdfsConstants;
import org.apache.hadoop.security.UserGroupInformation;
import org.apache.hadoop.util.Progressable;

import com.inspur.idap.bdm.config.data.Cluster;
import com.inspur.idap.bdm.utils.BdmUtil;

/**
 * Hdfs文件操作工具类
 * 
 * @author huxiaoqing
 * 
 */
public class FileSystemUtil {

	// private static final String HDFS_FS_DEFAULTFS = "fs.defaultFS";

	// private static final String HDFS_DFS_NAMESERVICES = "dfs.nameservices";

	private static Log log = LogFactory.getLog(FileSystemUtil.class);

	//fileSystem缓冲
	private static Map fileSystemCache = new HashMap();

	public final static Map PERMISSIONMAP = new HashMap();
	static{
		PERMISSIONMAP.put(7, FsAction.ALL);
		PERMISSIONMAP.put(6, FsAction.READ_WRITE);
		PERMISSIONMAP.put(5, FsAction.READ_EXECUTE);
		PERMISSIONMAP.put(4, FsAction.READ);
		PERMISSIONMAP.put(3, FsAction.WRITE_EXECUTE);
		PERMISSIONMAP.put(2, FsAction.WRITE);
		PERMISSIONMAP.put(1, FsAction.EXECUTE);
		PERMISSIONMAP.put(0, FsAction.NONE);
	}
	/**
	 * 根据集群标识获取文件系统
	 * 
	 * @param clusterId
	 * @return
	 * @throws HdfsException
	 * @throws IOException
	 */
	public synchronized static FileSystem getFileSystem(String clusterId)
			throws HdfsException {
		// 首先判断大数据参数管理下的hdfs缓存是否存在，如不存在，说明可能修改过hdfs的参数配置 ，因此需要重新获取文件系统
//		Map cachedInfo = (Map) BdmUtil.cofigMap.get(clusterId + "_"
//				+ BdmUtil.COMPONENT_HDFS);
//		if (cachedInfo == null || cachedInfo.isEmpty()) {
//			fileSystemCache.clear();
//		}
//		FileSystem fs = (FileSystem) fileSystemCache.get(clusterId);
		FileSystem fs = null;
//		if (fs == null) {
			try {
				Map<String, String> map = BdmUtil.getHdfsConf(clusterId);
				log.debug("获取的配置信息:" + map);
				String uri=map.get("fs.defaultFS");
				if(uri == null || "null".equals(uri)|| "".equals(uri)){
					log.error("标识为" + clusterId + "的集群，在大数据集群配置中配置信息错误！");
					throw new HdfsException("标识为" + clusterId + "的集群，在大数据集群配置中配置信息错误！");
				}
				Configuration conf = new Configuration();
				String user="";
				for (Map.Entry<String, String> entry : map.entrySet()) {
					if ("fs.defaultFS".equals(entry.getKey())) {
						uri = entry.getValue();
					} else if("HADOOP_USER_NAME".equals(entry.getKey())){
						user= entry.getValue();
					}else {
						conf.set(entry.getKey(), entry.getValue());
					}
				}
				conf.set("fs.defaultFS", uri);
				conf.set("dfs.cluster.administrators", user);
				//fs = FileSystem.get(conf);
				//配置kerberos认证
				String kerberosFlag = BdmUtil.getClusterByClusterId(clusterId).getKerberosFlag();
				if(Cluster.KERBEROSFLAG_YES.equals(kerberosFlag)){
					conf.set("hadoop.security.authentication","kerberos");
					conf.set("hadoop.security.authorization","true");
				}else{
					//不启用kerberos,则采用默认值
					conf.set("hadoop.security.authentication","simple");
					conf.set("hadoop.security.authorization","false");
				}
				//如果启用kerbeos,则使用票据和凭证进行认证
				//获取认证文件路径，krb5.conf和keytab
				String dstPath=Thread.currentThread().getContextClassLoader().getResource("").toString();
				dstPath=dstPath.substring(5,dstPath.length()-16)+"download/";
				if (Cluster.KERBEROSFLAG_YES.equals(kerberosFlag)) {
					String realm="@"+BdmUtil.getKerberosRealmName(clusterId);//example:   @IDAP.COM
					dstPath=dstPath+clusterId+'/';
					System.clearProperty("java.security.krb5.conf");
					String krbStr=dstPath+"krb5.conf";
					String userInfo="hdfs-"+BdmUtil.getClusterByClusterId(clusterId).getClusterNameManager()+realm;
					String userkeytab=dstPath+"hdfs.headless.keytab";
					// 初始化配置文件
					System.setProperty("java.security.krb5.conf",krbStr);	
					// 使用票据和凭证进行认证(需替换为自己申请的kerberos票据信息)
					UserGroupInformation.setConfiguration(conf);
					try{
						sun.security.krb5.Config.refresh();
					}catch (Exception e) {
						log.error("刷新kerberos config信息报错：",e);
					}
					UserGroupInformation.loginUserFromKeytab(userInfo,userkeytab);	
					fs = FileSystem.get(conf);
				}else{
					System.clearProperty("java.security.krb5.conf");
					String krbStr=dstPath+"krb5_template.conf";	
					System.setProperty("java.security.krb5.conf", krbStr);
					UserGroupInformation.setConfiguration(conf);
					try {
						sun.security.krb5.Config.refresh();
					} catch (Exception e) {
						log.error("刷新无kerberos config信息报错：", e);
					}
					UserGroupInformation.loginUserFromSubject(null);
					Subject subject = new Subject();
					UserGroupInformation.loginUserFromSubject(subject);
					fs = FileSystem.get(new URI(uri),conf,user);
				}
			} catch (Exception e) {
				log.error("根据集群标识" + clusterId + "获取文件系统出错！",e);
				throw new HdfsException("根据集群标识" + clusterId + "获取文件系统出错！");
			}
//		}
		return fs;
	}

	/**
	 * 获取指定集群指定目录下所有文件名称含有fileName的所有文件列表,如果fileName为空，则展示所有文件
	 * 
	 * @param clusterId
	 * @param path
	 * @param fileName
	 * @return
	 * @throws HdfsException
	 */
	public static List<Map> listFileStatuses(String clusterId, String path,
			String fileName) throws HdfsException {
		List resList = new ArrayList();
		try {
			FileSystem fs = FileSystemUtil.getFileSystem(clusterId);
			if (null == path || "".equals(path))
				path = "/";
			FileStatus[] statuses;
			if (null == fileName || "".equals(fileName)) {
				statuses = fs.listStatus(new Path(path));
			} else {
				MyFilePathFileter pathFileter = new MyFilePathFileter(fileName);
				statuses = fs.listStatus(new Path(path), pathFileter);
			}
			for (FileStatus fileStatus : statuses) {
				Map map = new HashMap();
				map.put("fileName", fileStatus.getPath().getName());
				map.put("permission", fileStatus.getPermission().toString());
				map.put("owner", fileStatus.getOwner());
				map.put("group", fileStatus.getGroup());
				map.put("length", fileStatus.getLen());
				/*
				 * map.put("replication", fileStatus.getReplication());
				 * map.put("blockSize", fileStatus.getBlockSize());
				 */
				map.put("modificationTime",
						format(fileStatus.getModificationTime()));
				map.put("path", fileStatus.getPath().toString());
				map.put("isDirectory", fileStatus.isDirectory());
				resList.add(map);
			}
			return resList;
		} catch (Exception e) {
			log.error(e);
			throw new HdfsException("根据集群标识" + clusterId + "获取路径" + path
					+ "下的文件出错，异常信息:" + e.getMessage());
		}
	}
    /**
     * 获取文件权限
     * @throws HdfsException 
     */
	public static String obtainPermission(String clusterId, String path) throws HdfsException{
		String str=null;
		Path hdfsDir = new Path(path);
		try {
			FileSystem fs = FileSystemUtil.getFileSystem(clusterId);
			FileStatus fileStatus = fs.getFileStatus(new Path(path));
			str = fileStatus.getPermission().toString();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return str;
	}
	private static String format(long time) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		return sdf.format(new Timestamp(time));
	}

	/**
	 * 在指定集群Hdfs上创建目录
	 * 
	 * @param clusterId
	 *            集群实例ID
	 * @param dir
	 *            hdfs文件目录
	 * @return boolean 是否创建成功
	 * @throws HdfsException
	 */
	public static boolean makeDir(String clusterId, String dir)
			throws HdfsException {
		boolean isSuccess = false;
		Path hdfsDir = new Path(dir);
		FileSystem fs = getFileSystem(clusterId);
		//log.debug("用户:" + System.getProperty("HADOOP_USER_NAME"));
		try {
			isSuccess = fs.mkdirs(hdfsDir);
		} catch (IOException e) {
			log.error("创建文件目录出现异常!",e);
			throw new HdfsException("创建文件目录出现异常!" + e.getMessage());
		}

		return isSuccess;
	}
	
	/**
	 * 在指定集群Hdfs上创建目录,权限为777
	 * 
	 * @param clusterId
	 *            集群实例ID
	 * @param dir
	 *            hdfs文件目录
	 * @return boolean 是否创建成功
	 * @throws HdfsException
	 */
	public static boolean makeDirAllRight(String clusterId, String dir)
			throws HdfsException {
		boolean isSuccess = false;
		Path hdfsDir = new Path(dir);
		FileSystem fs = getFileSystem(clusterId);
		try {
			FsPermission permission = new FsPermission(FsAction.ALL,FsAction.ALL,FsAction.ALL);
			isSuccess = fs.mkdirs(hdfsDir);
			if(isSuccess){
				fs.setPermission(hdfsDir, permission);
			}
		} catch (IOException e) {
			log.error("创建文件目录出现异常!",e);
			throw new HdfsException("创建文件目录出现异常!" + e.getMessage());
		}

		return isSuccess;
	}
 
	/**
	 * 在指定集群中创建文件
	 * 
	 * @param clusterId
	 * @param dir
	 * @return
	 * @throws HdfsException
	 */
	public static boolean createFile(String clusterId, String dir)
			throws HdfsException {
		boolean isSuccess = false;
		Path hdfsDir = new Path(dir);
		FileSystem fs = getFileSystem(clusterId);
		//log.debug("用户:" + System.getProperty("HADOOP_USER_NAME"));
		try {
			isSuccess = fs.createNewFile(hdfsDir);
		} catch (IOException e) {
			log.error("创建文件出现异常!",e);
			throw new HdfsException("创建文件出现异常!" + e.getMessage());
		}

		return isSuccess;
	}

	public static boolean isDirectory(String clusterId, String path)
			throws HdfsException {
		try {
			FileSystem fs = getFileSystem(clusterId);
			return fs.isDirectory(new Path(path));
		} catch (IOException e) {
			log.error("出现异常!",e);
			throw new HdfsException("出现异常!" + e.getMessage());
		}
	}

	public static Map canBeDeleted(String clusterId, String[] filePathArr)
			throws HdfsException {
		FileSystem fs = getFileSystem(clusterId);
		Map resMap = new HashMap();
		boolean res = true;
		String message = "";
		try {
			for (String filePath : filePathArr) {
				if (fs.exists(new Path(filePath))) {
					if (fs.isDirectory(new Path(filePath))) {
						FileStatus[] arr = fs.listStatus(new Path(filePath));
						if (arr.length > 0) {
							res = false;
							message = "文件夹" + new Path(filePath).getName() + "不为空，不能被删除!";
							break;
						}
					}
				}
			}
		} catch (IOException e) {
			res = false;
			message = "校验文件是否能被删除时，出现错误！";
			log.error("出现异常!",e);
			throw new HdfsException("canBeDeleted方法出错:" + e.getMessage());
		}
		resMap.put("result", res);
		resMap.put("message", message);
		return resMap;
	}

	/**
	 * 以输入流的方式上传文件到指定集群Hdfs目录下
	 * 
	 * @param clusterId
	 *            集群实例ID
	 * @param fis
	 *            输入流
	 * @param path
	 *            hdfs文件路径
	 * @return boolean 是否上传成功
	 * @throws HdfsException
	 */
	public static boolean uploadFile(String clusterId, InputStream fis,
			String path) throws HdfsException {
		BufferedInputStream bi = null;
		BufferedOutputStream bo = null;
		FSDataOutputStream os = null;
		boolean isSuccess = false;
		try {
			FileSystem fs = getFileSystem(clusterId);
			//log.debug("用户:" + System.getProperty("HADOOP_USER_NAME"));
			bi = new BufferedInputStream(fis);
			Path p = new Path(path);
			// 同名文件覆盖
			os = fs.create(p, true);
			bo = new BufferedOutputStream(os);
			byte[] buffer = new byte[1024 * 4];
			int size = 0;
			while (true) {
				size = bi.read(buffer);
				if (size == -1) {
					break;
				} else {
					bo.write(buffer, 0, size);
				}
			}
			isSuccess = true;
		} catch (Exception e) {
			log.error("Hdfs中存储流失败!", e);
			throw new HdfsException("Hdfs中存储流失败!" + e.getMessage());
		} finally {
			try {
				if (bo != null) {
					bo.close();
				}
			} catch (Exception e) {
				log.error("Hdfs中关闭流失败!", e);
			}
		}

		return isSuccess;
	}

	/**
	 * 以输入流的方式从指定集群Hdfs上获取文件信息
	 * 
	 * @param clusterId
	 *            集群实例ID
	 * @param path
	 *            hdfs文件路径
	 * @return Map 文件内容
	 * @throws IOException
	 */
	public static Map readFile(String clusterId, Path path) 
			throws HdfsException {
		Map res = new HashMap();
		StringBuffer sb = new StringBuffer();
		FileSystem filesystem = getFileSystem(clusterId);
		FSDataInputStream fs = null;
		BufferedReader bis = null;
		try {
			fs = filesystem.open(path);
			bis = new BufferedReader(new InputStreamReader(fs, "UTF-8"));
			if (path != null) {
				String temp;
				while ((temp = bis.readLine()) != null) {
					sb.append(temp);
					sb.append("<br>");
				}
				String str = sb.toString();
				str = str.replaceAll("\\\\N", "null"); // 处理空值
				str = str.replaceAll("", ","); // 处理特殊字符
				res.put("code", "1");// 获取成功
				res.put("msg", "获取成功");
				res.put("value", str);
			} else {
				res.put("code", "0");// 获取失败
				res.put("msg", "数据路径为空");
				res.put("value", "");
			}
		} catch (IOException e) {
			log.error("hdfs中获取数据失败!", e);
			res.put("code", "0");// 获取失败
			res.put("msg", "hdfs中获取数据失败!" + e);
			res.put("value", "");
			throw new HdfsException("hdfs中获取数据失败!" + e.getMessage());
		} finally {
			try {
				if (fs != null) {
					bis.close();
					fs.close();
				}
			} catch (Exception e) {
				log.error("hdfs中关闭流失败!", e);
				throw new HdfsException("hdfs中关闭流失败!" + e.getMessage());
			} finally {
				return res;
			}
		}
	}

	/**
	 * 删除hdfs上的文件
	 * 
	 * @param clusterId
	 *            集群实例ID
	 * @param delPath
	 *            hdfs文件路径
	 * @return String 如果返回信息为空串，则说明删除成功
	 * @throws HdfsException
	 */
	public static String deleteFile(String clusterId, String[] filePathArr)
			throws HdfsException {
		String message = "";
		FileSystem fs = getFileSystem(clusterId);
		//log.debug("用户:" + System.getProperty("HADOOP_USER_NAME"));
		try {
			for (String filePath : filePathArr) {
				//判断路径是否存在，如果存在，则删除操作
				if(fs.exists(new Path(filePath))){
					boolean temp = fs.delete(new Path(filePath), false);
					if (!temp) {
						message = message + "文件" + new Path(filePath).getName() + "删除失败!";
					}
				}
			}
		} catch (IOException e) {
			message = "删除文件异常,请查看日志信息!";
			log.error("删除文件出现异常!", e);
			throw new HdfsException("删除文件出现异常!" + e.getMessage());
		}
		return message;
	}

	/**
	 * 判断某个路径是否已经存在
	 * 
	 * @param clusterId
	 * @param path
	 * @return
	 * @throws HdfsException
	 */
	public static boolean existPath(String clusterId, String path)
			throws HdfsException {
		FileSystem fs = getFileSystem(clusterId);
		try {
			return fs.exists(new Path(path));
		} catch (Exception e) {
			log.error("判断文件路径是否存在出现异常!",e);
			throw new HdfsException("判断文件路径是否存在出现异常!" + e.getMessage());
		}
	}

	/**
	 * 重命名文件
	 * 
	 * @param clusterId
	 * @param path1
	 * @param path2
	 * @return
	 * @throws HdfsException
	 */
	public static boolean rename(String clusterId, String path1, String path2)
			throws HdfsException {
		FileSystem fs = getFileSystem(clusterId);
		//log.debug("用户:" + System.getProperty("HADOOP_USER_NAME"));
		try {
			return fs.rename(new Path(path1), new Path(path2));
		} catch (Exception e) {
			log.error("重命名文件路径是否存在出现异常!",e);
			throw new HdfsException("重命名文件路径出现异常!" + e.getMessage());
		}
	}

	public static boolean changeDirAllRight(String clusterId, String dir, int str_user, int str_group, int str_other)
		// TODO Auto-generated method stub
		throws HdfsException {
			boolean isSuccess = false;
			Path hdfsDir = new Path(dir);
			FileSystem fs = getFileSystem(clusterId);
			try {
				FsPermission permission = new FsPermission((FsAction)PERMISSIONMAP.get(str_user),(FsAction)PERMISSIONMAP.get(str_group),(FsAction)PERMISSIONMAP.get(str_other));
				isSuccess = fs.mkdirs(hdfsDir);
				if(isSuccess){
					fs.setPermission(hdfsDir, permission);
				}
			} catch (IOException e) {
				log.error("修改目录权限出现异常!",e);
				throw new HdfsException("修改目录权限出现异常!" + e.getMessage());
			}
			return isSuccess;
	}

	public static boolean changeFileAllRight(String clusterId, String dir, int str_user, int str_group, int str_other) 
		// TODO Auto-generated method stub
		throws HdfsException {
			boolean isSuccess = true;
			Path hdfsDir = new Path(dir);
			FileSystem fs = getFileSystem(clusterId);
			try {
				FsPermission permission = new FsPermission((FsAction)PERMISSIONMAP.get(str_user),(FsAction)PERMISSIONMAP.get(str_group),(FsAction)PERMISSIONMAP.get(str_other));
				fs.setPermission(hdfsDir, permission);
			} catch (IOException e) {
				isSuccess = false;
				log.error("修改文件权限出现异常!",e);
				throw new HdfsException("修改文件权限出现异常!" + e.getMessage());
			}
			return isSuccess;
	}
	
	 /**
     * 设置配额
     * @throws HdfsException 
     */
	public static boolean setQuota(String clusterId, String path, long numQuota,long spaceQuota) throws HdfsException{
		boolean isSuccess = true;
		Path hdfsDir = new Path(path);
		try {
			FileSystem fs = FileSystemUtil.getFileSystem(clusterId);
			((DistributedFileSystem)fs).setQuota(hdfsDir, numQuota, spaceQuota);	
		} catch (IOException e) {
			isSuccess = false;
			log.error("设置配额出现异常!",e);
			throw new HdfsException("设置配额出现异常!" + e.getMessage());
		}
		return isSuccess;
	}
	
	 /**
     * 获取配额
     * @throws HdfsException 
     */
	public static Map<String,Long> getQuota(String clusterId, String path) throws HdfsException{
		Path hdfsDir = new Path(path);
		Map<String,Long> quota=new HashMap<String,Long>();
		try {
			FileSystem fs = FileSystemUtil.getFileSystem(clusterId);
			ContentSummary c = fs.getContentSummary(hdfsDir);
			long spaceQuota=c.getSpaceQuota();
			long numQuota=c.getQuota();
			quota.put("numQuota", numQuota);
			quota.put("spaceQuota", spaceQuota);
			return quota;
		} catch (IOException e) {
			log.error("获取配额出现异常!",e);
			throw new HdfsException("获取配额出现异常!" + e.getMessage());
		}

	}
	
	public static void main(String[] args) throws IOException {
		Configuration conf = new Configuration();
		String uri = "hdfs://jszxcluster";
		conf.set("fs.defaultFS", uri);
		// 在hdfs-site.xml文件中可以找到相关的
		conf.set("dfs.nameservices", "jszxcluster");
		conf.set("dfs.ha.namenodes.jszxcluster", "nn1,nn2");
		conf.set("dfs.namenode.rpc-address.jszxcluster.nn1",
				"idap-agent-238.idap.com:8020");
		conf.set("dfs.namenode.rpc-address.jszxcluster.nn2",
				"idap-agent-242.idap.com:8020");
		String user = "hdfs";
		try {
			FileSystem fs = FileSystem.get(new URI(uri), conf, user);
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
