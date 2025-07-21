AniList = require "./../../main/extensions/AniList"

class Extension
    constructor: () ->
        @extensions = []
    
    # @param id {String}
    getExtension: (id)->
        return @extensions.find (ext) ->
            return ext.id is id

    getExtensions: () ->
        return @extensions.map (ext) ->
            return ext


module.exports = new Extension()