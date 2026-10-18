import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_available_images.dart';
import 'package:dashboard/features/chat/flutterwechat_demo/flutterwechat_widget_card.dart';
import 'package:flutter/material.dart';

/// Port of the source `basicsData` list (source `lib/widgets/WeigetData.dart`).
///
/// 11 cards, verbatim: same titles, descriptions and images. The source gives
/// every card no route, so every card's tap is inert.
final List<Widget> flutterWechatBasicsEntries = [
  FlutterWechatWidgetCard(
    title: 'Container',
    describe: '一个拥有绘制、定位、调整大小的 widget。',
    imagePath: FlutterWechatAvailableImages.catalogContainer,
  ),
  FlutterWechatWidgetCard(
    title: 'Row',
    describe: '在水平方向上排列子widget的列表。',
    imagePath: FlutterWechatAvailableImages.catalogRow,
  ),
  FlutterWechatWidgetCard(
    title: 'Column',
    describe: '在垂直方向上排列子widget的列表。',
    imagePath: FlutterWechatAvailableImages.catalogColumn,
  ),
  FlutterWechatWidgetCard(
    title: 'Image',
    describe: '一个显示图片的widget',
    imagePath: FlutterWechatAvailableImages.catalogImage,
  ),
  FlutterWechatWidgetCard(
    title: 'Text',
    describe: '单一格式的文本',
    imagePath: FlutterWechatAvailableImages.catalogText,
  ),
  FlutterWechatWidgetCard(
    title: 'Icon',
    describe: 'A Material Design icon.',
    imagePath: FlutterWechatAvailableImages.catalogMdIcon,
  ),
  FlutterWechatWidgetCard(
    title: 'RaisedButton',
    describe: 'Material Design中的button， 一个凸起的材质矩形按钮',
    imagePath: FlutterWechatAvailableImages.catalogButton,
  ),
  FlutterWechatWidgetCard(
    title: 'Scaffold',
    describe: 'Material Design布局结构的基本实现。此类提供了用于显示drawer、snackbar和底部sheet的API。',
    imagePath: FlutterWechatAvailableImages.catalogScaffold,
  ),
  FlutterWechatWidgetCard(
    title: 'Appbar',
    describe:
        '一个Material Design应用程序栏，由工具栏和其他可能的widget（如TabBar和FlexibleSpaceBar）组成。',
    imagePath: FlutterWechatAvailableImages.catalogAppbar,
  ),
  FlutterWechatWidgetCard(
    title: 'FlutterLogo',
    describe: 'Flutter logo, 以widget形式. 这个widget遵从IconTheme。',
    imagePath: FlutterWechatAvailableImages.catalogFlutter,
  ),
  FlutterWechatWidgetCard(
    title: 'Placeholder',
    describe: '一个绘制了一个盒子的的widget，代表日后有widget将会被添加到该盒子中',
    imagePath: FlutterWechatAvailableImages.catalogFlutter,
  ),
];

