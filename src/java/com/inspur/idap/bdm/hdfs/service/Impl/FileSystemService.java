package com.inspur.idap.bdm.hdfs.service.Impl;

import java.util.List;
import java.util.Map;

import com.inspur.idap.bdm.hdfs.service.IFileSystemService;
import com.inspur.idap.bdm.hdfs.util.FileSystemUtil;
import com.inspur.idap.bdm.hdfs.util.HdfsException;

import org.springframework.stereotype.Service;

@Service("fileSystemService")
public class FileSystemService implements IFileSystemService {

	public List<Map> listFileStatuses(String clusterId, String path,
			String fileName) throws HdfsException {
		return FileSystemUtil.listFileStatuses(clusterId, path,fileName);
	}

	@Override
	public boolean createFile(String clusterId, String dir)
			throws HdfsException {
		return FileSystemUtil.createFile(clusterId, dir);
	}

	@Override
	public boolean makeDir(String clusterId, String dir) throws HdfsException {
		return FileSystemUtil.makeDir(clusterId, dir);
	}

	@Override
	public String deleteFile(String clusterId, String[] filePathArr)
			throws HdfsException {
		return FileSystemUtil.deleteFile(clusterId, filePathArr);
	}

	public boolean isDirectory(String clusterId, String path)
			throws HdfsException {
		return FileSystemUtil.isDirectory(clusterId, path);
	}

	@Override
	public Map canBeDeleted(String clusterId, String[] filePathArr)
			throws HdfsException {
		return FileSystemUtil.canBeDeleted(clusterId, filePathArr);
	}

	@Override
	public boolean existPath(String clusterId, String path)
			throws HdfsException {
		return FileSystemUtil.existPath(clusterId, path);
	}

	@Override
	public boolean rename(String clusterId, String path1, String path2)
			throws HdfsException {
		return FileSystemUtil.rename(clusterId, path1, path2);
	}
	
	public  boolean makeDirAllRight(String clusterId, String dir) throws HdfsException{
		return FileSystemUtil.makeDirAllRight(clusterId, dir);
	}

	@Override
	public boolean changeDirAllRight(String clusterId, String dir, int str_user, int str_group,
			int str_other) throws HdfsException {
		// TODO Auto-generated method stub
		return FileSystemUtil.changeDirAllRight(clusterId, dir, str_user, str_group, str_other);
	}

	@Override
	public boolean changeFileAllRight(String clusterId, String dir, int str_user, int str_group,int str_other) throws HdfsException {
		// TODO Auto-generated method stub
		return FileSystemUtil.changeFileAllRight(clusterId, dir, str_user, str_group,str_other);
	}

	@Override
	public String obtainPermission(String clusterId, String path) throws HdfsException {
		// TODO Auto-generated method stub
		return FileSystemUtil.obtainPermission(clusterId, path);
	}

}
