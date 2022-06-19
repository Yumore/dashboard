import 'package:sqflite/sqflite.dart';

final String comicDownloadTableName = 'ComicDownload';
final String comicDownloadColumnChapterID = 'ChapterID';
final String comicDownloadColumnChapterName = 'ChapterName';
final String comicDownloadColumnComicID = 'ComicID';
final String comicDownloadColumnComicName = 'ComicName';
final String comicDownloadColumnStatus = 'Status';
final String comicDownloadColumnVolume = 'Volume';
final String comicDownloadColumnPage = 'Page';
final String comicDownloadColumnCount = 'Count';
final String comicDownloadColumnSavePath = 'SavePath';
final String comicDownloadColumnUrls = 'Urls';

class ComicDownloadSqlItem {
  int chapterID = 0;
  String? chapterName;
  int comicID = 0;
  String? comicName;
  int status = 0;
  String? volume;
  int page = 0;
  int count = 0;
  String? savePath;
  String? urls;

  ComicDownloadSqlItem(this.chapterID, this.chapterName, this.comicID, this.comicName, this.status, this.volume, {this.page = 0, this.count = 0, this.savePath, this.urls});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      comicDownloadColumnChapterID: chapterID,
      comicDownloadColumnChapterName: chapterName,
      comicDownloadColumnComicID: comicID,
      comicDownloadColumnComicName: comicName,
      comicDownloadColumnStatus: status,
      comicDownloadColumnVolume: volume,
      comicDownloadColumnPage: page,
      comicDownloadColumnCount: count,
      comicDownloadColumnSavePath: savePath,
      comicDownloadColumnUrls: urls,
    };
    return map;
  }

  ComicDownloadSqlItem.fromMap(Map<String, dynamic> map) {
    chapterID = map[comicDownloadColumnChapterID];
    chapterName = map[comicDownloadColumnChapterName];
    comicID = map[comicDownloadColumnComicID];
    comicName = map[comicDownloadColumnComicName];
    status = map[comicDownloadColumnStatus];
    volume = map[comicDownloadColumnVolume];
    page = map[comicDownloadColumnPage];
    count = map[comicDownloadColumnCount];
    savePath = map[comicDownloadColumnSavePath];
    urls = map[comicDownloadColumnUrls];
  }
}

class ComicDownloadProvider {
  static Database? database;

  static Future<ComicDownloadSqlItem> insert(ComicDownloadSqlItem item) async {
    await database!.insert(comicDownloadTableName, item.toMap());
    return item;
  }

  static Future<ComicDownloadSqlItem> getItem(int id) async {
    List<Map<String, dynamic>> maps = await database!.query(comicDownloadTableName,
        columns: [
          comicDownloadColumnChapterID,
          comicDownloadColumnChapterName,
          comicDownloadColumnComicID,
          comicDownloadColumnComicName,
          comicDownloadColumnStatus,
          comicDownloadColumnVolume,
          comicDownloadColumnPage,
          comicDownloadColumnCount,
          comicDownloadColumnSavePath,
          comicDownloadColumnUrls,
        ],
        where: '$comicDownloadColumnChapterID = ?',
        whereArgs: [id]);

    if (maps.length > 0) {
      return ComicDownloadSqlItem.fromMap(maps.first);
    }
    return ComicDownloadSqlItem.fromMap(<String, dynamic>{});
  }

  static Future<int> clear() async {
    return await database!.delete(comicDownloadTableName);
  }

  static Future<ComicDownloadSqlItem> updateOrInsert(ComicDownloadSqlItem item) async {
    var data = await getItem(item.chapterID);
    if (data != null) {
      await update(item);
      return item;
    } else {
      return await insert(item);
    }
  }

  static Future<List<ComicDownloadSqlItem>> getItems() async {
    List<ComicDownloadSqlItem> maps = (await database!.query(comicDownloadTableName)).map<ComicDownloadSqlItem>((x) => ComicDownloadSqlItem.fromMap(x)).toList();
    return maps;
  }

  static Future<int> delete(int id) async {
    return await database!.delete(comicDownloadTableName, where: '$comicDownloadColumnChapterID = ?', whereArgs: [id]);
  }

  static Future<int> update(ComicDownloadSqlItem item) async {
    return await database!.update(comicDownloadTableName, item.toMap(), where: '$comicDownloadColumnChapterID = ?', whereArgs: [item.chapterID]);
  }

  static Future close() async => database!.close();
}
