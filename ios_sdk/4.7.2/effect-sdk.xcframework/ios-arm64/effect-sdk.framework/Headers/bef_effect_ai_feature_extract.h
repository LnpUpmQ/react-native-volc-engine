#ifndef BYTEDEFFECTS_BEF_EFFECT_AI_FEATURE_EXTRACT_H
#define BYTEDEFFECTS_BEF_EFFECT_AI_FEATURE_EXTRACT_H

#include "bef_effect_ai_public_define.h"

#ifdef BEF_FEATURE_EXTRACT_TOB

/// @brief Feature Extract 配置
/// @note 目前暂不支持配置，预留
typedef struct bef_ai_feature_extract_config_t {
}bef_ai_feature_extract_config_t ;

/// @brief 初始化Feature Extract
BEF_SDK_API bef_effect_result_t bef_effect_ai_feature_extract_init();

/// @brief 设置Feature Extract的开关
/// @param enable 是否开启
/// @return 成功则返回BEF_RESULT_SUC
bef_effect_result_t bef_effect_ai_feature_extract_enable(bool enable);

/// @brief 设置Feature Extract的配置
/// @param config 配置
/// @return 成功则返回BEF_RESULT_SUC
BEF_SDK_API bef_effect_result_t bef_effect_ai_feature_extract_set_config(const bef_ai_feature_extract_config_t* config);

/// @brief 释放Feature Extract
/// @note 确认不使用后再释放，否则有些全量Feature在释放后不能再获取
BEF_SDK_API bef_effect_result_t bef_effect_ai_feature_extract_release();

/// @brief 清除缓存的运行时Feature列表
BEF_SDK_API bef_effect_result_t bef_effect_ai_feature_extract_clear_runtime_features_cache();

/// @brief 获取SDK支持的所有Feature列表
/// @param features_str 获取到的Feature列表
/// @param features_str_len 获取到的Feature列表长度
/// @return 成功则返回BEF_RESULT_SUC
/// @note 调用方需要自行释放features_str
BEF_SDK_API bef_effect_result_t bef_effect_ai_get_support_features(const char** features_str, int* features_str_len);

/// @brief 获取SDK运行时捕获的Feature列表，自从上次清除之后的
/// @param features_str 获取到的Feature列表
/// @param features_str_len 获取到的Feature列表长度
/// @return 成功则返回BEF_RESULT_SUC
/// @note 调用方需要自行释放features_str
BEF_SDK_API bef_effect_result_t bef_effect_ai_get_runtime_features(const char** features_str, int* features_str_len);

#endif

#endif //BYTEDEFFECTS_BEF_EFFECT_AI_FEATURE_EXTRACT_H
