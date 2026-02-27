# Beep 操作手册（中文版）

> 跨平台整点报时与定时器应用

---

## 目录

1. [项目简介](#1-项目简介)
2. [环境准备](#2-环境准备)
3. [项目结构](#3-项目结构)
4. [开发与运行](#4-开发与运行)
5. [功能说明](#5-功能说明)
6. [打包发布](#6-打包发布)
7. [常见问题](#7-常见问题)

---

## 1. 项目简介

**Beep** 是一款使用 Flutter 开发的跨平台应用，支持：

- ✅ macOS（Intel 和 Apple 芯片）
- ✅ Android
- ✅ iOS
- ✅ Web

### 核心功能

| 功能 | 说明 |
|-----|------|
| 整点报时 | 每小时整点自动提醒，支持静音时段设置 |
| 自定义定时 | 创建一次性或每日重复的定时提醒 |
| 系统通知 | 推送系统通知 + 提示音 |
| 主题切换 | 支持浅色/深色/跟随系统 |

---

## 2. 环境准备

### 2.1 必需环境

| 工具 | 版本要求 | 用途 |
|-----|---------|------|
| Flutter SDK | 3.24.0+ | 开发框架 |
| Dart | 3.5.0+ | 编程语言（随 Flutter 安装） |

### 2.2 平台特定环境

| 目标平台 | 需要安装 |
|---------|---------|
| Web | 无额外要求（Chrome 浏览器即可） |
| macOS | Xcode 15.0+ |
| iOS | Xcode 15.0+ + iOS Simulator |
| Android | Android Studio + Android SDK |

### 2.3 安装 Flutter

**方式一：使用 Homebrew（macOS）**

```bash
brew install --cask flutter
```

**方式二：从镜像下载**

```bash
# 下载
curl -L -o flutter.zip "https://storage.flutter-io.cn/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.0-stable.zip"

# 解压到用户目录
unzip -q flutter.zip -d ~
rm flutter.zip

# 配置环境变量（添加到 ~/.zshrc）
export PATH="$HOME/flutter/bin:$PATH"
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn

# 使配置生效
source ~/.zshrc
```

### 2.4 验证安装

```bash
flutter doctor
```

---

## 3. 项目结构

```
beep/
├── lib/                          # 源代码目录
│   ├── main.dart                 # 应用入口
│   ├── app.dart                  # 应用配置（主题、国际化）
│   ├── core/                     # 核心服务
│   │   ├── scheduler/            # 调度模块
│   │   │   └── chime_scheduler.dart   # 整点报时调度器
│   │   ├── notification/         # 通知模块
│   │   │   └── notification_service.dart
│   │   └── audio/                # 音频模块
│   │       └── audio_service.dart
│   ├── data/                     # 数据层
│   │   ├── models/               # 数据模型
│   │   │   ├── timer_model.dart
│   │   │   └── settings_model.dart
│   │   └── repositories/         # 数据仓库
│   │       └── settings_repository.dart
│   └── ui/                       # 界面层
│       ├── screens/              # 页面
│       │   ├── home_screen.dart
│       │   ├── settings_screen.dart
│       │   ├── add_timer_screen.dart
│       │   └── edit_timer_screen.dart  # 编辑定时器页面
│       ├── widgets/              # 组件
│       │   ├── clock_display.dart
│       │   ├── chime_status_card.dart
│       │   └── timer_list_card.dart
│       └── state/                # 状态管理
│           ├── settings_state.dart
│           └── timer_state.dart
├── assets/                       # 资源文件
│   └── sounds/                   # 提示音
│       ├── chime.mp3
│       └── timer.mp3
├── android/                      # Android 原生配置
├── ios/                          # iOS 原生配置
├── macos/                        # macOS 原生配置
├── web/                          # Web 配置
├── docs/                         # 文档
├── pubspec.yaml                  # 依赖配置
└── README.md                     # 项目说明
```

---

## 4. 开发与运行

### 4.1 获取依赖

```bash
cd /Users/sv/codes/beep
flutter pub get
```

### 4.2 运行应用

**Web 版本（推荐用于快速测试）**

```bash
flutter run -d chrome
```

**macOS 版本**

```bash
# 需要先安装 Xcode
flutter run -d macos
```

**Android 版本**

```bash
# 需要先安装 Android Studio 和 Android SDK
# 查看可用设备
flutter devices

# 运行到指定设备
flutter run -d <device_id>
```

**iOS 版本**

```bash
# 需要先安装 Xcode
# 启动 iOS 模拟器
open -a Simulator

# 运行
flutter run -d <simulator_id>
```

### 4.3 热重载

运行时按以下快捷键：

| 按键 | 功能 |
|-----|------|
| `r` | 热重载（保留状态） |
| `R` | 热重启（重置状态） |
| `q` | 退出 |
| `h` | 帮助 |

---

## 5. 功能说明

### 5.1 整点报时

**工作原理：**
1. 应用计算到下一个整点的时间间隔
2. 设置定时器在整点触发
3. 触发时：播放提示音 + 推送系统通知
4. 自动调度下一个整点

**设置选项：**
- 开关：启用/禁用整点报时
- 静音时段：设置不报时的时间段（如 22:00 - 07:00）

### 5.2 自定义定时器

**支持模式：**
- 一次性：到达指定时间后触发一次
- 每日重复：每天在指定时间触发

**创建定时器：**
1. 点击右下角「Add Timer」按钮
2. 输入标签（如「吃药提醒」）
3. 选择时间
4. 选择重复模式
5. 点击「Save」保存

**编辑定时器：**
1. 点击定时器卡片或点击编辑图标（铅笔）
2. 修改标签、时间或重复模式
3. 点击「Save」保存更改
4. 若有未保存的更改，返回时会提示是否放弃

**删除定时器：**

方式一：左滑删除
- 在定时器卡片上向左滑动，直接删除

方式二：编辑页面删除
- 进入编辑页面，点击顶部删除图标或底部「Delete Timer」按钮
- 确认删除后，定时器将被永久移除

方式三：长按菜单
- 长按定时器卡片，弹出菜单
- 选择「Delete」并确认

**管理定时器：**
- 开关切换：点击右侧开关启用/禁用单个定时器
- 长按菜单：显示「Edit」「Toggle」「Delete」选项

### 5.3 设置

| 设置项 | 说明 |
|-------|------|
| Enable Hourly Chime | 开启/关闭整点报时 |
| Quiet Hours | 设置静音时段 |
| Volume | 调节提示音音量 |
| Vibration | 开启/关闭振动（移动端） |
| Theme | 切换浅色/深色/跟随系统 |
| 24-Hour Format | 使用 24 小时制 |

---

## 6. 打包发布

### 6.1 Web 版本

```bash
# 构建
flutter build web --release

# 输出目录
build/web/
```

部署：将 `build/web/` 目录内容上传到任意静态服务器。

### 6.2 Android 版本

**前置条件：**
1. 安装 Android Studio
2. 安装 Android SDK
3. 配置 `flutter config --android-sdk <path>`
4. 接受许可 `flutter doctor --android-licenses`

```bash
# 构建 APK（用于测试）
flutter build apk --release

# 输出文件
build/app/outputs/flutter-apk/app-release.apk

# 构建 App Bundle（用于 Google Play）
flutter build appbundle --release
```

### 6.3 iOS 版本

**前置条件：**
1. 安装 Xcode
2. Apple 开发者账号（发布到 App Store 需要）

```bash
# 构建
flutter build ios --release

# 使用 Xcode 归档发布
open ios/Runner.xcworkspace
```

### 6.4 macOS 版本

```bash
# 构建
flutter build macos --release

# 输出目录
build/macos/Build/Products/Release/beep.app
```

---

## 7. 发布到应用商店

### 7.1 Google Play Store（Android 国际）

**前置要求**

| 项目 | 要求 |
|-----|------|
| 开发者账号 | 一次性 $25 注册费 |
| 签名密钥 | 用于签名 APK/AAB |
| 应用图标 | 512x512 PNG |
| 截图 | 至少 2 张，每种屏幕尺寸 |
| 隐私政策 | 必须提供 URL |

**生成签名密钥**

```bash
keytool -genkey -v -keystore ~/beep-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias beep
```

**配置签名（android/key.properties）**

```properties
storePassword=你的密码
keyPassword=你的密码
keyAlias=beep
storeFile=/Users/你的用户名/beep-release-key.jks
```

**构建并上传**

```bash
flutter build appbundle --release
# 输出: build/app/outputs/bundle/release/app-release.aab
```

访问 https://play.google.com/console → 创建应用 → 上传 AAB → 提交审核（1-3 天）

---

### 7.2 Apple App Store（iOS/macOS）

**前置要求**

| 项目 | 要求 |
|-----|------|
| Apple 开发者账号 | 年费 $99（个人）/ $299（企业） |
| Mac 电脑 | 必须用 Xcode |
| 证书 & 描述文件 | Distribution Certificate + Provisioning Profile |
| 应用图标 | 1024x1024 PNG |
| 截图 | iPhone 6.5"、5.5"，iPad 各尺寸 |
| 隐私政策 | 必须提供 URL |

**配置步骤**

1. 登录 https://developer.apple.com
2. Certificates → 创建 Distribution Certificate
3. Identifiers → 创建 App ID（com.beep.beep）
4. Profiles → 创建 App Store Distribution Profile

**构建并归档**

```bash
flutter build ios --release
open ios/Runner.xcworkspace
# Xcode 中: Product → Archive → Distribute App → App Store Connect
```

访问 https://appstoreconnect.apple.com → 创建 App → 提交审核（1-2 天）

---

### 7.3 中国 Android 应用商店

中国没有 Google Play，需要发布到多个商店：

**主要应用商店**

| 商店 | 市场份额 | 注册地址 | 个人开发者 |
|-----|---------|---------|----------|
| 华为应用市场 | ~40% | https://developer.huawei.com | ⚠️ 部分支持 |
| 小米应用商店 | ~15% | https://dev.mi.com | ✅ 支持 |
| OPPO 软件商店 | ~12% | https://open.oppomobile.com | ⚠️ 需企业 |
| vivo 应用商店 | ~12% | https://dev.vivo.com.cn | ⚠️ 需企业 |
| 应用宝（腾讯） | ~10% | https://open.qq.com | ❌ 需企业 |
| 酷安 | ~3% | https://www.coolapk.com | ✅ 支持 |

**前置要求**

| 项目 | 说明 |
|-----|------|
| 企业资质 | 大部分商店要求营业执照 |
| 软件著作权 | 部分商店要求（华为、应用宝） |
| 实名认证 | 所有商店都要求 |
| 隐私政策 | 必须符合《个人信息保护法》 |

**构建 APK（国内商店用 APK，非 AAB）**

```bash
flutter build apk --release --split-per-abi

# 输出:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (旧设备)
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk   (主流设备)
```

**推荐发布顺序（个人开发者）**

1. 小米应用商店（个人开发者友好）
2. 酷安（独立开发者社区）
3. 华为应用市场（市场份额大）

---

### 7.4 iOS 中国区特殊要求

| 项目 | 说明 |
|-----|------|
| ICP 备案号 | 如涉及网络服务，必须注明 |
| 《个保法》合规 | 隐私政策需符合中国法规 |
| 网络游戏版号 | 仅游戏类需要 |

> **Beep 应用**：纯本地工具，不涉及网络服务，无需 ICP 备案。

---

### 7.5 合规清单

```
□ 隐私政策页面（符合《个人信息保护法》）
□ 用户协议页面
□ 权限说明弹窗（首次使用前告知）
□ 个人信息收集清单
□ 第三方 SDK 清单
□ 账号注销功能（如有账号系统）
```

**Beep 应用合规状态**

| 检查项 | 状态 |
|-------|------|
| 需要 ICP 备案？ | ❌ 不需要（纯本地应用） |
| 需要软著？ | ⚠️ 部分商店需要 |
| 收集个人信息？ | ❌ 不收集 |
| 需要版号？ | ❌ 不需要（非游戏） |

---

## 8. 开机启动与后台保活

### 8.1 Android 后台保活

Beep 使用以下策略确保整点报时不被系统杀死：

| 策略 | 效果 | 说明 |
|-----|------|------|
| 前台服务 | ⭐⭐⭐⭐⭐ | 状态栏显示常驻通知，最有效 |
| 电池优化白名单 | ⭐⭐⭐⭐ | 减少 Doze 模式限制 |
| 精确闹钟 | ⭐⭐⭐⭐ | 系统级唤醒 |
| 开机自启动 | ⭐⭐⭐ | 重启后自动恢复服务 |

**已配置的权限：**

```xml
RECEIVE_BOOT_COMPLETED    <!-- 开机自启动 -->
FOREGROUND_SERVICE        <!-- 前台服务 -->
SCHEDULE_EXACT_ALARM      <!-- 精确闹钟 -->
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS  <!-- 电池优化白名单 -->
WAKE_LOCK                 <!-- 唤醒锁 -->
```

### 8.2 国产 ROM 特殊设置

国产手机（华为、小米、OPPO、vivo 等）有额外的自启动管理，需要用户手动授权：

| 品牌 | 设置路径 |
|-----|---------|
| 小米/红米 | 设置 → 应用设置 → 应用管理 → Beep → 自启动 |
| 华为/荣耀 | 设置 → 应用 → 应用启动管理 → Beep → 手动管理 |
| OPPO/realme | 设置 → 应用管理 → 应用列表 → Beep → 耗电保护 |
| vivo/iQOO | 设置 → 电池 → 后台高耗电 → 允许 Beep |
| 一加 | 设置 → 电池 → 电池优化 → Beep → 不优化 |

**引导用户设置的代码已内置**，应用会检测手机品牌并提示用户打开对应设置。

### 8.3 iOS 限制

iOS 不支持真正的后台常驻，但 Beep 使用以下替代方案：

| 方案 | 说明 |
|-----|------|
| 本地通知 | 提前调度整点通知，无需后台运行 |
| 后台刷新 | 系统偶尔唤醒应用刷新数据 |
| 静默推送 | 服务器触发（需要后端支持） |

> **注意：** iOS 的整点报时依赖系统通知，精确度可能有几秒误差。

### 8.4 macOS/Web

- **macOS**：应用可以保持后台运行，无特殊限制
- **Web**：仅在浏览器标签页打开时有效

---

## 9. 常见问题

### Q1: flutter 命令找不到

配置环境变量：

```bash
export PATH="$HOME/flutter/bin:$PATH"
```

### Q2: 网络下载慢/超时

使用中国镜像：

```bash
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn
```

### Q3: Android SDK 未找到

```bash
flutter config --android-sdk /Users/$USER/Library/Android/sdk
flutter doctor --android-licenses
```

### Q4: Xcode 命令行工具问题

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Q5: 依赖版本冲突

```bash
flutter pub upgrade
flutter pub get
```

### Q6: Web 版本通知不工作

Web 平台的通知功能受浏览器限制，需要：
1. 使用 HTTPS 或 localhost
2. 用户授权通知权限

### Q7: 签名密钥丢失怎么办？

**重要：** 签名密钥一旦丢失，将无法更新已发布的应用！

建议：
1. 备份 `beep-release-key.jks` 到安全位置
2. 记录密码到密码管理器
3. 使用 Google Play App Signing（托管签名）

### Q8: 应用被商店拒绝？

常见原因：
- 隐私政策缺失或不完整
- 权限申请未说明用途
- 应用崩溃或严重 bug
- 截图与实际功能不符

### Q9: 整点报时不准或漏报？

**Android：**
1. 检查是否开启了自启动权限
2. 检查电池优化设置，将 Beep 设为"不优化"
3. 锁定应用到最近任务（下滑锁定）

**iOS：**
- iOS 通知可能有几秒延迟，属于系统限制

### Q10: 状态栏常驻通知如何关闭？

前台服务通知是保活的核心，关闭后可能导致报时不准。
如确需关闭：设置 → 应用 → Beep → 通知 → 关闭"Beep Service"通道

---

## 联系与支持

如有问题，请提交 Issue 或联系开发者。

---

*文档版本：1.1.0*  
*最后更新：2026-02-09*
