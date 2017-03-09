package com.inspur.idap.bdm.hdfs.service;

import java.util.List;
import java.util.Map;

import com.inspur.idap.bdm.hdfs.util.HdfsException;

public interface IFileSystemService {

	/**
	 * 展示集群下文件系统中某个路径下文件名称含有fileName的所有文件，如果path为null或“”，则展示根路径下的文件,
	 * 如果fileName为空则展示所有文件
	 * 
	 * @param clusterId
	 * @param path
	 * @param fileName
	 * @return
	 * @throws HdfsException
	 */
	public List<Map> listFileStatuses(String clusterId, String path,
			String fileName) throws HdfsException;

	/**
	 * 创建文件
	 * 
	 * @param clusterId
	 *            集群标识
	 * @param dir
	 *            文件路径
	 * @return
	 * @throws HdfsException
	 */
	public boolean createFile(String clusterId, String dir)
			throws HdfsException;

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
	public boolean makeDir(String clusterId, String dir) throws HdfsException;

	/**
	 * 删除hdfs上的文件
	 * 
	 * @param clusterId
	 *            集群实例ID
	 * @param filePathArr
	 *            hdfs文件路径
	 * @return String 如果返回信息为空串，则说明删除成功
	 * @throws HdfsException
	 */
	public String deleteFile(String clusterId, String[] filePathArr)
			throws HdfsException;

	/**
	 * 判断集群下某个路径是否为目录
	 * 
	 * @param clusterId
	 * @param path
	 * @return
	 * @throws HdfsException
	 */
	public boolean isDirectory(String clusterId, String path)
			throws HdfsException;

	/**
	 * 判断文件是否可被批量删除
	 * 
	 * @param clusterId
	 * @param filePathArr
	 * @return map key1:result
	 *         value1:true/false，当为true时可以被删除,false时表示不可以删除;key2:message
	 *         ,value2:提示信息
	 * @throws HdfsException
	 */
	public Map canBeDeleted(String clusterId, String[] filePathArr)
			throws HdfsException;

	/**
	 * 判断指定集群的文件系统中某个文件路径是否已经存在
	 * 
	 * @param clusterId
	 * @param path
	 * @return
	 * @throws HdfsException
	 */
	public boolean existPath(String clusterId, String path)
			throws HdfsException;

	/**
	 * 文件重命名
	 * 
	 * @param clusterId
	 * @param path1
	 * @param path2
	 * @return
	 * @throws HdfsException
	 */
	public boolean rename(String clusterId, String path1, String path2)
			throws HdfsException;
	public  boolean makeDirAllRight(String clusterId, String dir)throws HdfsException;
	/**
	 * 修改权限
	 * 
	 * @param clusterId
	 * @param path1
	 * @param path2
	 * @return
	 * @throws HdfsException
	 */
	public boolean changeDirAllRight(String clusterId, String dir, int str_user, int str_group, int str_other) throws HdfsException;

	public boolean changeFileAllRight(String clusterId, String dir, int str_user, int str_group, int str_other) throws HdfsException;

	public String obtainPermission(String clusterId, String path) throws HdfsException;

}
