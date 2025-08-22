
#ifndef ANDROIDDEMO_BEF_EFFECT_AI_CINE_MOVE_H
#define ANDROIDDEMO_BEF_EFFECT_AI_CINE_MOVE_H

#if defined(__ANDROID__) || defined(TARGET_OS_ANDROID)
#include <jni.h>
#endif

#include "bef_ai_image_quality_enhancement_public_define.h"

/**
 */
typedef enum {
    ALGORITHM_PARAMS_KEY_CINE_MOVE_VELOCITY,
    ALGORITHM_PARAMS_KEY_CINE_MOVE_STRENGTH,
} bef_ai_cine_move_param_type;

typedef enum {
    BEF_LENS_CINE_MOVE_FEATURE_FACE_RECT = 0,   // 人脸框
    BEF_LENS_CINE_MOVE_FEATURE_BODY_RECT,       // 人体框
    BEF_LENS_CINE_MOVE_FEATURE_FACE_POINT,      // 人脸特征点
    BEF_LENS_CINE_MOVE_FEATURE_BODY_POINT,      // 人体特征点
    BEF_LENS_CINE_MOVE_FEATURE_MOTION_POINT,    // 运动特征点
    BEF_LENS_CINE_MOVE_FEATURE_OBJECT_POINT,    // 物体特征点
} bef_ai_cine_move_feature_type;

/**
 * @brief 封装预测接口的返回值
 *
 * @note 不同的算法，可以在这里添加自己的自定义数据
 */

BEF_SDK_API
bef_effect_result_t bef_effect_ai_cine_move_create(bef_image_quality_enhancement_handle *handle, int lensType);

BEF_SDK_API
bef_effect_result_t bef_effect_ai_cine_move_detect(bef_image_quality_enhancement_handle handle,
                                                         bool isFirstFrame,
                                                         bool isOpen,
                                                         const bef_ai_cine_move_input* input,
                                                         bef_ai_cine_move_output* output);

BEF_SDK_API
bef_effect_result_t bef_effect_ai_cine_move_release(bef_image_quality_enhancement_handle handle);

/**
 * @brief 动态手势授权
 * @param [in] handle Created dynamic gesture handle
 *                    已创建的动态手势句柄
 * @param [in] license 授权文件字符串
 * @param [in] length  授权文件字符串长度
 * @return If succeed return BEF_RESULT_SUC, other value please refer bef_effect_ai_public_define.h
 *         成功返回 BEF_RESULT_SUC, 授权码非法返回 BEF_RESULT_INVALID_LICENSE ，其它失败返回相应错误码, 具体请参考 bef_effect_ai_public_define.h
 */

BEF_SDK_API
bef_effect_result_t bef_effect_ai_cine_move_check_license(bef_image_quality_enhancement_handle handle, const char *licensePath);

BEF_SDK_API
bef_effect_result_t bef_effect_ai_cine_move_check_online_license(bef_image_quality_enhancement_handle handle, const char *licensePath);

#endif //ANDROIDDEMO_BEF_EFFECT_AI_CINE_MOVE_H
