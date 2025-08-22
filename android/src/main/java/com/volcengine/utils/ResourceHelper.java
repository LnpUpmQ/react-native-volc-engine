package com.volcengine.utils;

import android.content.Context;

import java.io.File;

public class ResourceHelper {
  public static final String RESOURCE = Config.RESOURCE;
  protected Context mContext;

  public ResourceHelper(Context mContext) {
    this.mContext = mContext;
  }

  public String getResourcePath() {
    return new File(new File(mContext.getFilesDir(), "assets"), RESOURCE).getAbsolutePath();
  }

  public String getAssetModelPath() {
    return RESOURCE + File.separator + "ModelResource.bundle";
  }

  public String getModelPath() {
    return new File(new File(getResourcePath(), "ModelResource.bundle"), "").getAbsolutePath();
  }

  public String getLicensePath() {
    return new File(new File(getResourcePath(), "LicenseBag.bundle"), Config.LICENSE_NAME).getAbsolutePath();
  }

  public String getComposePath() {
    return new File(new File(getResourcePath(), "ComposeMakeup.bundle"), "ComposeMakeup").getAbsolutePath();
  }

  public String getComposePath(String node) {
    return new File(this.getComposePath(), node).getAbsolutePath();
  }


  public String getFilterPath() {
    return new File(new File(getResourcePath(), "FilterResource.bundle"), "Filter").getAbsolutePath();
  }

  public String getFilterPath(String filter) {
    return new File(getFilterPath(), filter).getAbsolutePath();
  }

  public String getStickerPath() {
    return new File(new File(getResourcePath(), "StickerResource.bundle"), "stickers").getAbsolutePath();
  }

  public String getStickerPath(String sticker) {
    return new File(getStickerPath(), sticker).getAbsolutePath();
  }
}
