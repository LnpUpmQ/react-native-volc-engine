#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "ZGCaptureDeviceProtocol.h"

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNVolcEngineSpec.h"

@interface VolcEngine : NSObject <NativeVolcEngineSpec, ZegoCustomVideoProcessHandler,ZegoCustomVideoCaptureHandler,ZGCaptureDeviceDataOutputPixelBufferDelegate>
#else
#import <React/RCTBridgeModule.h>

@interface VolcEngine : NSObject <RCTBridgeModule, ZegoCustomVideoProcessHandler,ZegoCustomVideoCaptureHandler,ZGCaptureDeviceDataOutputPixelBufferDelegate>
#endif

@end
