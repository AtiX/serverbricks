path = require 'path'
express = require 'express'
Promise = require 'bluebird'
directoryUtils = require '../utils/directoryUtils'
Brick = require '../Brick'

module.exports = class StaticAssets extends Brick
  constructor: (config = {}) ->
    @staticPaths = config.moduleAssetPaths || ['public']
    @staticNodeModulePaths = config.nodeModuleAssetPaths || []

  prepareInitialization: (@expressApp, @log) =>
    @log.debug '[ServerBricks] initializes staticAssets brick'

    for nodeModulePath in @staticNodeModulePaths
      pathToUse = path.join 'node_modules', nodeModulePath
      @expressApp.use express.static(pathToUse)
      @log.debug "[ServerBricks] Serve static asset node-module path '#{pathToUse}'"

  # called on each module
  initializeModule: (moduleFolder) =>
    p = Promise.resolve()
    p = p.then =>
      servePromises = []
      for staticPath in @staticPaths
        servePromises.push @_serveStaticallyIfExists(moduleFolder, staticPath)
      return Promise.all(servePromises)
    return p

  _serveStaticallyIfExists: (moduleFolder, staticPath) ->
    pubFolder = path.join moduleFolder, staticPath
    return directoryUtils.directoryExists(pubFolder)
    .then (doesExist) =>
      if doesExist
        @expressApp.use express.static(pubFolder)
        @log.debug "[ServerBricks] Serve static asset module path '#{pubFolder}'"
