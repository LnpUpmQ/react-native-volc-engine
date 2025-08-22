#import "DataHelper.h"




@implementation ComposeNodeItem
-(instancetype)initWidthNode:(NSString *)node key:(NSString *)key intensity:(double)intensity {
  self = [super init];
  if (self) {
    self.node = node;
    self.key = key;
    self.intensity = intensity;
  }
  return self;
}
@end




@interface DataHelper() {
  NSMutableArray<NSString *>  *_ComposeNodes;
  NSMutableArray<ComposeNodeItem *> *_ComposeNodeItems;
  NSString *_Filter;
  double _FilterIntensity;
  NSString *_Sticker;
}
@end

@implementation DataHelper

- (instancetype) init {
  self = [super init];
  _ComposeNodes = [NSMutableArray array];
  _ComposeNodeItems = [NSMutableArray array];
  _Filter = @"";
  _FilterIntensity = 0;
  _Sticker = @"";
  return self;
}



- (ComposeNodeItem * _Nullable)findComposeNodeItem:(NSString *)node key:(NSString *)key  {
  for (int i = 0; i < _ComposeNodeItems.count; i++) {
    ComposeNodeItem *item =[_ComposeNodeItems objectAtIndex:i];
    if([item.node isEqual:node] && [item.key isEqual:key]) {
      return item;
    }
  }
  return nil;
}

- (NSArray<NSString *> *) getComposeNodes {
  return (NSArray<NSString *> *) _ComposeNodes;
}

- (int) getComposeNodeCount {
  return (int)_ComposeNodes.count;
}

- (char **) getComposeNodePaths {
  char **nodesPath = (char **)malloc(_ComposeNodes.count * sizeof(char *));
  for (int i = 0; i < _ComposeNodes.count; i++) {
    NSString *node =  _ComposeNodes[i];
    if ([node canBeConvertedToEncoding:NSUTF8StringEncoding]) {
      NSUInteger strLength  = [node lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
      nodesPath[i] = (char *)malloc((strLength + 1) * sizeof(char *));
      strncpy(nodesPath[i], [node cStringUsingEncoding:NSUTF8StringEncoding], strLength);
      nodesPath[i][strLength] = '\0';
    }
  }
  return nodesPath;
}

- (NSArray<ComposeNodeItem *> *)getComposeNodeItems {
  return (NSArray<ComposeNodeItem *> *) _ComposeNodeItems;
}

- (NSString *)getFilter {
  return _Filter;
}

- (double)getFilterIntensity {
  return _FilterIntensity;
}

- (NSString *)getSticker {
  return _Sticker;
}




- (void)saveComposeNodes:(NSArray<NSString *> *)nodes {
  [_ComposeNodes removeAllObjects];
  for (int i = 0; i < nodes.count; i++) {
    NSString *node = nodes[i];
    if ([_ComposeNodes containsObject:node]) {
      continue;
    }
    [_ComposeNodes addObject:node];
  }
}

- (void)saveComposeNodeItem:(NSString *)node key:(NSString *)key intensity:(double)intensity {
  if(![_ComposeNodes containsObject:node]) {
    [_ComposeNodes addObject:node];
  }

  ComposeNodeItem *item = [self findComposeNodeItem:node key:key];
  if(item == nil) {
    item = [[ComposeNodeItem alloc] initWidthNode:node key:key intensity:intensity];
  }
  item.intensity = intensity;
  [_ComposeNodeItems addObject:item];
}



- (void)saveFilter:(NSString *)path {
  _Filter = path;
}

- (void)saveFilterIntensity:(double)intensity {
  _FilterIntensity = intensity;
}

- (void)saveSticker:(NSString *)path {
  _Sticker = path;
}

@end
