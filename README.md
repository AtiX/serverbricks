[![Build Status](https://travis-ci.org/AtiX/serverbricks.svg?branch=master)](https://travis-ci.org/AtiX/serverbricks)

# Serverbricks

Serverbricks is a pluggable Node.js server framework based on express to jumpstart server development.
It offers various *bricks* that accomplish commonly needed tasks - e.g. define routes or bundle code with browserify.

To keep the project structured and clean even for bigger codebases, the code is separated into *modules*. All modules
have similar structure, for instance, bundling code with browserify is done by looking into the `/client` subfolder
of each module. Thus, separate parts of your app can be separated by code, but still use the same features offered
by bricks.

## Example

Let's imagine building a webshop (based on angular or your preferred frontend framework)
with some static landing/imprint/.. pages. For better structure,
we separate the angular app and the static pages and create two modules:

```
- src
   |- server.coffee
   |- modules
       |- staticPages
           |- public
           |   |- ...
           |- routes
           |   |- staticRoutes.coffe
           |- views
           |   |- landingpage.jade
       |- webshopWithAngular
           |- public
               |- ...
           |- routes
               |- productAPI.coffee
           |- views
               |- productInfoPartial.jade
               |- ...
           |- client
               |- productController.coffee
```

Now, we use serverBricks to get everything working:

```coffeescript
# In server.coffee

serverBricks = new ServerBricks({
  expressApp: webapp # the object returned by express()
  log: log # winston works well, if nothing is defined, console is used
  modulePath: './src/modules' # where are our modules?
})

# Now, it's time to add functionality

# first, we want to serve static assets in all /public folders
serverBricks.addBrick 'staticAssets'

# then, let each module define its routes in /routes
serverBricks.addBrick 'routes'

# Use pug (formerly jade) to compile templates in /views
serverBricks.addBrick 'viewFolders'

# And use browserify to bundle all code in /client folder
serverBricks.addBrick 'browserifyCode'

startPromise = serverBricks.initialize()
```

## Available bricks
You are not restricted to use the built-in bricks. `addBrick` also supports
receiving an brick instance, which needs to offer the methods specified in `Brick.coffee`.

< ToDo: link each brick with detailed codo documentation >

- *browserifyCode* bundles code with browserify and serves it to clients as client.js.
- *mongoose* initializes a connection to mongodb and looks for mongoose models in /db/models
- *routes* lets each module define routes in /routes
- *sass* transforms sass/scss to css in /public/styles. Important: use this brick before
the staticAssets bricks or stylesheet recompilation won't work.
- *staticAssets* serves everything in /public as static files.
- *viewFolders* configures express to use pug ~~jade~~ as a view engine and allows to use pug/jade templates stored in /views

## Brick configuration

Each brick can be configured by supplying a config object: `serverBricks.addBrick 'Name', config`

**sass:**

- `urlPrefix` defines the url prefix where stylesheets are served. Defaults to `/styles`, so a stylesheet
named `screen.sass` will be available as `/styles/screen.css`.
- `styleSubfolder` defines the subfolder in each module where stylesheets are searched. Defaults to `public/styles`

**viewFolders:**

- `useViewCache` defines whether view caching is used. Defaults to `true`.

## Development
Although the ideas and most of the code of ServerBricks is used in multiple production apps, the module itself is fairly new
and still needs some work and polishing - feel free to file issues and create pull requests.

Development ist done in Coffeescript, with grunt as a build system. Please see the gruntfile
for more details.
