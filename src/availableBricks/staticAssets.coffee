path = require 'path'
express = require 'express'
Promise = require 'bluebird'
directoryUtils = require '../utils/directoryUtils'
Brick = require '../Brick'

module.exports = class StaticAssets extends Brick
  constructor: (config = {}) ->
    @staticPaths = config.staticPaths || ['public']

  # called before any modules are initialized
  prepareInitialization: (@expressApp, @log) =>
    # static Fontawesome in node modules
    @expressApp.use express.static('node_modules/font-awesome/')

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
