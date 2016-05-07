# Configures the module/views subfolder for the view engine of the application

directoryUtils = require '../utils/directoryUtils'
path = require 'path'
Promise = require 'bluebird'
Brick = require '../Brick'

module.exports = class ViewFolders extends Brick
  constructor: (config = {}) ->
    @useViewCache = config.useViewCache || true

  prepareInitialization: (@expressApp, @log) =>
    @viewFolders = []

    # Basic jade settings
    @expressApp.set 'view engine', 'jade'
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
    @log.info "[Framework] Setting view folders to: [#{@viewFolders}]"
    @expressApp.set 'views', @viewFolders
