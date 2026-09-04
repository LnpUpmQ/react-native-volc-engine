# react-native-volc-engine

volc

## Installation

```sh
npm install react-native-volc-engine
```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)

## Android: 火山美颜 SDK（effectsdk）

美颜 SDK 二进制不再走 JitPack 第三方仓，改为随本仓库分发的官方 aar（文件版 Maven 仓库）：

- 位置：`android/mavenrepo/com/bytedance/effectsdk/4.7.2/`，Gradle 通过 `maven { url "$projectDir/mavenrepo" }` 解析，依赖坐标 `com.bytedance:effectsdk:4.7.2`；
- 来源：火山引擎智能美化特效控制台离线 SDK 包（4.7.2，官方原版二进制）；
- 指纹：`effectsdk-4.7.2.aar` SHA-256 `f77bb0ff58eec04ef096461572435b43819ab9753686741e19d97a4d47a72451`。

升级 SDK 版本时：从控制台下载新版本离线包，将 aar 放入 `android/mavenrepo/com/bytedance/effectsdk/<版本>/`（附同名 `.pom`，内容参照现有最小模板），同步修改 `android/gradle.properties` 的 `VolcEngine_effectSdkVersion`；宿主工程也可用 `rootProject.ext.effectSdkVersion` 覆盖版本。注意火山美颜 License 与 SDK 版本绑定，升级后需在控制台重新生成授权文件。
