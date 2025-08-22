package com.volcengine.utils;

import android.content.res.AssetManager;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Objects;

public class FileUtils {
  public static void copyAssets(AssetManager assets, String path, String rootDir) throws IOException {
    if (isAssetsDir(assets, path)) {
      File dir = new File(rootDir + File.separator + path);
      if (!dir.exists() && !dir.mkdirs()) {
        throw new IllegalStateException("mkdir failed");
      }
      for (String s : Objects.requireNonNull(assets.list(path))) {
        copyAssets(assets, path + "/" + s, rootDir);
      }
    } else {
      InputStream input = assets.open(path);
      File dest = new File(rootDir, path);
      copyToFileOrThrow(input, dest);
    }

  }


  public static void copyAssets(AssetManager assets, String srcRootDir, String path, String rootDir) throws IOException {
    String fullAssetPath = new File(srcRootDir, path).toString();
    if (isAssetsDir(assets, fullAssetPath)) {
      File dir = new File(rootDir + File.separator + path);
      if (!dir.exists() && !dir.mkdirs()) {
        throw new IllegalStateException("mkdir failed");
      }
      String[] pathList = assets.list(fullAssetPath);
      if (pathList != null) {
        for (String s : pathList) {
          copyAssets(assets, srcRootDir, path + "/" + s, rootDir);
        }
      }
    } else {
      InputStream input = assets.open(fullAssetPath);
      File dest = new File(rootDir, path);
      copyToFileOrThrow(input, dest);
    }

  }

  public static boolean isAssetsDir(AssetManager assets, String path) {
    try {
      String[] files = assets.list(path);
      return files != null && files.length > 0;
    } catch (IOException ignored) {
    }
    return false;
  }

  public static void copyToFileOrThrow(InputStream inputStream, File destFile)
    throws IOException {
    if (destFile.exists()) {
      return;

    }
    File file = destFile.getParentFile();
    if (file != null && !file.exists()) {
      file.mkdirs();
    }
    FileOutputStream out = new FileOutputStream(destFile);
    try {
      byte[] buffer = new byte[4096];
      int bytesRead;
      while ((bytesRead = inputStream.read(buffer)) >= 0) {
        out.write(buffer, 0, bytesRead);
      }
    } finally {
      out.flush();
      try {
        out.getFD().sync();
      } catch (IOException ignored) {
      }
      out.close();
    }
  }

}
