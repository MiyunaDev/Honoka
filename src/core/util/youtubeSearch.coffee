yts = require 'yt-search'

youtubeSearch = (query, page) ->
  return yts({
        query: query,
        type: "playlist"
        pages: page or 1,
        userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36"
    })

module.exports = youtubeSearch