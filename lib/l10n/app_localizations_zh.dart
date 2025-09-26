// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get helloWorld => '你好世界！';

  @override
  String get home => '主页';

  @override
  String get settings => '设置';

  @override
  String get yourApiKey => '您的API密钥（不要分享给别人！）';

  @override
  String get apiKeyWrong => '确保输入正确的API密钥。';

  @override
  String get yourVaUrl => '您的 VA 链接（不要在末尾添加\'/\'）';

  @override
  String get invalidUrl => '无效的链接';

  @override
  String get delete => ' 删除';

  @override
  String get submit => '提交';

  @override
  String get save => '保存';

  @override
  String get testConnection => '连接测试';

  @override
  String get test => '测试';

  @override
  String get testOK => '✓ 成功';

  @override
  String get eCheckVA => '失败，检查您的 VA 链接';

  @override
  String get e401 => '错误 401 未授权, 检查您的 API 密钥和 VA 链接';

  @override
  String get e404 => '错误 404 请求不存在, 检查您的 VA 链接';

  @override
  String get e400 => '错误 400 验证错误, 联系开发者';

  @override
  String get eInternet => '失败, 检查您的网络连接和 VA 链接设置';

  @override
  String get language => '语言';

  @override
  String get connectionType => '连接方式';

  @override
  String get connectionTypeTip => 'FSUIPC: 适用于 FSX,P3D,MSFS2020/2024\nXPUIPC: 适用于 X-Plane 11/12\n请确保 FSUIPC/XPUIPC 已安装';

  @override
  String get weightUnit => '重量单位';

  @override
  String get clear => '清除';

  @override
  String get refresh => '刷新';

  @override
  String get startFlight => '开始飞行';

  @override
  String get airline => '航空公司';

  @override
  String get flightNumber => '航班号';

  @override
  String get dep => '起飞机场';

  @override
  String get arr => '落地机场';

  @override
  String get aircraftType => '飞机型号';

  @override
  String get aircraftIcaoCode => '飞机ICAO';

  @override
  String get aircraftName => '名字';

  @override
  String get registration => '注册号';

  @override
  String get blockFuel => '轮挡油量';

  @override
  String get noFares => '无配载数据';

  @override
  String get route => '航路';

  @override
  String get prefiling => '上传航班计划中, 请坐和放宽...';

  @override
  String get prefilingError => '上传航班计划时发生错误，请检查您的设置和网络连接。';

  @override
  String get error => '错误';

  @override
  String get noBidsFoundTitle => '找不到航班 :(';

  @override
  String get noBidsFound => '找不到任何航班，检查您的设置和网络连接，或在 VA 网站预定一个航班。';

  @override
  String get back => '返回';

  @override
  String get quit => '退出';

  @override
  String get fares => '配载';

  @override
  String get code => '代码';

  @override
  String get count => '数量';
}
