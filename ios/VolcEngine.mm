#import "VolcEngine.h"
#import "ResourceHelper.h"
#import "DataHelper.h"
#import "BEGLTexture.h"
#import "ZGCaptureDeviceCamera.h"
#import <EffectsARSDK/bef_effect_ai_api.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <CoreVideo/CoreVideo.h>

static NSString *LICENSE_NAME = @"";
static BOOL debug = YES;
static BOOL usePipeline = NO;
static BOOL useCustomVideoCapture = YES;


@implementation VolcEngine
RCT_EXPORT_MODULE()


void EffectLog(NSString *msg) {
  if(debug) {
    NSLog(@"RN[EffectSDK]: %@", msg);
  }
}

int effectLogCallback(int logLevel, const char* msg) {
  EffectLog([NSString stringWithUTF8String:msg]);
  return 0;
}


ResourceHelper *mResourceHelper = [[ResourceHelper alloc] init];
DataHelper *mDataHelper = [[DataHelper alloc] init];
EAGLContext *_glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
bef_effect_handle_t _handle = nil;


bool _inited = false;
bool _processing = false;
bool _process_paused = false;


RCT_EXPORT_METHOD(init:(NSString *)license  version:(double)version
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  LICENSE_NAME = license;

  bef_effect_result_t ret = BEF_RESULT_SUC;

  [EAGLContext setCurrentContext:_glContext];

  _inited = true;

  resolve(@(ret));
}

/**
 创建&初始化美颜句柄
 */
- (bef_effect_result_t)initHandle {
  EffectLog([NSString stringWithFormat:@"initHandle with %@", _glContext]);

  bef_effect_result_t ret = BEF_RESULT_SUC;

  if(!_handle) {
    if ([EAGLContext currentContext] != _glContext) {
      EffectLog(@"effectsar init and destroy are not run in the same glContext");
      [EAGLContext setCurrentContext:_glContext];
    }

    ret = bef_effect_ai_create(&_handle);

    //    if(debug){
    //      bef_effect_ai_set_log_level(BEF_AI_LOG_LEVEL_WARN);
    //      bef_effect_ai_set_log_callback(effectLogCallback);
    //    }

    ret = bef_effect_ai_check_license(_handle, [mResourceHelper licensePath:LICENSE_NAME]);
    ret = bef_effect_ai_use_pipeline_processor(_handle, usePipeline);
    ret = bef_effect_ai_init(_handle, 360, 640, mResourceHelper.modelDirPath, "");
  }

  return ret;
}


/**
 销毁句柄
 */
- (void)destroyHandle {
  EffectLog([NSString stringWithFormat:@"destroyHandle with %@", _glContext]);

  if(_handle) {
    if ([EAGLContext currentContext] != _glContext) {
      EffectLog(@"effectsar init and destroy are not run in the same glContext");
      [EAGLContext setCurrentContext:_glContext];
    }

    // 销毁句柄
    bef_effect_ai_destroy(_handle);
    _handle = nil;
  }
}



NSCondition *_condition = [[NSCondition alloc] init];
int _lockCount = 0;

/**
 开始预览/采集的回调
 */
- (void)onStart:(ZegoPublishChannel)channel {
  NSThread *thread = [[NSThread alloc] initWithBlock:^{
    [_condition lock];
    EffectLog(@"onStart");

    [self startProgressing];

    if(useCustomVideoCapture) {
      [self startCapture];
    }
    [_condition unlock];
  }];
  [thread start];
}

/**
 结束预览/采集的回调
 */
- (void)onStop:(ZegoPublishChannel)channel {
  NSThread *thread = [[NSThread alloc] initWithBlock:^{
    EffectLog([NSString stringWithFormat:@"onStop lockCount: %i", _lockCount]);

    [_condition lock];
    while (_lockCount > 0) {
      EffectLog(@"onStop wait");
      [_condition wait];
    }

    EffectLog(@"onStop continue");

    [self stopProgressing];

    if(useCustomVideoCapture) {
      [self stopCapture];
    }

    [_condition unlock];

    _lockCount = 0;
  }];
  [thread start];
}



BEPixelBufferGLTexture *_inputTexture = nil;
BEPixelBufferGLTexture *_outputTexture = nil;
CVOpenGLESTextureCacheRef _textureCache = nil;

