package com.volcengine.utils;

import android.graphics.Point;
import android.opengl.GLES20;

public class ImageUtil {


  protected int[] mFrameBuffers;
  protected int[] mFrameBufferTextures;
  protected int FRAME_BUFFER_NUM = 1;
  protected Point mFrameBufferShape;


  public ImageUtil() {
  }

  /** {zh}
   * 准备帧缓冲区纹理对象
   *
   * @param width  纹理宽度
   * @param height 纹理高度
   * @return 纹理ID
   */
  /**
   * {en}
   * Prepare frame buffer texture object
   *
   * @param width  texture width
   * @param height texture height
   * @return texture ID
   */

  public int prepareTexture(int width, int height) {
    initFrameBufferIfNeed(width, height);
    return mFrameBufferTextures[0];
  }


  /** {zh}
   * 初始化帧缓冲区
   *
   * @param width  缓冲的纹理宽度
   * @param height 缓冲的纹理高度
   */
  /**
   * {en}
   * Initialize frame buffer
   *
   * @param width  buffered texture width
   * @param height buffered texture height
   */
  private void initFrameBufferIfNeed(int width, int height) {
    boolean need = false;
    if (null == mFrameBufferShape || mFrameBufferShape.x != width || mFrameBufferShape.y != height) {
      need = true;
    }
    if (mFrameBuffers == null || mFrameBufferTextures == null) {
      need = true;
    }
    if (need) {
      destroyFrameBuffers();
      mFrameBuffers = new int[FRAME_BUFFER_NUM];
      mFrameBufferTextures = new int[FRAME_BUFFER_NUM];
      GLES20.glGenFramebuffers(FRAME_BUFFER_NUM, mFrameBuffers, 0);
      GLES20.glGenTextures(FRAME_BUFFER_NUM, mFrameBufferTextures, 0);
      for (int i = 0; i < FRAME_BUFFER_NUM; i++) {
        bindFrameBuffer(mFrameBufferTextures[i], mFrameBuffers[i], width, height);
      }
      mFrameBufferShape = new Point(width, height);
    }

  }

  /** {zh}
   * 销毁帧缓冲区对象
   */
  /**
   * {en}
   * Destroy frame buffer objects
   */
  private void destroyFrameBuffers() {
    if (mFrameBufferTextures != null) {
      GLES20.glDeleteTextures(FRAME_BUFFER_NUM, mFrameBufferTextures, 0);
      mFrameBufferTextures = null;
    }
    if (mFrameBuffers != null) {
      GLES20.glDeleteFramebuffers(FRAME_BUFFER_NUM, mFrameBuffers, 0);
      mFrameBuffers = null;
    }
  }

  /** {zh}
   * 纹理参数设置+buffer绑定
   * set texture params
   * and bind buffer
   */
  /**
   * {en}
   * Texture parameter setting + buffer binding
   * set texture params
   * and binding buffer
   */
  private void bindFrameBuffer(int textureId, int frameBuffer, int width, int height) {
    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);
    GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, width, height, 0,
      GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null);
    GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
      GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
      GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
      GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D,
      GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);

    GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, frameBuffer);
    GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0,
      GLES20.GL_TEXTURE_2D, textureId, 0);

    GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
    GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
  }

}
