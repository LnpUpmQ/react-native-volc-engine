


@interface ComposeNodeItem: NSObject

@property (nonatomic, copy) NSString *node;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) double intensity;

-(instancetype)initWidthNode:(NSString *)node key:(NSString *)key intensity:(double)intensity;

@end


@interface DataHelper: NSObject

- (NSArray<NSString *> *)getComposeNodes;
- (int)getComposeNodeCount;
- (char **)getComposeNodePaths;
- (NSArray<ComposeNodeItem *> *)getComposeNodeItems;
- (NSString *)getFilter;
- (double)getFilterIntensity;
- (NSString *)getSticker;

- (void)saveComposeNodes:(NSArray<NSString *> *)nodes;
- (void)saveComposeNodeItem:(NSString *)node key:(NSString *)key intensity:(double)intensity;
- (void)saveFilter:(NSString *)path;
- (void)saveFilterIntensity:(double)intensity;
- (void)saveSticker:(NSString *)path;

@end
