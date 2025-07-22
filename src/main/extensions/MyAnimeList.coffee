express = require "express"
axios = require "axios"

class MyAnimeList
    constructor: ->
        @name = "MyAnimeList"
        @id = "MyAnimeList"
        @baseUrl = "https://myanimelist.net/v1"
        @clientId = process.env.MAL_CLIENT_ID
        @clientSecret = process.env.MAL_CLIENT_SECRET
        @redirectUri = "#{process.env.HONOKA_DNS}/extensions/#{@name.toLocaleLowerCase()}#{process.env.MAL_REDIRECT_URI}"
        @pkceCodeChallenge = process.env.MAL_PKCE_CODE_VERIFIER
        @pkceCodeVerifier = process.env.MAL_PKCE_CODE_VERIFIER
    
    deployExpress: (opt) ->
        router = express.Router()
        
        router.get "/login", (req, res) ->
            unless opt.clientId and opt.clientSecret
                return res.status(500).send 'MAL_CLIENT_ID and MAL_CLIENT_SECRET must be set in environment variables.'
            authUrl = "#{opt.baseUrl}/oauth2/authorize?response_type=code&client_id=#{opt.clientId}&redirect_uri=#{opt.redirectUri}&code_challenge=#{opt.pkceCodeChallenge}"
            res.redirect authUrl

        router.get process.env.ANILIST_REDIRECT_ENDPOINT, (req, res) ->
            code = req.query.code
            unless code
                return res.status(400).send 'Authorization code is required.'
                
            try
                response = await axios.post "#{opt.baseUrl}/oauth2/token", new URLSearchParams {
                    client_id: opt.clientId,
                    grant_type: "authorization_code",
                    code: code,
                    code_verifier: opt.pkceCodeVerifier,
                    client_secret: opt.clientSecret,
                    redirect_uri: opt.redirectUri
                },
                    headers: {
                       "Content-Type": "application/x-www-form-urlencoded"
                    }
                console.log "Response", response.data
                accessToken = response.data.access_token
                res.send 'Login berhasil! Sekarang kamu bisa fetch data dari MyAnimeList.'
            catch err
                console.error "Error during token exchange:", err
                res.status(500).send 'Gagal tukar token.'
        return router

module.exports = new MyAnimeList()