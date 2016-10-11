path = require 'path'
express = require 'express'
Promise = require 'bluebird'
directoryUtils = require '../utils/directoryUtils'
Brick = require '../Brick'

module.exports = class StaticAssets extends Brick
  constructor: (config = {}) ->
    @staticPaths = config.moduleAssetPaths || ['public']
    @staticNodeModulePaths = config.nodeModuleAssetPaths || []

    @staticPaths = @_ensureUrlAndPath @staticPaths
    @staticNodeModulePaths = @_ensureUrlAndPath @staticNodeModulePaths

  # Ensures that we know the url and path for each entry. For strings, the global
  # url root '/' is assumed
  _ensureUrlAndPath: (inputArray) ->
    output = []

    for entry in inputArray
      if typeof entry is 'string'
        # Assume root mount point
        output.push {
          urlRoot: '/'
          path: entry
        }
      else
        # Assume object with correct keys
        output.push entry

    return output

  prepareInitialization: (@expressApp, @log) =>
    @log.debug '[ServerBricks] initializes staticAssets brick'

    for mountPoint in @staticNodeModulePaths
      pathToUse = path.join 'node_modules', mountPoint.path
      @expressApp.use mountPoint.urlRoot, express.static(pathToUse)
      @log.debug "[ServerBricks] Serve static asset node-module path '#{mountPoint.urlRoot}' -> #{pathToUse}'"

  # called on each module
  initializeModule: (moduleFolder) =>
    p = Promise.resolve()
    p = p.then =>
      servePromises = []
      for mountPoint in @staticPaths
        servePromises.push @_serveStaticallyIfExists(moduleFolder, mountPoint)
      return Promise.all(servePromises)
    return p

  _serveStaticallyIfExists: (moduleFolder, mountPoint) ->
    pubFolder = path.join moduleFolder, mountPoint.path
    return directoryUtils.directoryExists(pubFolder)
    .then (doesExist) =>
      if doesExist
        @expressApp.use mountPoint.urlRoot, express.static(pubFolder)
        @log.debug "[ServerBricks] Serve static asset module path '#{mountPoint.urlRoot}' -> #{pubFolder}'"
