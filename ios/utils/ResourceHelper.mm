#import "ResourceHelper.h"


static NSString *LICENSE_PATH = @"LicenseBag";
static NSString *COMPOSER_PATH = @"ComposeMakeup";
static NSString *FILTER_PATH = @"FilterResource";
static NSString *STICKER_PATH = @"StickerResource";
static NSString *MODEL_PATH = @"ModelResource";
static NSString *VIDEOSR_PATH = @"videovrsr";
static NSString *BUNDLE = @"bundle";

@interface ResourceHelper()
{
  NSString *_licensePrefix;
  NSString *_composerPrefix;
  NSString *_filterPrefix;
  NSString *_stickerPrefix;
}
@end


@implementation ResourceHelper

- (const char *)modelDirPath {
  return [[[NSBundle mainBundle] pathForResource:MODEL_PATH ofType:BUNDLE] UTF8String];
}

- (const char *)licensePath:(NSString *)licenseName  {
  if(!_licensePrefix) {
    _licensePrefix = [[[NSBundle mainBundle] pathForResource:LICENSE_PATH ofType:BUNDLE] stringByAppendingFormat:@"/"];
  }
  return [[_licensePrefix stringByAppendingString:licenseName] UTF8String];
}

- (NSString *)composerNodePath:(NSString *)nodeName {
    if(!_composerPrefix) {
        _composerPrefix =  [[[NSBundle mainBundle] pathForResource:COMPOSER_PATH ofType:BUNDLE] stringByAppendingFormat:@"/ComposeMakeup/"];
    }
    return [_composerPrefix stringByAppendingString:nodeName];
}

- (NSString *)filterPath:(NSString *)filterName {
    if (!_filterPrefix) {
        _filterPrefix = [[[NSBundle mainBundle] pathForResource:FILTER_PATH ofType:BUNDLE] stringByAppendingFormat:@"/Filter/"];
    }
    return [_filterPrefix stringByAppendingString:filterName];
}

- (NSString *)stickerPath:(NSString *)stickerName {
    if(!_stickerPrefix) {
        _stickerPrefix = [[[NSBundle mainBundle] pathForResource:STICKER_PATH ofType:BUNDLE] stringByAppendingFormat:@"/stickers/"];
    }

    return [_stickerPrefix stringByAppendingString:stickerName];
}

@end
