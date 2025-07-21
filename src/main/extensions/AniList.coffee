class AniList
    constructor: ->
        @name = "AniList"
        @id = "AniList"
        @baseUrl = "https://anilist.co/api/v2"
        @clientId = process.env.ANILIST_CLIENT_ID or 'your_client_id'
        @clientSecret = process.env.ANILIST_CLIENT_SECRET or 'your_client_secret'
        @redirectUri = "#{process.env.DNS}#{process.env.ANILIST_REDIRECT_ENDPOINT}"
        @accessToken = null
    
    deployExpress: (app) ->
        app.get "/#{@name.toLocaleLowerCase()}/login", (req, res) ->
            authUrl = "#{@baseUrl}/oauth/authorize?client_id=#{@ANILIST_CLIENT_ID}&redirect_uri=#{@ANILIST_REDIRECT_URI}&response_type=code"
            res.redirect authUrl

            app.get process.env.ANILIST_REDIRECT_ENDPOINT, (req, res) ->
                code = req.query.code
                unless code
                    return res.status(400).send 'Authorization code is required.'

                try
                    response = await axios.post "#{@baseUrl}/oauth/token",
                        grant_type: 'authorization_code'
                        client_id: ANILIST_CLIENT_ID
                        client_secret: ANILIST_CLIENT_SECRET
                        redirect_uri: ANILIST_REDIRECT_URI
                        code: code
                    console.log "Response", response.data
                    accessToken = response.data.access_token
                    res.send 'Login berhasil! Sekarang kamu bisa fetch data dari AniList.'
                catch err
                    console.error "Error during token exchange:", err
                    res.status(500).send 'Gagal tukar token.'

            app.get '/me', (req, res) ->
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