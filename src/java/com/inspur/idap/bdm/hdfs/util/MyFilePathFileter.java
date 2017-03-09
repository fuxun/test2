package com.inspur.idap.bdm.hdfs.util;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.PathFilter;

/**
 * 文件路径过滤
 * 
 * @author
 * 
 */
public class MyFilePathFileter implements PathFilter {
	
	// 需要读取文件名必须包含fileName字符串
	private String fileName;

	public MyFilePathFileter(String fileName) {
		this.fileName = fileName;
	}

	/**
	 * @param path
	 *            :文件路径 如：hdfs://localhost:9000/hdfs/test/wordcount/in/word.txt
	 */
	@Override
	public boolean accept(Path path) {
		boolean res = false;
		if (path.toString().indexOf(fileName) != -1) {
			res = true;
		}
		System.out.println("path = " + path + "过滤结果：" + res);
		return res;
	}

}