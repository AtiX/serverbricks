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

  addBrick: (brickInstanceOrString, brickParameters = {}) =>
    if (typeof brickInstanceOrString) == 'string'
      BrickClass = require "./availableBricks/#{brickInstanceOrString}"
      brickInstanceOrString = new BrickClass(brickParameters)

      @bricks.push brickInstanceOrString

  initialize: (partsToInitialize) =>
    @log.info "[ServerBricks] Initializing Framework (modules: #{@modulePath})"

    # If no filter is given, init all parts, else, only initialize the selected ones
    selectedParts = []
    if not partsToInitialize?
      selectedParts = @bricks
    else
      for partName in partsToInitialize
        part = @bricks.find (p) -> p.name == partName

        if part.isInizialized = true
          @log.info "[ServerBricks] Skipping initialization of brick '#{partName}' because it already is initialized"
        else
          selectedParts.push part
          part.isInizialized = true

    p = Promise.resolve()

    # Call pre initialization calls on framework parts
    p = p.then =>
      partPromises = []
      for part in selectedParts
        partPromises.push part.prepareInitialization(@expressApp, @log)
      return Promise.all partPromises

    # List all directories and call initializeModule on them
    p = p.then =>
      directoryUtils.listDirectories(@modulePath)

    p = p.then (directories) =>
      initPromises = []

      for folder in directories
        initPromises.push @_initializeModule @modulePath, folder, selectedParts

      return Promise.all(initPromises)

    # Call post initialization calls on framework parts
    p = p.then ->
      partPromises = []
      for part in selectedParts
        partPromises.push part.finishInitialization()
      return Promise.all(partPromises)

    p = p.catch (error) =>
      @log.error '[ServerBricks] Framework initialization error:'
      @log.error error
      throw error

    return p

  # Calls initializeModule on all Framework parts
  _initializeModule: (parentDir, moduleFolder, selectedParts) =>
    @log.info "[ServerBricks] Initializing module '#{moduleFolder}'"
    module = @modules[moduleFolder] = {}

    partPromises = []
    for part in selectedParts
      absoluteModuleDir = path.join parentDir, moduleFolder
      partPromises.push part.initializeModule(absoluteModuleDir, module)

    return Promise.all(partPromises)
