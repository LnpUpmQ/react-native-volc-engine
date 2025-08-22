package com.volcengine

import android.app.ActivityManager
import android.content.Context
import android.util.Log
import com.effectsar.labcv.effectsdk.EffectsSDKEffectConstants
import com.effectsar.labcv.effectsdk.RenderManager
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.volcengine.utils.Config
import com.volcengine.utils.DataHelper
import com.volcengine.utils.FileUtils
import com.volcengine.utils.ImageUtil
import com.volcengine.utils.ResourceHelper
import im.zego.zegoexpress.ZegoExpressEngine
import im.zego.zegoexpress.callback.IZegoCustomVideoProcessHandler
import im.zego.zegoexpress.constants.ZegoPublishChannel
import im.zego.zegoexpress.constants.ZegoVideoBufferType
import im.zego.zegoexpress.entity.ZegoCustomVideoProcessConfig
import java.io.File

class VolcEngineModule internal constructor(context: ReactApplicationContext) :
  VolcEngineSpec(context) {
  private var debug: Boolean = true
  private val TAG = "VolcEngineModule"

  private val mContext = context
  private var mResourceHelper = ResourceHelper(context)
  private var mDataHelper = DataHelper(context)
  private var mRenderManager: RenderManager = RenderManager()
  private lateinit var mImageUtil: ImageUtil

  private var _inited: Boolean = false
  private var _processing: Boolean = false // 是否美颜中
  private var _process_paused: Boolean = false // 暂停预览原图

  override fun getName(): String {
    return NAME
  }

  private fun log(string: String) {
    if (debug) {
      Log.println(Log.DEBUG, TAG, string)
    }
  }

  /**
   * 检查将资源文件（copy to filesDir)
   */
  private fun checkResourceReady(version: String, callback: Callback): Int {
    var ret = 0
    try {
      val checkFile = File(mResourceHelper.resourcePath, "$version.txt")
      if (!checkFile.exists()) {
        Thread {
          FileUtils.copyAssets(
            mContext.assets,
            Config.RESOURCE,
            File(mContext.filesDir, "assets").absolutePath
          )
          checkFile.appendText("done")
          log("copyAssets done")
          callback.invoke()
        }.start()
      } else {
        callback.invoke()
      }
    } catch (e: Error) {
      ret = -1
      log("check resource fail: $e")
    }
    return ret
  }


  @ReactMethod
  override fun init(license: String, version: String, promise: Promise) {
    try {
      log("init with license:$license")
      Config.LICENSE_NAME = license
      checkResourceReady(version) {
        _inited = initRender()
        promise.resolve(if (_inited) 0 else -1)
      }
    }
    catch (e: Error) {
      log("init fail: $e")
      promise.resolve(-1)
    }
  }

  private fun initRender(): Boolean {
    mImageUtil = ImageUtil()
    val am = mContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    val renderApi = if ((am.deviceConfigurationInfo.reqGlEsVersion >= 0x30000)) 1 else 0
    val ret = mRenderManager.init(
      mContext,
      mResourceHelper.assetModelPath,
      mResourceHelper.licensePath,
      mContext.cacheDir.absolutePath,
      false,
      false,
      true,
      renderApi
    )
    return ret == 0
  }

  /**
   * 应用美颜设置
   */
  private fun applyEffect() {
    try {
      mRenderManager.setComposerNodes(mDataHelper.getComposeNodes())
      mDataHelper.getComposeNodeItem().forEach(fun(it) {
        mRenderManager.updateComposerNodes(it.path, it.key, it.intensity)
      })
      mRenderManager.setFilter(mDataHelper.getFilter())
      mRenderManager.updateIntensity(
        EffectsSDKEffectConstants.IntensityType.Filter.id, mDataHelper.getFilterIntensity()
      )
      mRenderManager.setSticker(mDataHelper.getSticker())
    } catch (e: Error) {
      log("apply effect fail: $e")
    }
  }

  /**
   * 开启/关闭美颜
   */
  @ReactMethod
  override fun enableCustomVideoProcessing(
    enable: Boolean, channel: Double, promise: Promise
  ) {
    log("enableCustomVideoProcessing: $enable, $channel, $_inited")
    try {

      if (!_inited) {
        return promise.resolve(-1)
      }

      // 开启自定义视频处理
      val videoProcessConfig = ZegoCustomVideoProcessConfig()
      videoProcessConfig.bufferType = ZegoVideoBufferType.GL_TEXTURE_2D


      ZegoExpressEngine.getEngine()
        .setCustomVideoProcessHandler(if (enable) processHandle else null)

      ZegoExpressEngine.getEngine().enableCustomVideoProcessing(
        enable,
        videoProcessConfig,
        ZegoPublishChannel.getZegoPublishChannel(channel.toInt())
      )

      promise.resolve(0)
    } catch (e: Error) {
      log("enableCustomVideoProcessing fail: $e")
      promise.resolve(-1)
    }
  }

  @ReactMethod
  override fun pauseProcessing(paused: Boolean, promise: Promise) {
    _process_paused = paused
    promise.resolve(0)
  }

  /**
   * 图像帧处理句柄
   */
  private var processHandle: IZegoCustomVideoProcessHandler =
    object : IZegoCustomVideoProcessHandler() {
      override fun onStart(channel: ZegoPublishChannel) {
        log("custom process start")
        _processing = initRender()
        _process_paused = false;
        applyEffect()
      }

      override fun onStop(channel: ZegoPublishChannel) {
        log("custom process stop")
        _processing = false
        _process_paused = false;
        mRenderManager.release()
      }

      // 从引擎接收 Texture
      override fun onCapturedUnprocessedTextureData(
        textureID: Int,
        width: Int,
        height: Int,
        referenceTimeMillisecond: Long,
        channel: ZegoPublishChannel
      ) {
        if (_processing && !_process_paused) {
          // 准备帧缓冲区纹理对象
          val dstTextureID: Int = mImageUtil.prepareTexture(width, height)
          // val timestamp = System.nanoTime()
          val ret = mRenderManager.processTexture(
            textureID,
            dstTextureID,
            width,
            height,
            EffectsSDKEffectConstants.Rotation.CLOCKWISE_ROTATE_0,
            referenceTimeMillisecond + 1000000000000
          )
//                    log("onCapturedUnprocessedTextureData:$ret, $width, $height, $referenceTimeMillisecond")

          ZegoExpressEngine.getEngine().sendCustomVideoProcessedTextureData(
            dstTextureID,
            width,
            height,
            referenceTimeMillisecond,
            channel
          )
        } else {
          ZegoExpressEngine.getEngine().sendCustomVideoProcessedTextureData(
            textureID,
            width,
            height,
            referenceTimeMillisecond,
            channel
          )
        }
      }
    }


  @ReactMethod
  override fun setComposeNodes(nodes: ReadableArray, promise: Promise) {
    try {
      if (!_inited) {
        return promise.resolve(-1)
      }

      val mComposeNodes = mDataHelper.saveComposeNodes(
        nodes.toArrayList()
          .filter(fun(node): Boolean {
            return node.toString() != "null" && node.toString().isNotEmpty()
          })
          .map(fun(node): String {
            return mResourceHelper.getComposePath(node.toString())
          })
      )

      val ret = mRenderManager.setComposerNodes(mComposeNodes)

      promise.resolve(ret)

      log("setComposeNodes: $nodes, $ret")
    } catch (e: Error) {
      log("setComposeNodes fail: $e")
      promise.resolve(-1)
    }
  }


  @ReactMethod
  override fun updateComposerNodeIntensity(
    node: String, key: String, intensity: Double, promise: Promise
  ) {
    try {
      if (!_inited || node.isEmpty()) {
        return promise.resolve(-1)
      }
      val path = mResourceHelper.getComposePath(node);

      mDataHelper.saveComposeNodeItem(path, key, intensity.toFloat())

      val ret = mRenderManager.updateComposerNodes(path, key, intensity.toFloat())

      promise.resolve(ret)

      log("updateComposerNodeIntensity: $node, $key, $intensity, $ret")
    } catch (e: Error) {
      log("updateComposerNodeIntensity fail: $e")
      promise.resolve(-1)
    }
  }


  @ReactMethod
  override fun setFilter(path: String, promise: Promise) {
    try {
      if (!_inited) {
        return promise.resolve(-1)
      }

      val ret: Boolean
      if (path.isEmpty()) {
        ret = mRenderManager.setFilter(null)
      } else {
        val mFilter = mDataHelper.saveFilter(mResourceHelper.getFilterPath(path))
        ret = mRenderManager.setFilter(mFilter)
      }

      promise.resolve(ret)

      log("setFilter: $path, $ret")
    } catch (e: Error) {
      log("setFilter fail: $e")
      promise.resolve(-1)
    }
  }


  @ReactMethod
  override fun updateFilterIntensity(intensity: Double, promise: Promise) {
    try {
      if (!_inited) {
        return promise.resolve(-1)
      }

      val mFilterIntensity = mDataHelper.saveFilterIntensity(intensity.toFloat())

      val ret = mRenderManager.updateIntensity(
        EffectsSDKEffectConstants.IntensityType.Filter.id,
        mFilterIntensity
      )

      promise.resolve(ret)

      log("updateFilterIntensity: $intensity, $ret")
    } catch (e: Error) {
      log("updateFilterIntensity fail: $e")
      promise.resolve(-1)
    }
  }

  @ReactMethod
  override fun setSticker(path: String, promise: Promise) {
    try {
      if (!_inited) {
        return promise.resolve(-1)
      }

      val ret: Boolean
      if (path.isEmpty()) {
        ret = mRenderManager.setSticker(null)
      } else {
        val mSticker = mDataHelper.saveSticker(mResourceHelper.getStickerPath(path))
        ret = mRenderManager.setSticker(mSticker)
      }

      promise.resolve(ret)

      log("setSticker: $path, $ret")
    } catch (e: Error) {
      log("setSticker fail: $e")
      promise.resolve(-1)
    }
  }


  companion object {
    const val NAME = "VolcEngine"
  }
}
