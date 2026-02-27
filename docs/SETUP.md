# Beep 项目环境搭建指南

> 本文档记录 Flutter 开发环境的安装与配置过程，适用于 macOS（Intel/M 芯片）。

---

## 一、环境概览

| 组件 | 版本 | 用途 |
|-----|------|-----|
| Flutter | 3.24.0+ | 跨平台 UI 框架 |
| Dart | 3.5.0+ | 编程语言（随 Flutter 安装） |
| Xcode | 15.0+ | iOS/macOS 开发（需从 App Store 安装） |
| Android Studio | Latest | Android 开发、模拟器 |
| CocoaPods | 1.16+ | iOS/macOS 依赖管理 |
| VS Code | Latest | 代码编辑器 |

---

## 二、安装步骤

### 2.1 安装 Homebrew（如未安装）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2.2 安装 Flutter SDK

**方式一：使用 Homebrew（推荐，需稳定网络）**

```bash
brew install --cask flutter
```

**方式二：从中国镜像下载（网络不稳定时使用）**

```bash
# 下载 Flutter SDK
cd ~
curl -L -o flutter_macos.zip "https://storage.flutter-io.cn/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.0-stable.zip"

# 解压
unzip -q flutter_macos.zip
rm flutter_macos.zip
```

### 2.3 配置环境变量

在 `~/.zshrc`（或 `~/.bash_profile`）中添加：

```bash
# Flutter 环境配置
export PATH="$HOME/flutter/bin:$PATH"

# 中国镜像（可选，加速 pub 包下载）
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn
```

使配置生效：

```bash
source ~/.zshrc
```

### 2.4 安装 CocoaPods

```bash
brew install cocoapods
```

### 2.5 安装 Xcode（iOS/macOS 开发必需）

1. 从 App Store 下载并安装 **Xcode**
2. 安装完成后运行：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
```

### 2.6 安装 Android Studio（Android 开发必需）

1. 下载地址：https://developer.android.com/studio
2. 安装后启动，按向导安装 Android SDK
3. 配置 Flutter：

```bash
flutter config --android-sdk /Users/$USER/Library/Android/sdk
```

4. 接受 Android 许可：

```bash
flutter doctor --android-licenses
```

---

## 三、验证安装

运行 Flutter 诊断：

```bash
flutter doctor -v
```

**理想状态：**

```
[✓] Flutter (Channel stable, 3.24.0, on macOS ...)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] VS Code
[✓] Connected device
[✓] Network resources
```

---

## 四、VS Code 扩展（推荐）

在 VS Code 中安装以下扩展：

| 扩展名 | ID | 用途 |
|-------|-----|-----|
| Flutter | Dart-Code.flutter | Flutter 开发支持 |
| Dart | Dart-Code.dart-code | Dart 语言支持 |
| Error Lens | usernamehw.errorlens | 实时错误提示 |

安装命令：

```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

---

## 五、常用命令

```bash
# 检查环境
flutter doctor

# 创建项目
flutter create --org com.example my_app

# 运行项目
flutter run

# 指定设备运行
flutter run -d macos
flutter run -d chrome
flutter run -d <device_id>

# 查看可用设备
flutter devices

# 热重载（开发时自动）
# 按 r 键

# 构建发布版
flutter build apk --release      # Android
flutter build ios --release      # iOS
flutter build macos --release    # macOS
```

---

## 六、常见问题

### Q1: `flutter doctor` 报 Android SDK 找不到

```bash
flutter config --android-sdk /Users/$USER/Library/Android/sdk
```

### Q2: CocoaPods 安装失败

```bash
sudo gem install cocoapods
```

### Q3: 网络超时/下载失败

配置中国镜像：

```bash
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn
```

### Q4: Xcode 命令行工具问题

```bash
sudo xcode-select --reset
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

---

## 七、当前环境状态

**已完成：**
- [x] Flutter SDK 3.24.0
- [x] Dart 3.5.0
- [x] CocoaPods 1.16.2
- [x] VS Code + Flutter 扩展
- [x] 项目骨架创建完成
- [x] Web 版本可运行

**待完成（可选）：**
- [ ] Xcode（iOS/macOS 开发需要）
- [ ] Android Studio（Android 开发需要）
- [ ] 添加提示音文件到 assets/sounds/

---

## 八、项目结构

```
beep/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── app.dart                  # App 配置（主题、国际化）
│   ├── core/
│   │   ├── scheduler/
│   │   │   └── chime_scheduler.dart   # 整点报时调度器
│   │   ├── notification/
│   │   │   └── notification_service.dart  # 系统通知服务
│   │   └── audio/
│   │       └── audio_service.dart     # 音频播放服务
│   ├── data/
│   │   ├── models/
│   │   │   ├── timer_model.dart       # 定时器数据模型
│   │   │   └── settings_model.dart    # 设置数据模型
│   │   └── repositories/
│   │       └── settings_repository.dart  # 本地存储
│   └── ui/
│       ├── screens/
│       │   ├── home_screen.dart       # 主页
│       │   ├── settings_screen.dart   # 设置页
│       │   └── add_timer_screen.dart  # 添加定时器页
│       ├── widgets/
│       │   ├── clock_display.dart     # 时钟显示组件
│       │   ├── chime_status_card.dart # 整点报时状态卡片
│       │   └── timer_list_card.dart   # 定时器列表卡片
│       └── state/
│           ├── settings_state.dart    # 设置状态管理
│           └── timer_state.dart       # 定时器状态管理
├── assets/
│   └── sounds/                   # 提示音文件（需添加）
├── android/                      # Android 原生配置
├── ios/                          # iOS 原生配置
├── macos/                        # macOS 原生配置
├── web/                          # Web 配置
├── docs/
│   └── SETUP.md                  # 本文档
└── pubspec.yaml                  # 依赖配置
```

---

## 九、运行命令

```bash
# Web 版本（当前可用）
flutter run -d chrome

# macOS 版本（需要 Xcode）
flutter run -d macos

# Android 版本（需要 Android Studio）
flutter run -d <device_id>

# iOS 版本（需要 Xcode + iOS Simulator）
flutter run -d <simulator_id>

# 查看可用设备
flutter devices
```

---

*文档生成时间：2026-02-07*