/// Port of the source `materialData` list (source `lib/widgets/WeigetData.dart`).
///
/// 35 cards plus the source's 6 section headers (App结构和导航, 按钮, 输入框和选择框,
/// 对话框、Alert、Panel, 信息展示, 布局), in source order.
final List<Widget> flutterWechatMaterialEntries = <Widget>[
  Row(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('App结构和导航', style: TextStyle(fontSize: 30.0)),
      ),
    ],
  ),
  FlutterWechatWidgetCard(
    title: 'Scaffold',
    describe: 'Material Design布局结构的基本实现。此类提供了用于显示drawer、snackbar和底部sheet的API。',
    imagePath: FlutterWechatAvailableImages.catalogScaffold,
  ),
  FlutterWechatWidgetCard(
    title: 'Appbar',
    describe:
        '一个Material Design应用程序栏，由工具栏和其他可能的widget（如TabBar和FlexibleSpaceBar）组成。',
    imagePath: FlutterWechatAvailableImages.catalogAppbar,
  ),
  FlutterWechatWidgetCard(
    title: 'BottomNavigationBar',
    describe: '底部导航条，可以很容易地在tap之间切换和浏览顶级视图。',
    imagePath: FlutterWechatAvailableImages.catalogBottomNavigationBar,
  ),
  FlutterWechatWidgetCard(
    title: 'TabBar',
    describe: '一个显示水平选项卡的Material Design widget。',
    imagePath: FlutterWechatAvailableImages.catalogTabbar,
  ),
  FlutterWechatWidgetCard(
    title: 'TabBarView',
    describe: '显示与当前选中的选项卡相对应的页面视图。通常和TabBar一起使用。',
    imagePath: FlutterWechatAvailableImages.catalogTabBarView,
  ),
  FlutterWechatWidgetCard(
    title: 'MaterialApp',
    describe: '一个方便的widget，它封装了应用程序实现Material Design所需要的一些widget。',
    imagePath: FlutterWechatAvailableImages.catalogMaterialApp,
  ),
  FlutterWechatWidgetCard(
    title: 'WidgetsApp',
    describe: '一个方便的类，它封装了应用程序通常需要的一些widget。',
    imagePath: FlutterWechatAvailableImages.catalogFlutter,
  ),
  FlutterWechatWidgetCard(
    title: 'Drawer',
    describe: '从Scaffold边缘水平滑动以显示应用程序中导航链接的Material Design面板。',
    imagePath: FlutterWechatAvailableImages.catalogDrawer,
  ),
  Row(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('按钮', style: TextStyle(fontSize: 30.0)),
      ),
    ],
  ),
  FlutterWechatWidgetCard(
    title: 'RaisedButton',
    describe: 'Material Design中的button， 一个凸起的材质矩形按钮',
    imagePath: FlutterWechatAvailableImages.catalogButton,
  ),
  FlutterWechatWidgetCard(
    title: 'FloatingActionButton',
    describe: '一个圆形图标按钮，它悬停在内容之上，以展示应用程序中的主要动作。',
    imagePath: FlutterWechatAvailableImages.catalogFloatingActionButton,
  ),
  FlutterWechatWidgetCard(
    title: 'FlatButton',
    describe: '一个扁平的Material按钮',
    imagePath: FlutterWechatAvailableImages.catalogFlatButton,
  ),
  FlutterWechatWidgetCard(
    title: 'IconButton',
    describe: '一个Material图标按钮，点击时会有水波动画',
    imagePath: FlutterWechatAvailableImages.catalogIconButton,
  ),
  FlutterWechatWidgetCard(
    title: 'PopupMenuButton',
    describe: '当菜单隐藏式，点击或调用onSelected时显示一个弹出式菜单列表',
    imagePath: FlutterWechatAvailableImages.catalogPopupMenuButton,
  ),
  FlutterWechatWidgetCard(
    title: 'ButtonBar',
    describe: '水平排列的按钮组',
    imagePath: FlutterWechatAvailableImages.catalogFlutter,
  ),
  Row(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('输入框和选择框', style: TextStyle(fontSize: 30.0)),
      ),
    ],
  ),
  FlutterWechatWidgetCard(
    title: 'TextField',
    describe: '文本输入框',
    imagePath: FlutterWechatAvailableImages.catalogTextField,
  ),
  FlutterWechatWidgetCard(
    title: 'Checkbox',
    describe: '复选框，允许用户从一组中选择多个选项。',
    imagePath: FlutterWechatAvailableImages.catalogCheckbox,
  ),
  FlutterWechatWidgetCard(
    title: 'Radio',
    describe: '单选框，允许用户从一组中选择一个选项。',
    imagePath: FlutterWechatAvailableImages.catalogRadio,
  ),
  FlutterWechatWidgetCard(
    title: 'Switch',
    describe: 'On/off 用于切换一个单一状态',
    imagePath: FlutterWechatAvailableImages.catalogSwitch,
  ),
  FlutterWechatWidgetCard(
    title: 'Slider',
    describe: '滑块，允许用户通过滑动滑块来从一系列值中选择。',
    imagePath: FlutterWechatAvailableImages.catalogSlider,
  ),
  FlutterWechatWidgetCard(
    title: 'Date & Time Pickers',
    describe: '日期&时间选择器',
    imagePath: FlutterWechatAvailableImages.catalogTimePicker,
  ),
  Row(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('对话框、Alert、Panel', style: TextStyle(fontSize: 30.0)),
      ),
    ],
  ),
  FlutterWechatWidgetCard(
    title: 'SimpleDialog',
    describe: '简单对话框可以显示附加的提示或操作',
    imagePath: FlutterWechatAvailableImages.catalogSimpleDialog,
  ),
  FlutterWechatWidgetCard(
    title: 'AlertDialog',
    describe: '一个会中断用户操作的对话款，需要用户确认',
    imagePath: FlutterWechatAvailableImages.catalogAlertDialog,
  ),
  FlutterWechatWidgetCard(
    title: 'BottomSheet',
    describe:
        'BottomSheet是一个从屏幕底部滑起的列表（以显示更多的内容）。你可以调用showBottomSheet()或showModalBottomSheet弹出',
    imagePath: FlutterWechatAvailableImages.catalogBottomSheet,
  ),
  FlutterWechatWidgetCard(
    title: 'ExpansionPanel',
    describe: '扩展面板包含创建流，允许对元素进行轻量级的编辑。expanpanel小部件实现这个组件。',
    imagePath: FlutterWechatAvailableImages.catalogExpansionPanel,
  ),
  FlutterWechatWidgetCard(
    title: 'SnackBar',
    describe: '具有可选操作的轻量级消息提示，在屏幕的底部显示。',
    imagePath: FlutterWechatAvailableImages.catalogSnackBar,
  ),
  Row(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('信息展示', style: TextStyle(fontSize: 30.0)),
      ),
    ],
  ),
  FlutterWechatWidgetCard(
    title: 'Image',
    describe: '一个显示图片的widget',
    imagePath: FlutterWechatAvailableImages.catalogImage,
  ),
  FlutterWechatWidgetCard(
    title: 'Icon',
    describe: 'A Material Design icon.',
    imagePath: FlutterWechatAvailableImages.catalogMdIcon,
  ),
  FlutterWechatWidgetCard(
    title: 'Chip',
    describe: '标签，一个Material widget。 它可以将一个复杂内容实体展现在一个小块中，如联系人。',
    imagePath: FlutterWechatAvailableImages.catalogChip,
  ),
  FlutterWechatWidgetCard(
    title: 'Tooltip',
    describe: '一个文本提示工具，帮助解释一个按钮或其他用户界面，当widget长时间按下时（当用户采取其他适当操作时）显示一个提示标签。',
    imagePath: FlutterWechatAvailableImages.catalogTooltip,
  ),
  FlutterWechatWidgetCard(
    title: 'DataTable',
    describe: '数据表显示原始数据集。它们通常出现在桌面企业产品中。DataTable Widget实现这个组件',
    imagePath: FlutterWechatAvailableImages.catalogDataTable,
  ),
  FlutterWechatWidgetCard(
    title: 'Card',
    describe: '一个 Material Design 卡片。拥有一个圆角和阴影',
    imagePath: FlutterWechatAvailableImages.catalogCard,
  ),
  FlutterWechatWidgetCard(
    title: 'LinearProgressIndicator',
    describe: '一个线性进度条，另外还有一个圆形进度条CircularProgressIndicator',
    imagePath: FlutterWechatAvailableImages.catalogLinearProgressIndicator,
  ),
  Row(
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text('布局', style: TextStyle(fontSize: 30.0)),
      ),
    ],
  ),
  FlutterWechatWidgetCard(
    title: 'ListTile',
    describe: '一个固定高度的行，通常包含一些文本，以及一个行前或行尾图标',
    imagePath: FlutterWechatAvailableImages.catalogListTile,
  ),
  FlutterWechatWidgetCard(
    title: 'Stepper',
    describe: '一个Material Design 步骤指示器，显示一系列步骤的过程',
    imagePath: FlutterWechatAvailableImages.catalogStepper,
  ),
  FlutterWechatWidgetCard(
    title: 'Divider',
    describe: '一个逻辑1像素厚的水平分割线，两边都有填充',
    imagePath: FlutterWechatAvailableImages.catalogDivider,
  ),
];
