# Fitness App

> A production-grade, offline-first Flutter fitness app with Apple Liquid Glass UI, designed for long-term commercial evolution (Apple Watch, Apple Health, AI coaching, subscription).

[![Flutter](https://img.shields.io/badge/Flutter-3.47.1-blue)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.1-blue)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## 📱 项目介绍

Fitness App 是一个基于 Flutter 构建的商业级健身应用，采用 Apple Liquid Glass 设计语言，支持离线优先、多语言、深色/浅色主题，并预留了 Apple Watch、Apple Health、AI 教练和订阅商业化能力。

### 核心能力

- **1324+ 健身动作库** — 含 GIF 动画演示、多语言说明、分步骤教程
- **训练计划系统** — 创建/编辑/复制/排序，支持组数/次数/重量/休息时间配置
- **训练日历** — 月/周视图，安排训练、标记完成、休息日
- **训练追踪** — 实时计时、组记录、休息计时器、历史记录
- **饮食系统** — 四餐次记录、营养统计（热量/蛋白质/碳水/脂肪）、饮食计划
- **身体数据** — 体重/体脂/BMI/围度记录、趋势图、变化百分比
- **AI 计划生成** — 基于用户输入生成个性化训练/饮食计划
- **Apple Health** — 架构预留，支持步数/心率/卡路里等数据接入
- **Apple Watch** — 架构预留，支持训练控制/心率监测通信
- **订阅系统** — Free/Pro/Premium 三级权益，功能门控

## 🛠 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Flutter | 3.47.1 |
| 语言 | Dart | 3.13.1 |
| 状态管理 | Riverpod | 3.4.2 |
| 路由 | go_router | 17.5.0 |
| 数据库 | drift (SQLite) | 2.34.3 |
| 数据模型 | freezed + json_serializable | 4.0.0 / 6.14.1 |
| 图片缓存 | cached_network_image | 3.4.1 |
| 图表 | fl_chart | 1.2.0 |
| 本地化 | flutter_localizations + gen-l10n | — |
| 屏幕适配 | flutter_screenutil | 5.9.3 |
| 网络 | dio | 5.11.0 |
| 日志 | logger | 2.7.0 |

## 📁 项目结构

```
lib/
├── config/              # 生产环境配置
├── database/             # drift 数据库（12 张表）
├── l10n/                 # 多语言 ARB 文件 + 生成的 AppLocalizations
├── models/               # freezed 数据模型（15+ Model）
├── pages/                # 页面（20+ 页面）
├── providers/            # Riverpod 状态管理
├── repositories/         # 数据访问层
├── routers/              # go_router 路由配置
├── services/             # 平台服务（Health/Watch/AI/Subscription）
├── theme/                # Design Tokens + Glass 主题
├── utils/                # 工具类（Logger / URL Resolver）
├── widgets/               # 组件
│   ├── calendar/         # 日历组件
│   ├── common/            # 通用组件（Skeleton / States）
│   ├── dashboard/        # Dashboard 卡片
│   ├── diet/              # 饮食组件
│   ├── exercise/          # 动作组件
│   ├── glass/             # Liquid Glass 组件库
│   └── workout/           # 训练组件
├── assets/               # 静态资源（exercises.json）
└── main.dart             # 入口
```

## 📦 安装步骤

### 前置要求

- Flutter 3.47.1+
- Dart 3.13.1+
- iOS 15+ / Android 8.0+ (API 26)

### 安装

```bash
# 克隆项目
git clone <repository-url>
cd fitness_app

# 安装依赖
flutter pub get

# 生成代码（freezed / json_serializable / drift）
dart run build_runner build --delete-conflicting-outputs

# 生成本地化文件
flutter gen-l10n
```

### 运行

```bash
# Debug 模式
flutter run

# Release 模式
flutter run --release
```

### 测试

```bash
# 运行所有测试
flutter test

# 运行分析
flutter analyze
```

## 🗄 数据库

使用 drift (SQLite ORM)，12 张表，schema 版本 8：

| 表名 | 用途 |
|------|------|
| Exercises | 健身动作库（1324 条） |
| Favorites | 用户收藏 |
| RecentlyViewed | 最近浏览记录 |
| TrainingPlans | 训练计划 |
| TrainingDays | 训练日 |
| TrainingExercises | 训练动作配置 |
| ScheduledWorkouts | 日历安排 |
| WorkoutSessions | 训练会话记录 |
| SetRecords | 组记录 |
| DietRecords | 饮食记录 |
| DietPlans | 饮食计划 |
| BodyMetrics | 身体数据 |

### 数据导入

首次启动时自动导入 `lib/assets/exercises.json`（1324 个动作），包含：
- JSON 解析 + 字段验证 + 异常跳过
- 导入统计（total / success / failed / duplicated）
- 幂等导入（重复启动不重复导入）

## 🎨 Liquid Glass 设计系统

统一的玻璃拟态设计语言：

- `GlassContainer` — 基础容器（BackdropFilter + tint + border + shadow）
- `GlassCard` — 可点击卡片（缩放动画 + 高光叠加）
- `GlassButton` — 按钮（primary / secondary / text / destructive）
- `GlassChip` — 标签（selected 状态切换）
- `GlassSegmentedControl` — iOS 风格分段控件
- `GlassNavigationBar` — 顶部毛玻璃导航栏
- `GlassBottomSheet` — 底部弹窗
- `GlassDialog` — 居中弹窗

## 🌐 多语言

支持简体中文 + English，200+ 翻译键：

- Flutter 官方 `gen-l10n` 方案
- 类型安全的 `AppLocalizations` 调用
- 设置页语言切换（系统 / English / 简体中文）
- SharedPreferences 持久化语言偏好

## 🏗 架构

```
Presentation (Pages + Widgets)
         ↓
Provider (Riverpod Notifier)
         ↓
Repository (Data Access)
         ↓
Service / Database (drift / Dio / MethodChannel)
```

### 平台服务架构

所有平台服务采用 `abstract interface class` + `MockXxxService` 模式：

- **HealthService** — Apple Health 数据读取（Mock fallback）
- **WatchService** — Apple Watch 通信（Mock fallback）
- **AIService** — AI 计划生成（Mock fallback）
- **SubscriptionService** — IAP 订阅管理（Mock fallback）

未来接入真实 API 时，只需实现具体 Service 类并在 Provider 中切换，无需修改业务代码。

## 📊 数据来源

- **动作数据** — [exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset)（1324 个动作）
- **GIF 动画** — Gym Visual（gymvisual.com）

## 📝 版权

```
© Gym visual — gymvisual.com
```

动作数据和 GIF 动画来源于开源项目 [exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset)，该项目的数据汇总自 Gym Visual。所有 GIF 版权信息在应用 UI 中保持可见。

## 🔮 未来路线

- [ ] iOS 原生 HealthKit 桥接（Swift）
- [ ] iOS 原生 WatchConnectivity 桥接（Swift）
- [ ] 真实 AI API 接入（OpenAI / Claude）
- [ ] StoreKit / BillingClient IAP 接入
- [ ] 云同步
- [ ] 繁体中文 / 日语 / 韩语支持
- [ ] iPad 自适应布局
- [ ] 拖拽排序
- [ ] 食物数据库 API 接入
- [ ] 条形码扫描

## 📄 开发命令

```bash
# 安装依赖
flutter pub get

# 代码生成
dart run build_runner build --delete-conflicting-outputs

# 本地化生成
flutter gen-l10n

# 静态分析
flutter analyze

# 测试
flutter test

# 运行
flutter run

# 构建
flutter build ios     # iOS
flutter build apk     # Android
```
