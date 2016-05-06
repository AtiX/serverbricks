directoryUtils = require './utils/directoryUtils'
Promise = require 'bluebird'

module.exports = class ModuleFramework
  constructor: (@expressApp, @log, @environment) ->
    # Parts of the framework that actually do something with the modules
    @frameworkParts = []
    @modules = {}
    return

  loadFrameworkParts: (excludedParts = []) =>
    @log.info '[Framework] Loading available parts'

    p = directoryUtils.listFiles(__dirname + '/frameworkParts', '.coffee')
    p = p.then (files) ->
      plainNames = files.map (file) -> file.substr(0, file.length - 7)
      return plainNames
    p = p.then (partNames) =>
      partNames = partNames.filter (partName) -> excludedParts.indexOf(partName) == -1
      for partName in partNames
        @log.debug "[Framework] Loading part '#{partName}'"

        PartClass = require './frameworkParts/' + partName
        partInstance = new PartClass()
        partInstance.name = partName
        @frameworkParts.push partInstance

    return p

  initialize: (@modulePath, partsToInitialize) =>
    @log.info "[Framework] Initializing Framework (#{@modulePath})"

    # If no filter is given, init all parts, else, only initialize the selected ones
    selectedParts = []
    if not partsToInitialize?
      selectedParts = @frameworkParts
    else
      for partName in partsToInitialize
        part = @frameworkParts.find (p) -> p.name == partName

        if part.isInizialized = true
          @log.info "[Framework] Skipping initialization of part '#{partName}' because it already is initialized"
        else
          selectedParts.push part
          part.isInizialized = true

    p = Promise.resolve()

    # Call pre initialization calls on framework parts
    p = p.then =>
      partPromises = []
      for part in selectedParts
        partPromises.push part.prepareInitialization(@expressApp, @log, @environment)
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
      @log.error '[Framework] Framework initialization error:'
      @log.error error
      throw error

    return p

  # Calls initializeModule on all Framework parts
  _initializeModule: (parentDir, moduleFolder, selectedParts) =>
    @log.info "[Framework] Initializing module '#{moduleFolder}'"
    module = @modules[moduleFolder] = {}

    partPromises = []
    for part in selectedParts
      partPromises.push part.initializeModule(parentDir, moduleFolder, module)

    return Promise.all(partPromises)
