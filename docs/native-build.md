# 原生构建

需要 Godot 4.6.3 和对应导出模板。仓库不包含引擎、SDK、个人图片、签名密钥或构建产物。

Android：安装 Android SDK、JDK 17，安装 Godot 对应 Android 源码模板。`tools/prepare_android.py` 将 `native/android/SlowCoinSpeechPlugin.java` 注入导出工程，提供主动语音及系统图片选择。SDK 路径可通过 ANDROID_HOME / ANDROID_SDK_ROOT 设置。运行 `tools/build_android.sh`。

iOS：下载 Godot 4.6.3 源码到 `.tools/godot-4.6.3-stable`，将 `native/ios/slow_coin_speech` 复制到源码的 `modules/slow_coin_speech`。在源码目录安装/使用 SCons，分别构建：

```
scons platform=ios target=template_debug arch=arm64 vulkan=no metal=no opengl3=yes optimize=size debug_symbols=no simulator=yes -j8
scons platform=ios target=template_debug arch=arm64 vulkan=no metal=no opengl3=yes optimize=size debug_symbols=no simulator=no -j8
```

随后 `tools/build_ios.sh` 将自定义静态库注入导出工程并链接 Speech、PhotosUI。该脚本构建无签名模拟器目标；真机需在 Xcode 配置自己的签名团队。发布版需要对应 release 引擎与签名，勿直接将 debug APK 当作商店发布包。

图片选择使用 [Android Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider) 和 [Apple PHPickerViewController](https://developer.apple.com/documentation/PhotosUI/PHPickerViewController)。只读取用户选择的一张图片，缩小后交给 Godot 做本地圆形简化预览；没有照片上传服务。
