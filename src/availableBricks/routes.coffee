directoryUtils = require '../utils/directoryUtils'

path = require 'path'

module.exports = class Routes
  prepareInitialization: (@expressApp, @log, @environment) =>
    return

  # called on each module
  initializeModule: (moduleFolder, module) =>
    routesDir = path.join moduleFolder, 'routes'

    return directoryUtils.listFiles(routesDir)
    .then (routeFiles) =>
      for file in routeFiles
        # Require route module and call initialize on it
        routeModule = require path.join routesDir, file
        routeModule.initialize @expressApp
    .catch (error) ->
      # ignore it if routes subfolder does not exist
      if error.code == 'ENOENT'
        return
      else
        throw error

  # called after all modules are initialized
  # Actually set up browserify bundle with all collected files
  finishInitialization: ->
    return
