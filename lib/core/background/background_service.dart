/// ============================================================================
/// BackgroundService - Android 后台保活管理
/// ============================================================================
/// 
/// **设计原理：**
/// 整合 Android 平台特有的后台保活策略：
/// 1. 前台服务 - 最有效的保活方式
/// 2. 电池优化白名单 - 减少被系统杀死的概率
/// 3. 精确闹钟 - 系统级别的定时唤醒
/// 
/// **平台限制：**
/// - iOS: 无法实现真正的后台常驻，只能依赖系统通知
/// - Web: 仅在标签页打开时有效
/// - macOS: 可以保持后台运行
/// 
/// **国产 ROM 特殊处理：**
/// 华为、小米、OPPO、vivo 等有额外的自启动管理，
/// 需要引导用户手动授权。
/// ============================================================================
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 后台服务管理类
class BackgroundService {
  // 私有构造函数
  BackgroundService._();
  
  /// 全局单例
  static final BackgroundService instance = BackgroundService._();

  /// 平台通道（与 Android 原生代码通信）
  static const MethodChannel _channel = MethodChannel('com.beep.beep/background');

  /// 是否已初始化
  bool _isInitialized = false;

  /// 初始化后台服务
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb || !Platform.isAndroid) {
      _isInitialized = true;
      return;
    }

    try {
      // 启动前台服务
      await startForegroundService();
      
      // 请求忽略电池优化
      await requestBatteryOptimizationExemption();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('[BackgroundService] Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[BackgroundService] Initialization failed: $e');
      }
    }
  }

  /// 启动前台服务
  /// 
  /// 前台服务会在状态栏显示一个常驻通知，
  /// 告知用户应用正在后台运行。
  Future<void> startForegroundService() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _channel.invokeMethod('startForegroundService');
      if (kDebugMode) {
        print('[BackgroundService] Foreground service started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[BackgroundService] Failed to start foreground service: $e');
      }
    }
  }

  /// 停止前台服务
  Future<void> stopForegroundService() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _channel.invokeMethod('stopForegroundService');
      if (kDebugMode) {
        print('[BackgroundService] Foreground service stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[BackgroundService] Failed to stop foreground service: $e');
      }
    }
  }

  /// 请求忽略电池优化
  /// 
  /// Android 6.0+ 引入了 Doze 模式和应用待机，
  /// 会限制后台应用的网络和 CPU 使用。
  /// 请求加入白名单可以减少这些限制。
  Future<bool> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('requestBatteryOptimization');
      if (kDebugMode) {
        print('[BackgroundService] Battery optimization exemption: $result');
      }
      return result ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('[BackgroundService] Failed to request battery optimization: $e');
      }
      return false;
    }
  }

  /// 检查是否已忽略电池优化
  Future<bool> isBatteryOptimizationIgnored() async {
    if (!Platform.isAndroid) return true;
    
    try {
      final result = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 打开自启动设置页面（国产 ROM）
  /// 
  /// 华为、小米、OPPO、vivo 等有额外的自启动管理，
  /// 需要引导用户手动开启。
  Future<void> openAutoStartSettings() async {
    if (!Platform.isAndroid) return;
    
    try {
      await _channel.invokeMethod('openAutoStartSettings');
    } catch (e) {
      if (kDebugMode) {
        print('[BackgroundService] Failed to open auto-start settings: $e');
      }
    }
  }

  /// 获取设备制造商
  Future<String?> getManufacturer() async {
    if (!Platform.isAndroid) return null;
    
    try {
      return await _channel.invokeMethod<String>('getManufacturer');
    } catch (e) {
      return null;
    }
  }

  /// 检查是否需要特殊的自启动设置（国产 ROM）
  Future<bool> needsAutoStartPermission() async {
    final manufacturer = await getManufacturer();
    if (manufacturer == null) return false;
    
    final lowerManufacturer = manufacturer.toLowerCase();
    
    // 这些厂商的 ROM 有额外的自启动管理
    const specialRoms = [
      'huawei',
      'honor',
      'xiaomi',
      'redmi',
      'oppo',
      'realme',
      'vivo',
      'iqoo',
      'oneplus',
      'meizu',
      'samsung',
      'lenovo',
    ];
    
    return specialRoms.any((rom) => lowerManufacturer.contains(rom));
  }
}
