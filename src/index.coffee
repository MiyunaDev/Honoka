dotenv = require 'dotenv'
dotenv.config()

sourceManager = require './core/lib/sourceFind'
extensionManager = require './core/lib/extensionFind'
express = require 'express'
yts = require 'yt-search'

app = express()

port = process.env.PORT or 3000

app.get '/', (req, res) ->
  res.send 'Hello from CoffeeScript + Express!'

app.get '/sources', (req, res) ->
  sources = await sourceManager.getSources().map (ext) ->
    {
      id: ext.id,
      name: ext.name,
      description: ext.description,
      baseUrl: ext.baseUrl,
      platform: ext.platform,
      platformProfile: ext.platformProfile
    }
  await sources.filter (source) ->
    return source.platform is "youtube" and source.platformProfile?.name
  .forEach (youtubeSource) ->
    ytsResult = await yts(youtubeSource.platformProfile.name)
    youtubeSource.verified = ytsResult.channels[0].verified ? true or false
    sourceIndex = sources.findIndex (s) -> s.id is youtubeSource.id
    console.log "Updating source index:", sourceIndex, "for", ytsResult.channels[0]
    await sources[sourceIndex].youtubeData = ytsResult.channels[0]
  setTimeout ->
    res.status(200).send({
      message: "Available sources",
      data: sources
    })
  , 2000    

app.get '/sources/:sourceId', (req, res) ->
  id = req.params.sourceId
  if not id
    return res.status(400).send({ message: "Source ID is required" })
  console.log sourceManager.extensions
  ext = sourceManager.getSource(id)

  return res.status(500).send {
    message: "Source with id #{id} not found"
  } unless ext

  verified = false
  youtubeData = null
  if ext?.platform == "youtube"
    ytsResult = await yts(ext.platformProfile.name)
    verified = ytsResult.channels[0].name is ext.platformProfile.name and ytsResult.channels[0].verified ? true or false
    youtubeData = ytsResult.channels[0]
  
  res.send({
    message:"Success get #{ext.name}",
    data: {
      id: ext.id,
      name: ext.name,
      description: ext.description,
      baseUrl: ext.baseUrl,
      verified: verified,
      features: {
        latest: typeof ext.getLatest == "function" ? true or false,
        browse: typeof ext.getBrowse == "function" ? true or false
      },
      platformProfile: youtubeData
    }
  })

app.get '/sources/:sourceId/latest', (req, res) ->
  id = req.params.sourceId
  if not id
    return res.status(400).send({ message: "Source ID is required" })
  ext = sourceManager.getSource(id)

  unless ext and typeof ext.getLatest is "function"
    return res.status(500).send {
      message: "Source with id #{id} does not support latest feature"
    }

  return res.status(500).send {
    message: "Source with id #{id} not found"
  } unless ext
  page = req.query.page ? 1
  try
    latest = await ext.getLatest(page)
    console.log "Received", latest
    res.send({
      message: "Success get latest from #{ext.name}",
      data: latest
    })
  catch error
    console.error error
    res.status(500).send({
      message: "Failed to get latest from #{ext.name}",
      error: error.message
    })

app.get '/sources/:sourceId/browse', (req, res) ->
  id = req.params.sourceId
  if not id
    return res.status(400).send({ message: "Source ID is required" })
  ext = sourceManager.getSource(id)

  unless ext and typeof ext.getBrowse is "function"
    return res.status(500).send {
      message: "Source with id #{id} does not support browse feature"
    }

  return res.status(500).send {
    message: "Source with id #{id} not found"
  } unless ext
  page = req.query.page ? 1
  title = req.query.title ? ''
  title = decodeURIComponent(title)
  try
    browse = await ext.getBrowse(title, page)
    console.log "Received", browse
    res.send({
      message: "Success get latest from #{ext.name}",
      data: browse
    })
  catch error
    console.error error
    res.status(500).send({
      message: "Failed to get latest from #{ext.name}",
      error: error.message
    })

app.get '/sources/:sourceId/detail/:id', (req, res) ->
  id = req.params.id
  sourceId = req.params.sourceId
  if not id or not sourceId
    return res.status(400).send({ message: "Source ID and Detail ID are required" })
  ext = sourceManager.getSource(sourceId)
  unless ext and typeof ext.getDetail is "function"
    return res.status(500).send {
      message: "Source with id #{sourceId} does not support detail feature"
    }
  return res.status(500).send {
    message: "Source with id #{sourceId} not found"
  } unless ext
  try
    detail = await ext.getDetail(id)
    console.log "Received", detail
    res.send({
      message: "Success get detail from #{ext.name}",
      data: detail
    })
  catch error
    console.error error
    res.status(500).send({
      message: "Failed to get detail from #{ext.name}",
      error: error.message
    })

app.get '/extensions', (req, res) ->
  extensions = await extensionManager.getExtensions().map (ext) ->
    {
      id: ext.id,
      name: ext.name
    }
  res.status(200).send({
      message: "Available extebsions",
      data: extensions
    })

app.get '/extensions/:extensionId', (req, res) ->
  id = req.params.extensionId
  if not id
    return res.status(400).send({ message: "Extension ID is required" })
  ext = extensionManager.getExtension(id)

  return res.status(500).send {
    message: "Extension with id #{id} not found"
  } unless ext

  res.send({
    message:"Success get #{ext.name}",
    data: {
      id: ext.id,
      name: ext.name
    }
  })

extensionManager.extensions.forEach (ext) ->
  if typeof ext.deployExpress is "function"
    routes = ext.deployExpress(ext)
    app.use "/extensions/#{ext.name.toLocaleLowerCase()}", routes

app.listen port, ->
  console.log "Server is running at http://localhost:#{port}"