- (void)startProgressing {
  EffectLog(@"startProgressing");

  if(_glContext) {
    if(!_textureCache) {
      if ([EAGLContext currentContext] != _glContext) {
        EffectLog(@"effectsar init and destroy are not run in the same glContext");
        [EAGLContext setCurrentContext:_glContext];
      }

      CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _glContext, NULL, &_textureCache);
      if (ret != kCVReturnSuccess) {
        EffectLog([NSString stringWithFormat:@"create CVOpenGLESTextureCacheRef fail: %d", ret]);
      }
    }

    _inputTexture = [[BEPixelBufferGLTexture alloc] initWithTextureCache:_textureCache];
    // inputTexture = [[BEPixelBufferGLTexture alloc] init];
    _outputTexture =[[BEPixelBufferGLTexture alloc] initWithWidth:360 height:640 textureCache:_textureCache];
    // outputTexture =[[BEPixelBufferGLTexture alloc] initWithWidth:360 height:640];

    //  processing = true;
    // 创建并初始化特效句柄
    _processing = ([self initHandle] == BEF_RESULT_SUC);
    _process_paused = false;
    // 应用最近的美颜设置
    [self applyEffect];
  }
}


- (void)stopProgressing {
  EffectLog(@"stopProgressing");

  _processing = false;
  _process_paused = false;

  // 销毁句柄
  [self destroyHandle];

  if (_textureCache) {
    EffectLog([NSString stringWithFormat:@"release CVTextureCache %@", _textureCache]);
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
    CFRelease(_textureCache);
    _textureCache = nil;
  }

  [_inputTexture destroy];
  _inputTexture = nil;
  [_outputTexture destroy];
  _outputTexture = nil;
}

- (BEPixelBufferGLTexture *)processTexture:(CVPixelBufferRef)buffer timestamp:(CMTime)timestamp {
  [_inputTexture update:buffer];
  // 获取对应的纹理的宽高
  int width = _inputTexture.width;
  int height = _inputTexture.height;
  //
  [_outputTexture updateWidth:width height:height];

  // 获取对应的 OpenGL 纹理
  int srcTexture = _inputTexture.texture;
  int dstTexture = _outputTexture.texture;


  bef_effect_result_t ret = bef_effect_ai_set_width_height(_handle, width, height);
  ret = bef_effect_ai_set_orientation(_handle, BEF_AI_CLOCKWISE_ROTATE_0);

  double timeStamp = (double)timestamp.value/timestamp.timescale;
  // double timeStamp = [[NSDate date] timeIntervalSince1970];
  ret = bef_effect_ai_algorithm_texture(_handle, srcTexture, timeStamp);

  if ([EAGLContext currentContext] != _glContext) {
    EffectLog([NSString stringWithFormat:@"effectsar process are not run in the same glContext: %@, %@", _glContext, [EAGLContext currentContext]]);
    [EAGLContext setCurrentContext:_glContext];
  }
  ret = bef_effect_ai_process_texture(_handle, srcTexture, dstTexture, timeStamp);

  return _outputTexture;
}

/**
 回调接口获取原始视频数据
 */
- (void)onCapturedUnprocessedCVPixelBuffer:(CVPixelBufferRef)buffer
                                 timestamp:(CMTime)timestamp
                                   channel:(ZegoPublishChannel)channel {
  //  EffectLog(@"onCapturedUnprocessedCVPixelBuffer: %@", [NSNumber numberWithDouble:CMTimeGetSeconds(timestamp)]);
  if(_processing && !_process_paused) {
    try {
      // 执行纹理的特效处理
      BEPixelBufferGLTexture *_out = [self processTexture:buffer timestamp:timestamp];

      // 将处理后的 buffer 发回 Express SDK 里
      [[ZegoExpressEngine sharedEngine] sendCustomVideoProcessedCVPixelBuffer:_out.pixelBuffer timestamp:timestamp channel:channel];
    } catch(NSError *error ) {
      EffectLog([NSString stringWithFormat:@"onCapturedUnprocessedCVPixelBuffer fail: %@", error]);
      [[ZegoExpressEngine sharedEngine] sendCustomVideoProcessedCVPixelBuffer:buffer timestamp:timestamp channel:channel];
    }
  } else {
    [[ZegoExpressEngine sharedEngine] sendCustomVideoProcessedCVPixelBuffer:buffer timestamp:timestamp channel:channel];
  }
}





ZegoPublishChannel _channel = ZegoPublishChannelMain;
ZGCaptureDeviceCamera *_captureDevice = nil;


/**
 开始视频采集
 */
- (void)startCapture  {
  EffectLog(@"startCapture");

  _captureDevice = [[ZGCaptureDeviceCamera alloc] initWithPixelFormatType:kCVPixelFormatType_32BGRA];
  _captureDevice.delegate = self;

  [_captureDevice startCapture];
  //  [[ZegoExpressEngine sharedEngine] start];
}

