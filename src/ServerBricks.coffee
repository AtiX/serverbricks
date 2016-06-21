directoryUtils = require './utils/directoryUtils'
Promise = require 'bluebird'
path = require 'path'

module.exports = class ServerBricks
  constructor: (options = {}) ->
    # Extract options

    @log = options.log
    # Fallback to console logging
    @log ?= {
      info: (message) -> console.log message
      debug: (message) -> console.log message
      error: (message) -> console.error message
    }

    @expressApp = options.expressApp
    if not @expressApp?
      throw new Error('options.expressApp must not be null')

    @modulePath = options.modulePath
    if not @modulePath?
      throw new Error('options.modulePath must not be null')
    @modulePath = path.resolve @modulePath

    @bricks = []
    @modules = {}
    return

  addBrick: (brickInstanceOrString, brickParameters = {}, before) =>
    if (typeof brickInstanceOrString) == 'string'
      BrickClass = require "./availableBricks/#{brickInstanceOrString}"
      brickInstanceOrString = new BrickClass(brickParameters)

      @bricks.push brickInstanceOrString

  initialize: =>
    @log.info "[ServerBricks] Initializing Framework (modules: #{@modulePath})"

    p = Promise.resolve()

    # Call pre initialization call on each brick
    p = p.then =>
      partPromises = []
      for part in @bericks
        partPromises.push part.prepareInitialization(@expressApp, @log)
      return Promise.all partPromises

    # List all directories (=modules)
    p = p.then =>
      directoryUtils.listDirectories(@modulePath)

    # and initialize them one by one with all bricks
    p = p.then (directories) =>
      initPromises = []

      for folder in directories
        initPromises.push @_initializeModule @modulePath, folder

      return Promise.all(initPromises)

    # Call post initialization call on each brick
    p = p.then ->
      brickPromises = []
      for brick in @bricks
        brickPromises.push brick.finishInitialization()
      return Promise.all(brickPromises)

    p = p.catch (error) =>
      @log.error '[ServerBricks] Framework initialization error:'
      @log.error error
      throw error

    return p

  # Calls initializeModule on all bricks on a selected module folder
  _initializeModule: (parentDir, moduleFolder) =>
    @log.info "[ServerBricks] Initializing module '#{moduleFolder}'"
    module = @modules[moduleFolder] = {}

    partPromises = []
    for brick in @bricks
      absoluteModuleDir = path.join parentDir, moduleFolder
      partPromises.push brick.initializeModule(absoluteModuleDir, module)

    return Promise.all(partPromises)
