import 'dart:ui' as ui;

/// One rendered page of a chapter.
///
/// The source kept both a [ui.Picture] (the retained draw commands) and a
/// rasterised [ui.Image]: the simulation-turn animation drew pictures for the
/// cheap layers but switched to the image for the folded back area, because the
/// complex transform stack performed far better on an image than on a picture.
class ReaderCanvasPage {
  ReaderCanvasPage({this.pageIndex = 0, this.pagePicture, this.pageImage});

  int pageIndex;
  ui.Picture? pagePicture;
  ui.Image? pageImage;
}
