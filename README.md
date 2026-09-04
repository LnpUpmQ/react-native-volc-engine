# react-native-volc-engine

volc

## Installation

```sh
npm install react-native-volc-engine
```

## Android 配置

本库 Android 端通过火山引擎官方 Maven artifact 引入智能美化特效 SDK（`com.bytedance:effectsdk`，默认 `cv_tob4.7.3_202510271120_2e88395de69`，即 4.7.3 版），不再依赖任何第三方 fork 源（JitPack）。

### 覆盖特效 SDK 版本

在宿主工程根 `build.gradle` 的 `ext` 中覆盖（对齐 Zego 版本配置方式）：

```gradle
ext {
  effectSdkVersion = "cv_tob4.8.1_202605131705_f3c616cca7d" // 可选
}
```

可用版本见[官方文档《CV-Android 远程依赖SDK方式》](https://docs.volcengine.com/docs/6705/1520739)（4.7.1 起支持远程依赖）。

### Maven 仓库凭据

依赖默认从公开仓 `https://maven.byted.org/repository/android_public/` 解析；若该仓缺失对应 artifact，会尝试认证仓 `https://artifact.bytedance.com/repository/thrall_ck/`。认证凭据需向火山引擎技术支持申请，在宿主工程根目录 `gradle.properties` 中配置：

```properties
VOLC_MAVEN_USERNAME=<技术支持提供的账号>
VOLC_MAVEN_PASSWORD=<技术支持提供的密码>
```

### 注意事项

- 特效版本由 4.7.2（原 JitPack fork）升到 4.7.3（官方 artifact），类包名一致（`com.effectsar.labcv.effectsdk`），代码无需改动；宿主 assets 中的模型/授权资源（`ModelResource.bundle`、`LicenseBag.bundle` 等）建议同步更新为 4.7.3 配套版本，并真机验证 `init` 返回 0。
- 若宿主工程开启 `minifyEnabled`，请按官方接入文档为特效 SDK 补充 ProGuard keep 规则。


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
