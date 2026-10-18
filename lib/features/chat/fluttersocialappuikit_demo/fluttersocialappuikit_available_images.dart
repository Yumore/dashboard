/// The ten bundled pictures of the FlutterSocialAppUIKit static UI demo.
///
/// Source: `assets/images/cm0.jpeg` … `assets/images/cm9.jpeg`, referenced from
/// `lib/util/data.dart:50` (`"assets/images/cm${random.nextInt(10)}.jpeg"`) and
/// from the profile screen. The files were copied byte-identically into
/// `assets/fluttersocialappuikit_demo/` and must be registered in `pubspec.yaml`
/// with `- assets/fluttersocialappuikit_demo/`.
///
/// The source also had one broken path: `lib/views/screens/chat/conversation.dart:35`
/// builds its avatar from `assets/cm${...}.jpeg` (missing the `images/`
/// segment), and `lib/views/widgets/chat_bubble.dart` receives image bubbles as
/// `assets/cm${...}.jpeg` from the same screen. The port uses the real asset
/// paths for those two places — the source never resolved them either, so this
/// is a documented path fix, not a behaviour change.
class FlutterSocialAppUIKitAvailableImages {
  const FlutterSocialAppUIKitAvailableImages._();

  static const String cm0 = 'assets/fluttersocialappuikit_demo/cm0.jpeg';
  static const String cm1 = 'assets/fluttersocialappuikit_demo/cm1.jpeg';
  static const String cm2 = 'assets/fluttersocialappuikit_demo/cm2.jpeg';
  static const String cm3 = 'assets/fluttersocialappuikit_demo/cm3.jpeg';
  static const String cm4 = 'assets/fluttersocialappuikit_demo/cm4.jpeg';
  static const String cm5 = 'assets/fluttersocialappuikit_demo/cm5.jpeg';
  static const String cm6 = 'assets/fluttersocialappuikit_demo/cm6.jpeg';
  static const String cm7 = 'assets/fluttersocialappuikit_demo/cm7.jpeg';
  static const String cm8 = 'assets/fluttersocialappuikit_demo/cm8.jpeg';
  static const String cm9 = 'assets/fluttersocialappuikit_demo/cm9.jpeg';

  /// The source always draws from `cm0` … `cm9`, in this order.
  static const List<String> all = <String>[
    cm0,
    cm1,
    cm2,
    cm3,
    cm4,
    cm5,
    cm6,
    cm7,
    cm8,
    cm9,
  ];

  /// The source picks a random index into [all]; the port resolves that draw to
  /// the given index so the demo is stable (see
  /// `fluttersocialappuikit_sample_data.dart`). [index] is wrapped so callers
  /// can pass a running counter.
  static String at(int index) => all[index % all.length];
}
