path = require 'path'
sassMiddleware = require 'node-sass-middleware'
Promise = require 'bluebird'
directoryUtils = require '../utils/directoryUtils'
Brick = require '../Brick'

# Autogenerates CSS out of SASS/SCSS files in a defined subfolder and serves them
module.exports = class Sass extends Brick

  constructor: (config = {}) ->
    @styleSubfolder = config.styleSubfolder || 'public/styles'
    @urlPrefix = config.urlPrefix || '/styles'

  prepareInitialization: (@expressApp, @log) =>
    @log.debug '[ServerBricks] initializes sass brick'
    @log.debug "[ServerBricks] (styleSubfolder: #{@styleSubfolder}, urlPrefix: #{@urlPrefix})"
    return

  # called on each module
  initializeModule: (moduleFolder) =>
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
