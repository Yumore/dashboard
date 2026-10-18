/// Ports a subset of PicaComic lib/network/nhentai_network/tags.dart.
///
/// The original map has 720 entries and is embedded as Dart source, so it can
/// be shrunk only by hand. This port keeps the first 59 entries verbatim plus
/// the three language tag ids used by `NhentaiNetwork.parseComic`
/// (nhentai_main_network.dart:96-103), which are checked as raw gallery
/// `data-tags` values and are *not* part of the source map.
///
/// Known gaps: every tag id outside this map is dropped from a gallery's tag
/// list (the original looked it up too, so behaviour is identical for these
/// entries and simply lossy for the rest).
const Map<String, String> nhentaiTags = {
  '2937': 'big breasts',
  '35762': 'sole female',
  '35763': 'sole male',
  '8010': 'group',
  '14283': 'anal',
  '19440': 'lolicon',
  '24201': 'stockings',
  '10314': 'schoolgirl uniform',
  '13720': 'nakadashi',
  '29859': 'blowjob',
  '8378': 'glasses',
  '20905': 'full color',
  '32341': 'shotacon',
  '27553': 'rape',
  '15658': 'bondage',
  '23895': 'yaoi',
  '27473': 'mosaic censorship',
  '13989': 'ahegao',
  '22942': 'incest',
  '21712': 'males only',
  '1207': 'milf',
  '19018': 'dark skin',
  '22945': 'double penetration',
  '25614': 'paizuri',
  '20035': 'x-ray',
  '779': 'futanari',
  '23237': 'tankoubon',
  '21572': 'multi-work series',
  '20525': 'defloration',
  '14971': 'sex toys',
  '8653': 'netorare',
  '3735': 'swimsuit',
  '19954': 'yuri',
  '15348': 'ffm threesome',
  '8368': 'full censorship',
  '15408': 'femdom',
  '29224': 'impregnation',
  '29013': 'dilf',
  '85295': 'twintails',
  '31044': 'collar',
  '85288': 'ponytail',
  '24380': 'pantyhose',
  '9260': 'cheating',
  '28031': 'sister',
  '16828': 'hairy',
  '31880': 'bbm',
  '30555': 'big penis',
  '15782': 'crossdressing',
  '31775': 'tentacles',
  '27384': 'mind break',
  '19175': 'bikini',
  '8739': 'story arc',
  '30473': 'muscle',
  '24102': 'lactation',
  '7752': 'schoolboy uniform',
  '20617': 'mind control',
  '9083': 'big ass',
  '29023': 'tomgirl',
  '81774': 'kemonomimi',
};

/// nhentai_main_network.dart:96-103 — the language tag ids, with the labels the
/// parser assigns.
const Map<String, String> nhentaiLanguageTagIds = {
  '12227': 'English',
  '6346': '日本語',
  '29963': '中文',
};

/// nhentai.dart:36-37 — the `/language/<x>` category paths.
const List<String> nhentaiLanguageNames = ['chinese', 'japanese', 'english'];
