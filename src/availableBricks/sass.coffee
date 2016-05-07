path = require 'path'
sassMiddleware = require 'node-sass-middleware'
Promise = require 'bluebird'
directoryUtils = require '../utils/directoryUtils'

# Autogenerates CSS out of SASS/SCSS files in a defined subfolder and serves them
module.exports = class Sass

  constructor: (config = {}) ->
    @styleSubfolder = config.styleSubfolder || 'public/styles'
    @urlPrefix = config.urlPrefix || '/styles'

  prepareInitialization: (@expressApp, @log, @environment) =>
    return

  # called on each module
  initializeModule: (moduleFolder, module) =>
    p = Promise.resolve()
    p = p.then =>
      pubStylesFolder = path.join moduleFolder, @styleSubfolder
      return directoryUtils.directoryExists(pubStylesFolder)
      .then (doesExist) =>
        if doesExist
          @expressApp.use sassMiddleware({
            src: pubStylesFolder
            debug: false
            outputStyle: 'compressed'
            prefix: @urlPrefix
            indentedSyntax: true,
            sourceMap: true
          })
    return p

  # called after all modules are initialized
  finishInitialization: ->
    return
