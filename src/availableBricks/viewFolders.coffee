# Configures the module/views subfolder for the view engine of the application

directoryUtils = require '../utils/directoryUtils'
path = require 'path'
Promise = require 'bluebird'

module.exports = class ViewFolders
  prepareInitialization: (@expressApp, @log, @environment) =>
    @viewFolders = []

    # Basic jade settings
    @expressApp.set 'view engine', 'jade'
    if @environment.developmentMode
      @expressApp.disable('view cache')
    else
      @expressApp.enable('view cache')
    return

  initializeModule: (moduleFolder, module) =>
    viewsFolder = path.join moduleFolder, 'views'

    return Promise.resolve().then =>
      return directoryUtils.directoryExists(viewsFolder)
      .then (doesExist) =>
        if doesExist
          @viewFolders.push viewsFolder

  finishInitialization: =>
    @log.info "[Framework] Setting view folders to: [#{@viewFolders}]"
    @expressApp.set 'views', @viewFolders
