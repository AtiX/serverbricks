path = require 'path'

module.exports = (grunt) ->
  grunt.initConfig(
    coffee:
      # Transpiles src/*.coffee to build/*.js
      compile:
        options:
          bare: true
          sourceMap: true
        expand: true
        flatten: false
        cwd: 'src/'
        src: '**/*.coffee'
        dest: 'build'
        ext: '.js'
    mochaTest:
      test:
        src: 'test/**/*.coffee'
    shell:
      coffeelint:
        command: -> path.normalize './node_modules/.bin/coffeelint .'
      codo:
        command: -> path.normalize './node_modules/.bin/codo'
  )

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-shell'

  grunt.registerTask 'default', ['shell:coffeelint', 'mochaTest', 'coffee', 'shell:codo']

  grunt.registerTask 'test', ['shell:coffeelint', 'mochaTest']

  # Tasks to be run when gitlab-ci is running
  grunt.registerTask 'ciTestset', ['shell:coffeelint', 'mochaTest', 'coffee']

  # Create JS and documentation
  grunt.registerTask 'prepublish', ['coffee', 'shell:codo']