/**
 停止视频采集
 */
- (void)stopCapture {
  EffectLog(@"stopCapture");

  [_captureDevice stopCapture];

  _captureDevice = nil;
}

#pragma mark - ZGCustomVideoCapturePixelBufferDelegate
- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data {
  [_condition lock];
  _lockCount += 1;
  [_condition unlock];

//  EffectLog([NSString stringWithFormat:@"captureDevice didCapturedData %d", _processing]);

  CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(data);
  CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(data);
  if(_processing && !_process_paused) {
    //    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(data);
    //    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(data);

    // 执行纹理的特效处理 BufferType: CVPixelBuffer
    [self processTexture:buffer timestamp:timestamp];

    // Send pixel buffer to ZEGO SDK
    //    [[ZegoExpressEngine sharedEngine] sendCustomVideoCaptureTextureData:_outputTexture.texture size:size timestamp:timestamp];
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:_outputTexture.pixelBuffer timestamp:timestamp channel:_channel];
  } else {
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:buffer timestamp:timestamp channel:_channel];
  }

  [_condition lock];
  _lockCount -= 1;
  [_condition signal];
  [_condition unlock];
}

/**
 自定义视频采集
 */
RCT_EXPORT_METHOD(enableCustomVideoCapture:(BOOL)enable channel:(double)channel resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  EffectLog([NSString stringWithFormat:@"enableCustomVideoCapture: %d", enable]);
  if (!_inited) {
    return resolve(@(BEF_RESULT_FAIL));
  }
  ZegoCustomVideoCaptureConfig *captureConfig = [[ZegoCustomVideoCaptureConfig alloc] init];
  // 选择 CVPixelBuffer 类型视频帧数据
  captureConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;
  _channel = (ZegoPublishChannel)channel;
  [[ZegoExpressEngine sharedEngine] enableCustomVideoCapture:enable config:captureConfig channel:(ZegoPublishChannel)channel];
  // 将自身作为自定义视频前处理回调对象
  if(enable) {
    [[ZegoExpressEngine sharedEngine] setCustomVideoCaptureHandler:self];
  } else {
    [[ZegoExpressEngine sharedEngine] setCustomVideoCaptureHandler:nil];
  }
  resolve(BEF_RESULT_SUC);
}

/**
 自定义视频前处理
 */
RCT_EXPORT_METHOD(enableCustomVideoProcessing:(BOOL)enable channel:(double)channel
                  resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  EffectLog([NSString stringWithFormat:@"enableCustomVideoProcessing: %d", enable]);
  if (!_inited) {
    return resolve(@(BEF_RESULT_FAIL));
  }

  ZegoCustomVideoProcessConfig *processConfig = [[ZegoCustomVideoProcessConfig alloc] init];
  // 选择 CVPixelBuffer 类型视频帧数据
  processConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;

  // 开启自定义视频前处理
  [[ZegoExpressEngine sharedEngine] enableCustomVideoProcessing:enable config:processConfig channel:(ZegoPublishChannel)channel];

  // 将自身作为自定义视频前处理回调对象
  if(enable) {
    [[ZegoExpressEngine sharedEngine] setCustomVideoProcessHandler:self];
  } else {
    [[ZegoExpressEngine sharedEngine] setCustomVideoProcessHandler:nil];
  }

  resolve(BEF_RESULT_SUC);
}

RCT_EXPORT_METHOD(pauseProcessing:(BOOL)enable resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
  _process_paused = enable;
  resolve(BEF_RESULT_SUC);
}

/**
 设置特效组合
 */
RCT_EXPORT_METHOD(setComposeNodes:(NSArray<NSString *> *)nodes
                  resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject){
  EffectLog([NSString stringWithFormat:@"setComposeNodes: %@", nodes]);

  if (!_inited) {
    return resolve(@(BEF_RESULT_FAIL));
  }

  NSMutableArray<NSString *> *paths = [NSMutableArray array];
  for (int i = 0; i < nodes.count; i++) {
    NSString *node = nodes[i];
    [paths addObject:[mResourceHelper composerNodePath:node]];
  }
  [mDataHelper saveComposeNodes:paths];

  char **nodePaths = [mDataHelper getComposeNodePaths];
  int nodeCount = [mDataHelper getComposeNodeCount];
  bef_effect_result_t ret = BEF_RESULT_SUC;
  ret = bef_effect_ai_composer_set_nodes(_handle, (const char **)nodePaths, nodeCount);

  for (int i = 0; i < nodeCount; i++) {
    free(nodePaths[i]);
  }
  free(nodePaths);

  resolve(@(ret));
}


