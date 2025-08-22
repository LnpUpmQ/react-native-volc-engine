@interface ResourceHelper: NSObject
//   {zh} / @brief 模型文件路径     {en} /@Brief model file path
- (const char *)modelDirPath;

- (const char *)licensePath:(NSString *)licenseName;

//   {zh} / @brief 滤镜路径     {en} /@Brief filter path
//   {zh} / @param filterName 滤镜名称     {en} /@param filterName filter name
- (NSString *)filterPath:(NSString *)filterName;

//   {zh} / @brief 贴纸路径     {en} /@brief sticker path
//   {zh} / @param stickerName 贴纸名称     {en} /@param stickerName sticker name
- (NSString *)stickerPath:(NSString *)stickerName;

//   {zh} / @brief 特效素材路径     {en} /@brief effect material path
//   {zh} / @param nodeName 特效名称     {en} /@param nodeName effect name
- (NSString *)composerNodePath:(NSString *)nodeName;
@end
