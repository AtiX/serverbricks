# Initializes a connection to mongodb
# Requires (and thus initializes) all models in module/db/models

directoryUtils = require '../utils/directoryUtils'
path = require 'path'
mongoose = require 'mongoose'

module.exports = class Mongoose
  prepareInitialization: (@expressApp, @log, @environment) =>
    return new Promise (resolve, reject) =>
      connectionString = "mongodb://\
        #{@environment.mongodb.host}:#{@environment.mongodb.port}/\
        #{@environment.mongodb.db}"

      @log.info "[MongoDB] Connecting to mongodb (#{connectionString})"
      mongoose.connect(connectionString)

      db = mongoose.connection
      db.on 'error', (error) =>
        @log.error "[MongoDB] #{error}"
        reject error
      db.once 'open', =>
        @log.info '[MongoDB] Connection established'
        resolve()

  initializeModule: (moduleFolder, module) =>
    modelsPath = path.join moduleFolder, 'db', 'models'

    return directoryUtils.listFiles modelsPath
    .then (files) =>
      # Load all models by requiring them
      for modelDefinition in files
        model = require path.join modelsPath, modelDefinition
        @log.debug "[MongoDB] Loaded model '#{model.modelName}'"
    .catch (error) ->
      # Ignore it if the db/models subfolder does not exist
      if error.code == 'ENOENT'
        return
      throw error

  finishInitialization: =>
    if @environment.developmentMode
      return @createDebugData()

  # Fills the database with debug data
  createDebugData: =>
    @log.debug '[MongoDB] Filling the database with debug data'

    # Users
    User = require '../../../modules/usersAndAuth/db/models/User.coffee'
    p = User.find({})
    .then (users) =>
      if users.length > 0
        @log.debug '[MongoDB] Skipping User generation since there already are some users'
        return

      users = [
        new User({
          name: 'Major Laser', profilePictureUrl: 'https://s3.amazonaws.com/uifaces/faces/twitter/rem/128.jpg'
        })
        new User({
          name: 'Allison Grayce',
          profilePictureUrl: 'https://s3.amazonaws.com/uifaces/faces/twitter/allisongrayce/128.jpg'
        })
        new User({
          name: 'Liang Chi', profilePictureUrl: 'https://s3.amazonaws.com/uifaces/faces/twitter/liang/128.jpg'
        })
        new User({
          name: 'teleject', profilePictureUrl: 'https://s3.amazonaws.com/uifaces/faces/twitter/teleject/128.jpg'
        })
        new User({
          name: 'Florian Mascaro',
          profilePictureUrl: 'https://s3.amazonaws.com/uifaces/faces/twitter/florianmascaro/128.jpg'
        })
      ]

      return Promise.all users.map (u) -> u.save()

    # Projects
    Project = require '../../../modules/projects/db/models/Project.coffee'
    p = p.then -> Project.find({})
    p = p.then (projects) =>
      if projects.length > 0
        @log.debug '[MongoDB] Skipping Project generation since there already are some projects'
        return

      return User.find({})
      .then (users) ->
        projects = [
          new Project({
            title: 'Treasure Chest',
            description: 'My description', creator: users[0]._id, tags: ['Chest', 'Wood', 'Pirrates']
          })
          new Project({
            title: 'Eiffel Tower', description: 'My description', creator: users[1]._id, tags: ['Paris', 'Architecture']
          })
          new Project({
            title: 'Empire State Building',
            description: 'My description', creator: users[2]._id, tags: ['America', 'Architecture']
          })
          new Project({
            title: 'LEGO Minifigure', description: 'My description', creator: users[3]._id, tags: ['Games', 'Playing']
          })
          new Project({
            title: 'Taj Mahal', description: 'My description', creator: users[4]._id, tags: ['India', 'Architecture']
          })
          new Project({
            title: 'OK Hands', description: 'My description', creator: users[0]._id, tags: ['Body parts']
          })
        ]
        return Promise.all projects.map (p) -> p.save()

    # Comments
    Comment = require '../../../modules/comments/db/models/Comment.coffee'
    p = p.then -> Comment.find({})
    p = p.then (comments) =>
      if comments.length > 0
        @log.debug '[MongoDB] Skipping Comments generation since there are already some comments'
        return

      pProjects = Project.find({}).exec()
      pUsers = User.find({}).exec()

      Promise.all([pProjects, pUsers])
      .then ([projects, users]) ->
        commentText = 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr,
          sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam.'

        comments = [
          new Comment({ author: users[0]._id, project: projects[0]._id, text: commentText})
          new Comment({ author: users[0]._id, project: projects[1]._id, text: commentText})
          new Comment({ author: users[0]._id, project: projects[2]._id, text: commentText})
          new Comment({ author: users[0]._id, project: projects[3]._id, text: commentText})
          new Comment({ author: users[0]._id, project: projects[4]._id, text: commentText})
          new Comment({ author: users[1]._id, project: projects[0]._id, text: commentText})
          new Comment({ author: users[1]._id, project: projects[1]._id, text: commentText})
          new Comment({ author: users[1]._id, project: projects[2]._id, text: commentText})
          new Comment({ author: users[1]._id, project: projects[3]._id, text: commentText})
          new Comment({ author: users[1]._id, project: projects[4]._id, text: commentText})
        ]

        return Promise.all comments.map (c) -> c.save()

    return p