/**
 设置特效强度
 */
RCT_EXPORT_METHOD(updateComposerNodeIntensity:(NSString *)node key:(NSString *)key intensity:(double)intensity
                  resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  EffectLog([NSString stringWithFormat:@"updateComposerNodeIntensity: %@, %@, %@", node, key, [NSNumber numberWithDouble:intensity]]);

  if (!_inited || [node isEqual:@""]) {
    return resolve(@(BEF_RESULT_FAIL));
  }
  // 保存美颜特效
  NSString *path = [mResourceHelper composerNodePath:node];
  [mDataHelper saveComposeNodeItem:path key:key intensity:intensity];

  // 设置美颜特效强度
  bef_effect_result_t ret = BEF_RESULT_SUC;
  ret = bef_effect_ai_composer_update_node(_handle, (const char *)[path UTF8String], (const char *)[key UTF8String], (float)intensity);

  resolve(@(ret));
}


/**
 设置滤镜
 */
RCT_EXPORT_METHOD(setFilter:(NSString *)filter
                  resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  EffectLog([NSString stringWithFormat:@"setFilter: %@",filter]);
  if (!_inited) {
    return resolve(@(BEF_RESULT_FAIL));
  }
  // 保存滤镜
  NSString *path = [mResourceHelper filterPath:filter];
  [mDataHelper saveFilter:path];

  // 设置滤镜
  bef_effect_result_t ret = BEF_RESULT_SUC;
  ret = bef_effect_ai_set_color_filter_v2(_handle, (const char *)[path UTF8String]);

  resolve(@(ret));
}


/**
 设置滤镜强度
 */
RCT_EXPORT_METHOD(updateFilterIntensity:(double)intensity
                  resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  EffectLog([NSString stringWithFormat:@"updateFilterIntensity: %@", [NSNumber numberWithDouble:intensity]]);

  if (!_inited) {
    return resolve(@(BEF_RESULT_FAIL));
  }
  // 保存滤镜强度
  [mDataHelper saveFilterIntensity:intensity];

  // 设置滤镜
  bef_effect_result_t ret = BEF_RESULT_SUC;
  ret = bef_effect_ai_set_intensity(_handle, BEF_INTENSITY_TYPE_GLOBAL_FILTER_V2, (float)intensity);

  resolve(@(ret));
}

/**
 设置贴纸
 */
RCT_EXPORT_METHOD(setSticker:(NSString *)sticker
                  resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
  EffectLog([NSString stringWithFormat:@"setSticker: %@",sticker]);
  if (!_inited) {
    return resolve(@(BEF_RESULT_FAIL));
  }
  // 保存贴纸
  NSString *path = [mResourceHelper stickerPath:sticker];
  [mDataHelper saveSticker:path];

  // 设置贴纸
  bef_effect_result_t ret = BEF_RESULT_SUC;
  ret = bef_effect_ai_set_effect(_handle, (const char *)[path UTF8String]);

  resolve(@(ret));
}


/**
 应用最近的美颜设置
 */
- (void) applyEffect {
  EffectLog(@"applyEffect");
  char **nodePaths = [mDataHelper getComposeNodePaths];
  int nodeCount = [mDataHelper getComposeNodeCount];
  NSArray<ComposeNodeItem *> *items = [mDataHelper getComposeNodeItems];
  NSString *filter = [mDataHelper getFilter];
  double filterIntensity = [mDataHelper getFilterIntensity];
  NSString *sticker = [mDataHelper getSticker];

  bef_effect_result_t ret = BEF_RESULT_SUC;
  ret = bef_effect_ai_composer_set_nodes(_handle, (const char **)nodePaths, nodeCount);
  for (int i = 0; i < items.count; i++) {
    ComposeNodeItem *item = [items objectAtIndex:i];
    ret = bef_effect_ai_composer_update_node(_handle, (const char *)[item.node UTF8String], (const char *)[item.key UTF8String], (float)item.intensity);
  }
  ret = bef_effect_ai_set_color_filter_v2(_handle, (const char *)[filter UTF8String]);
  ret = bef_effect_ai_set_intensity(_handle, BEF_INTENSITY_TYPE_GLOBAL_FILTER_V2, (float)filterIntensity);
  ret = bef_effect_ai_set_effect(_handle, (const char *)[sticker UTF8String]);
  for (int i = 0; i < nodeCount; i++) {
    free(nodePaths[i]);
  }
  free(nodePaths);
}



// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
(const facebook::react::ObjCTurboModule::InitParams &)params
{
  return std::make_shared<facebook::react::NativeVolcEngineSpecJSI>(params);
}
#endif

@end


