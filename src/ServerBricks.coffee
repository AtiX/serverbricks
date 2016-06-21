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

  # Add a brick to be initialized and used with ServerBricks
  # @param [String or Brick] brickInstanceOrString class name or instance of the brick to be used
  # @param [Object] brickParameters constructor parameters for the brick, only used if initialized by class name
  # @param [Function] preInitCallback
  #   callback that is called before prepareInitialization is executed on this brick. May return a Promise.
  # @param [Function] postInitCallback
  #   callback that is called after prepareInitialization is executed on this brick. May return a Promise.
  addBrick: (brickInstanceOrString, brickParameters = {}, preInitCallback, postInitCallback) =>
    if (typeof brickInstanceOrString) == 'string'
      BrickClass = require "./availableBricks/#{brickInstanceOrString}"
      brickInstanceOrString = new BrickClass(brickParameters)

      @bricks.push {
        brick: brickInstanceOrString
        preInitCallback: preInitCallback
        postInitCallback: postInitCallback
      }

  initialize: =>
    @log.info "[ServerBricks] Initializing Framework (modules: #{@modulePath})"

    p = Promise.resolve()

    # Call pre initialization call on each brick as well as the pre/post callbacks if specified
    p = p.then =>
      initChain = Promise.resolve()
      for brickEntry in @bricks
        do (brickEntry) =>
          initChain = initChain.then =>
            @_initializeBrick(brickEntry)
      return initChain

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
    p = p.then =>
      brickPromises = []
      for brickEntry in @bricks
        brickPromises.push brickEntry.brick.finishInitialization()
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
    for brickEntry in @bricks
      absoluteModuleDir = path.join parentDir, moduleFolder
      partPromises.push brickEntry.brick.initializeModule(absoluteModuleDir, module)

    return Promise.all(partPromises)

  # calls prepareInitialization as well as specified pre/post init callbacks on a specified entry of the
  # @bricks array
  _initializeBrick: (brickEntry) =>
    p = Promise.resolve()

    if brickEntry.preInitCallback?
      p = p.then ->
        brickEntry.preInitCallback()

    p = p.then =>
      brickEntry.brick.prepareInitialization(@expressApp, @log)

    if brickEntry.postInitCallback?
      p = p.then ->
        brickEntry.postInitCallback()

    return p
