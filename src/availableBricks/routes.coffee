directoryUtils = require '../utils/directoryUtils'
Brick = require '../Brick'
path = require 'path'

module.exports = class Routes extends Brick
  prepareInitialization: (@expressApp, @log) =>
    return

  # called on each module
  initializeModule: (moduleFolder) =>
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
