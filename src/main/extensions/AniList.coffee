express = require "express"
axios = require "axios"

class AniList
    constructor: ->
        @name = "AniList"
        @id = "AniList"
        @baseUrl = "https://anilist.co/api/v2"
        @clientId = process.env.ANILIST_CLIENT_ID
        @clientSecret = process.env.ANILIST_CLIENT_SECRET
        @redirectUri = "#{process.env.DNS}/extensions/#{@name.toLocaleLowerCase()}#{process.env.ANILIST_REDIRECT_ENDPOINT}"
        @accessToken = null
    
    deployExpress: (opt) ->
        router = express.Router()
        
        router.get "/login", (req, res) ->
            unless opt.clientId and opt.clientSecret
                return res.status(500).send 'ANILIST_CLIENT_ID and ANILIST_CLIENT_SECRET must be set in environment variables.'
            authUrl = "#{opt.baseUrl}/oauth/authorize?client_id=#{opt.clientId}&redirect_uri=#{opt.redirectUri}&response_type=code"
            res.redirect authUrl

        router.get process.env.ANILIST_REDIRECT_ENDPOINT, (req, res) ->
            code = req.query.code
            unless code
                return res.status(400).send 'Authorization code is required.'
                
            try
                response = await axios.post "#{opt.baseUrl}/oauth/token",
                    grant_type: 'authorization_code'
                    client_id: opt.clientId
                    client_secret: opt.clientSecret
                    redirect_uri: opt.redirectUri
                    code: code
                console.log "Response", response.data
                accessToken = response.data.access_token
                res.send 'Login berhasil! Sekarang kamu bisa fetch data dari AniList.'
            catch err
                console.error "Error during token exchange:", err
                res.status(500).send 'Gagal tukar token.'

        router.get '/me', (req, res) ->
            do async ->
                unless accessToken
                    return res.status(401).send 'Belum login.'

                query = '''
                    query {
                        Viewer {
                            id
                            name
                            avatar {
                                large
                                medium
                            }
                        }
                    }
                '''

                try
                    response = await axios.post 'https://graphql.anilist.co',
                        query: query,
                        headers:
                            'Authorization': "Bearer #{accessToken}"
                            'Content-Type': 'application/json'

                    res.json response.data
                catch err
                    res.status(500).send 'Gagal ambil data.'
        return router

module.exports = new AniList()