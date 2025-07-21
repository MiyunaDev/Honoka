class Source
    constructor: () ->
        @sources = []
    
    # @param id {String}
    getSource: (id)->
        return @sources.find (src) ->
            return src.id is id

    getSources: () ->
        return @sources.map (ext) ->
            return ext


module.exports = new Source()