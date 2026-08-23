// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '健身';

  @override
  String get navHome => '首页';

  @override
  String get navExercises => '动作库';

  @override
  String get navTrainingPlans => '训练计划';

  @override
  String get navCalendar => '日历';

  @override
  String get calendarSubtitle => '安排训练并追踪进度。';

  @override
  String get navDiet => '饮食';

  @override
  String get dietSubtitle => '记录饮食并追踪营养摄入。';

  @override
  String get navBodyData => '身体数据';

  @override
  String get navProgress => '进度';

  @override
  String get navSettings => '设置';

  @override
  String get navFavorites => '收藏';

  @override
  String get navRecent => '最近浏览';

  @override
  String get navWorkoutHistory => '训练历史';

  @override
  String get workoutHistorySubtitle => '查看过去的训练记录。';

  @override
  String get welcome => '欢迎';

  @override
  String get comingSoon => '即将推出';

  @override
  String get comingSoonSubtitle =>
      '完整仪表盘将在 Phase 17 上线。每个模块（动作、训练、饮食、身体数据、AI）都在各自的阶段中独立开发。';

  @override
  String get exerciseLibrary => '动作库';

  @override
  String get exerciseLibrarySubtitle => '浏览 1300+ 带动画演示的动作。';

  @override
  String get searchExercises => '搜索动作';

  @override
  String get filter => '筛选';

  @override
  String get bodyPart => '部位';

  @override
  String get equipment => '器械';

  @override
  String get clearAllFilters => '清除所有筛选';

  @override
  String get noResults => '未找到动作';

  @override
  String get noResultsSubtitle => '尝试调整搜索或筛选条件。';

  @override
  String get retry => '重试';

  @override
  String get somethingWentWrong => '出错了';

  @override
  String get howToPerform => '动作要领';

  @override
  String get details => '详细信息';

  @override
  String get target => '目标肌群';

  @override
  String get secondaryMuscles => '辅助肌群';

  @override
  String get addToFavorites => '添加到收藏';

  @override
  String get removeFromFavorites => '取消收藏';

  @override
  String get gifUnavailable => '动画不可用';

  @override
  String get noInstructionsAvailable => '暂无动作说明。';

  @override
  String get trainingPlans => '训练计划';

  @override
  String get trainingPlansSubtitle => '创建和管理你的训练计划。';

  @override
  String get newPlan => '新建计划';

  @override
  String get planName => '计划名称';

  @override
  String get planDescription => '描述（可选）';

  @override
  String get planGoal => '目标';

  @override
  String get daysPerWeek => '每周训练天数';

  @override
  String get create => '创建';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get duplicate => '复制';

  @override
  String get edit => '编辑';

  @override
  String get save => '保存';

  @override
  String get addDay => '添加训练日';

  @override
  String get dayName => '训练日名称';

  @override
  String get addExercise => '添加动作';

  @override
  String get sets => '组数';

  @override
  String get reps => '次数';

  @override
  String get weight => '重量';

  @override
  String get restSeconds => '休息（秒）';

  @override
  String get notes => '备注';

  @override
  String deletePlanConfirm(String name) {
    return '删除「$name」？';
  }

  @override
  String get deletePlanWarning => '此操作将永久删除该计划及其所有训练日和动作。';

  @override
  String get planDuplicated => '计划已复制';

  @override
  String get today => '今天';

  @override
  String get weekView => '周视图';

  @override
  String get monthView => '月视图';

  @override
  String get scheduleWorkout => '安排训练';

  @override
  String get markRestDay => '标记休息日';

  @override
  String get restDay => '休息日';

  @override
  String get markComplete => '标记完成';

  @override
  String get markIncomplete => '取消完成';

  @override
  String get remove => '移除';

  @override
  String get clear => '清除';

  @override
  String get noWorkoutScheduled => '当日无训练安排';

  @override
  String get selectPlanAndDay => '选择计划和训练日来安排';

  @override
  String get startWorkout => '开始训练';

  @override
  String get finishWorkout => '结束训练';

  @override
  String get finishWorkoutConfirm => '结束训练？';

  @override
  String get finishWorkoutWarning => '这将完成当前训练会话并标记为已完成。';

  @override
  String get workoutCompleted => '训练完成！';

  @override
  String get abandonWorkout => '放弃训练';

  @override
  String get abandonWorkoutConfirm => '放弃训练？';

  @override
  String get abandonWorkoutWarning => '这将丢弃当前会话，不会保存。';

  @override
  String get totalVolume => '训练量';

  @override
  String get completedSets => '组数';

  @override
  String get elapsedTime => '时长';

  @override
  String get restTimer => '休息计时器';

  @override
  String get skip => '跳过';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get add15s => '+15秒';

  @override
  String get browseExercisesHint => '浏览动作库，点击「添加到计划」来添加动作。';

  @override
  String get dietTracker => '饮食追踪';

  @override
  String get dietTrackerSubtitle => '记录餐食并追踪营养摄入。';

  @override
  String get breakfast => '早餐';

  @override
  String get lunch => '午餐';

  @override
  String get dinner => '晚餐';

  @override
  String get snack => '加餐';

  @override
  String get addToBreakfast => '添加到早餐';

  @override
  String get addToLunch => '添加到午餐';

  @override
  String get addToDinner => '添加到晚餐';

  @override
  String get addToSnack => '添加到加餐';

  @override
  String get foodName => '食物名称';

  @override
  String get quantity => '份量';

  @override
  String get unit => '单位';

  @override
  String get calories => '热量';

  @override
  String get protein => '蛋白质';

  @override
  String get carbs => '碳水';

  @override
  String get fat => '脂肪';

  @override
  String get addRecord => '添加记录';

  @override
  String get saveChanges => '保存更改';

  @override
  String get dietPlans => '饮食计划';

  @override
  String get newDietPlan => '新建计划';

  @override
  String get targetCalories => '目标热量';

  @override
  String get targetProtein => '目标蛋白质';

  @override
  String get targetCarbs => '目标碳水';

  @override
  String get targetFat => '目标脂肪';

  @override
  String get activate => '激活';

  @override
  String get noDietPlans => '暂无饮食计划';

  @override
  String get noDietPlansSubtitle => '创建一个计划来设定每日营养目标。';

  @override
  String get bodyData => '身体数据';

  @override
  String get addMeasurement => '添加测量';

  @override
  String get noMeasurements => '暂无测量数据';

  @override
  String get noMeasurementsSubtitle => '添加第一次测量来开始追踪进度。';

  @override
  String get bmi => 'BMI';

  @override
  String get waist => '腰围（cm）';

  @override
  String get chest => '胸围（cm）';

  @override
  String get hip => '臀围（cm）';

  @override
  String get arm => '臂围（cm）';

  @override
  String get thigh => '腿围（cm）';

  @override
  String get progress => '进度';

  @override
  String get noProgressData => '暂无进度数据';

  @override
  String get noProgressDataSubtitle => '添加身体测量数据来查看趋势。';

  @override
  String get current => '当前';

  @override
  String get change => '变化';

  @override
  String get start => '起始';

  @override
  String get weightTrend => '体重趋势';

  @override
  String get notEnoughData => '数据不足，无法显示趋势';

  @override
  String get settings => '设置';

  @override
  String get appearance => '外观';

  @override
  String get theme => '主题';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get system => '跟随系统';

  @override
  String get language => '语言';

  @override
  String get english => 'English';

  @override
  String get chinese => '简体中文';

  @override
  String get clearCache => '清除缓存';

  @override
  String get databaseInfo => '数据库信息';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get openSource => '开源项目';

  @override
  String get exerciseDataGifs => '动作数据与动画';

  @override
  String get privacy => '隐私';

  @override
  String get glassShowcase => '玻璃组件展示';

  @override
  String get glassShowcaseSubtitle => '浏览 Liquid Glass 组件库。';

  @override
  String get healthData => '健康数据';

  @override
  String get healthToday => '今日';

  @override
  String get healthSteps => '步数';

  @override
  String get healthActiveEnergy => '活动热量';

  @override
  String get healthHeartRate => '心率';

  @override
  String get healthDistance => '距离';

  @override
  String get healthFlightsClimbed => '爬楼层数';

  @override
  String get healthConnectTitle => '连接 Apple 健康';

  @override
  String get healthConnectSubtitle => '授权访问您的健康数据，查看步数、心率、卡路里等。';

  @override
  String get healthConnect => '连接';

  @override
  String get healthSources => '数据来源';

  @override
  String get healthSourcesSubtitle => '在 iOS 上从 Apple 健康读取数据。在其他平台上显示模拟数据用于演示。';

  @override
  String get watchTitle => 'Apple Watch';

  @override
  String get watchConnected => '手表已连接';

  @override
  String get watchReachable => '手表可达';

  @override
  String get watchNotConnected => '手表未连接';

  @override
  String get watchNotAvailable => '当前平台不支持 Apple Watch。';

  @override
  String get watchNotPaired => '未配对 Apple Watch。请在 Watch 应用中配对您的手表。';

  @override
  String get watchWorkoutSnapshot => '训练快照';

  @override
  String get watchHeartRate => '心率';

  @override
  String get watchCalories => '卡路里';

  @override
  String get watchProgress => '进度';

  @override
  String get watchSets => '组';

  @override
  String get watchElapsed => '已用时';

  @override
  String get watchStartWorkout => '开始训练';

  @override
  String get watchStopWorkout => '停止训练';

  @override
  String get watchPing => 'Ping 手表';

  @override
  String get watchDemoNote => '在非 iOS 平台上，显示模拟数据用于演示。';

  @override
  String get aiTrainingPlan => 'AI 训练计划';

  @override
  String get aiDietPlan => 'AI 饮食计划';

  @override
  String get aiGender => '性别';

  @override
  String get aiAge => '年龄';

  @override
  String get aiHeight => '身高（cm）';

  @override
  String get aiWeight => '体重（kg）';

  @override
  String get aiExperience => '训练经验';

  @override
  String get aiGoal => '目标';

  @override
  String get aiDaysPerWeek => '每周训练天数';

  @override
  String get aiSessionDuration => '训练时长（分钟）';

  @override
  String get aiEquipment => '器械条件';

  @override
  String get aiActivityLevel => '活动量';

  @override
  String get aiGenerate => '生成';

  @override
  String get aiGenerating => 'AI 正在生成您的计划...';

  @override
  String get aiPlanPreview => '计划预览';

  @override
  String get aiMealSuggestions => '餐次建议';

  @override
  String get aiRegenerate => '重新生成';

  @override
  String get aiReset => '重置';

  @override
  String get aiTargetCalories => '目标热量';

  @override
  String get aiTargetProtein => '目标蛋白质';

  @override
  String get aiTargetCarbs => '目标碳水';

  @override
  String get aiTargetFat => '目标脂肪';

  @override
  String get subscriptionTitle => '订阅';

  @override
  String get subscriptionAvailable => '可选方案';

  @override
  String get subscriptionPurchase => '购买';

  @override
  String get subscriptionRestore => '恢复购买';

  @override
  String get subscriptionCurrent => '当前方案';

  @override
  String get subscriptionFeatures => '功能';

  @override
  String get subscriptionFeatureExerciseLibrary => '动作库';

  @override
  String get subscriptionFeatureTrainingPlans => '训练计划';

  @override
  String get subscriptionFeatureAiTraining => 'AI 训练计划';

  @override
  String get subscriptionFeatureAiDiet => 'AI 饮食计划';

  @override
  String get subscriptionFeatureAnalytics => '高级分析';

  @override
  String get subscriptionFeatureWatch => 'Apple Watch 功能';

  @override
  String get subscriptionFeatureCloudSync => '云同步';

  @override
  String get subscriptionFeaturePriorityAi => '优先 AI';

  @override
  String get dashboardTodayWorkout => '今日训练';

  @override
  String get dashboardNoWorkout => '今日无训练安排。点击查看日历。';

  @override
  String get dashboardNoWorkoutToday => '今日无训练';

  @override
  String get dashboardScheduleWorkout => '安排训练';

  @override
  String get dashboardRestDay => '休息日';

  @override
  String get dashboardEnjoyRest => '好好休息恢复';

  @override
  String get dashboardStartWorkout => '开始';

  @override
  String get dashboardQuickStats => '快速统计';

  @override
  String get dashboardWorkouts => '训练次数';

  @override
  String get dashboardVolume => '训练量';

  @override
  String get dashboardWeight => '体重';

  @override
  String get dashboardSeeAll => '查看全部';

  @override
  String get dashboardNoData => '暂无数据';

  @override
  String get dashboardAIPlans => 'AI 计划';

  @override
  String get dashboardAISubtitle => '用 AI 生成个性化计划';

  @override
  String get dashboardSubscription => '升级';

  @override
  String get dashboardSubscriptionSubtitle => '解锁 AI、分析等功能';

  @override
  String get gymVisualCopyright => '© Gym visual — gymvisual.com';
}
