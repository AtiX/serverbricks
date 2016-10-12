# Configures the module/views subfolder for the view engine of the application

directoryUtils = require '../utils/directoryUtils'
path = require 'path'
Promise = require 'bluebird'
Brick = require '../Brick'

module.exports = class ViewFolders extends Brick
  constructor: (config = {}) ->
    config.useViewCache ?= true
    config.additionalViewFolders ?= []

    @useViewCache = config.useViewCache
    @additionalViewFolders = config.additionalViewFolders

  prepareInitialization: (@expressApp, @log) =>
    @log.debug '[ServerBricks] initializes viewFolders brick'
    @log.debug "[ServerBricks] (useViewCache: #{@useViewCache})"

    # Initialize all view folders with those manually specified
    @viewFolders = @additionalViewFolders.map (folder) -> path.resolve folder

    # Basic jade settings
    @expressApp.set 'view engine', 'pug'
    if @useViewCache
      @expressApp.enable('view cache')
    else
      @expressApp.disable('view cache')
    return

  initializeModule: (moduleFolder) =>
    viewsFolder = path.join moduleFolder, 'views'

    return Promise.resolve().then =>
      return directoryUtils.directoryExists(viewsFolder)
      .then (doesExist) =>
        if doesExist
          @viewFolders.push viewsFolder

  finishInitialization: =>
    @log.info "[ServerBricks] Setting view folders to: [#{@viewFolders}]"
    @expressApp.set 'views', @viewFolders
