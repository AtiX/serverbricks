directoryUtils = require '../utils/directoryUtils'
Brick = require '../Brick'
path = require 'path'

module.exports = class Routes extends Brick
  prepareInitialization: (@expressApp, @log) =>
    return

  # called on each module
  initializeModule: (moduleFolder) =>
    @log.debug '[ServerBricks] initializes routes brick'
    routesDir = path.join moduleFolder, 'routes'

    return directoryUtils.listFiles(routesDir)
    .then (routeFiles) =>
      routePromises = []

      for file in routeFiles
        # Require route module and call initialize on it
        routeModule = require path.join routesDir, file
        returnValue = routeModule.initialize @expressApp
        if returnValue?
          routePromises.push returnValue

      return Promise.all(routePromises)
    .catch (error) ->
      # ignore it if routes subfolder does not exist
      if error.code == 'ENOENT'
        return
      else
        throw error
