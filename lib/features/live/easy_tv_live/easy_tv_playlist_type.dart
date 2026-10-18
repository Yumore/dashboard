/// Playlist dialect detected for an easy_tv_live subscription source.
///
/// Mirrors the source app's `PlayListType`: `m3u` for `#EXTM3U`/`#EXTINF`
/// documents, `txt` for the comma-separated TiBox/TVBox style lists.
enum EasyTvPlaylistType { m3u, txt }
