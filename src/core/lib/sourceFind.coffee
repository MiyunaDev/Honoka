MuseIndonesiaExtension = require "./../../main/sources/[ID] MuseIndonesia/source"

class Source
    constructor: () ->
        @extensions = [MuseIndonesiaExtension]
    
    # @param id {String}
    getExtension: (id)->
        return @extensions.find (ext) ->
            return ext.id is id

    getExtensions: () ->
        return @extensions.map (ext) ->
            return ext


module.exports = new Source()