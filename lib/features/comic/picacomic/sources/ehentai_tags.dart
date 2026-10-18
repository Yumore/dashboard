/// Embedded e-hentai tag vocabulary used by the `ehentai` category page.
///
/// PicaComic read these lists from `assets/tags.json` via
/// `TagsTranslation.readData()` (lib/tools/tags_translation.dart:19). The host
/// pubspec does not register that asset and may not be edited, and PicaComic's
/// asset itself is not part of the Dart source, so the full dictionary cannot be
/// carried over. Each namespace therefore ships a small list of real e-hentai
/// tags. The namespaces, their order, and the `categoryType` of every part are
/// ported unchanged from lib/comic_source/built_in/ehentai.dart:72-125.
library;

/// part title -> candidate tags, in the original part order.
const Map<String, List<String>> ehentaiNamespaceTags = {
  'male': [
    'male:anal',
    'male:bbm',
    'male:crossdressing',
    'male:dilf',
    'male:futanari',
    'male:genderswap',
    'male:humiliation',
    'male:inflation',
    'male:netorare',
    'male:sole male',
  ],
  'female': [
    'female:anal',
    'female:big breasts',
    'female:glasses',
    'female:milf',
    'female:nakadashi',
    'female:schoolgirl uniform',
    'female:sole female',
    'female:stockings',
    'female:twintails',
    'female:yuri',
  ],
  'parody': [
    'parody:original',
    'parody:touhou project',
    'parody:fate grand order',
    'parody:kantai collection',
    'parody:love live',
    'parody:pokemon',
    'parody:genshin impact',
    'parody:the idolmaster',
    'parody:one piece',
    'parody:naruto',
  ],
  'character': [
    'hakurei reimu',
    'kirisame marisa',
    'artoria pendragon',
    'hatsune miku',
    'rem',
    'ram',
    'asuka langley soryu',
    'zero two',
    'mash kyrielight',
    'jeanne d\'arc',
  ],
  'mixed': [
    'sole male',
    'sole female',
    'nakadashi',
    'full color',
    'sole dickgirl',
    'tomgirl',
    'unusual insertions',
    'impregnation',
    'defloration',
    'group',
  ],
  'artist': [
    'artist:asanagi',
    'artist:homunculus',
    'artist:shindol',
    'artist:great mosu',
    'artist:fuuga',
    'artist:shimahara',
    'artist:michiking',
    'artist:miyabi',
    'artist:kizuka',
    'artist:taniguchi-san',
  ],
  'group': [
    'group:akatsuki kambou',
    'group:hellabunna',
    'group:todoroki',
    'group:neko wa manma',
    'group:chocolate',
    'group:mogadori',
    'group:yukimi',
    'group:shimapan',
    'group:asagi',
    'group:peach',
  ],
  'cosplayer': [
    'cosplayer:anime',
    'cosplayer:bleach',
    'cosplayer:fate',
    'cosplayer:final fantasy',
    'cosplayer:gundam',
    'cosplayer:kantai collection',
    'cosplayer:naruto',
    'cosplayer:one piece',
    'cosplayer:touhou project',
    'cosplayer:vocaloid',
  ],
  'other': [
    'other:full color',
    'other:uncensored',
    'other:mosaic censorship',
    'other:novel',
    'other:webtoon',
    'other:artbook',
    'other:game cg',
    'other:artistcg',
    'other:cosplay',
    'other:western',
  ],
};

/// The nine category part titles in page order.
const List<String> ehentaiCategoryPartTitles = [
  'male',
  'female',
  'parody',
  'character',
  'mixed',
  'artist',
  'group',
  'cosplayer',
  'other',
];
