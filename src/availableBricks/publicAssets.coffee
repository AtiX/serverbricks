path = require 'path'
express = require 'express'
Promise = require 'bluebird'
directoryUtils = require '../utils/directoryUtils'

module.exports = class PublicAssets
  # called before any modules are initialized
  prepareInitialization: (@expressApp, @log, @environment) =>
    # static Fontawesome in node modules
    @expressApp.use express.static('node_modules/font-awesome/')

  # called on each module
  initializeModule: (moduleFolder, module) =>
    p = Promise.resolve()
    p = p.then =>
      # Check if public folder exists, serve it staticly
      pubFolder = path.join moduleFolder, 'public'
      return directoryUtils.directoryExists(pubFolder)
      .then (doesExist) =>
        if doesExist
          @expressApp.use express.static(pubFolder)

    return p

  # called after all modules are initialized
  # Actually set up browserify bundle with all collected files
  finishInitialization: ->
    return
