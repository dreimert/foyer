'use strict'

module.exports = (grunt) ->

  grunt.initConfig
    assets:
      jade: ['app/index.static.jade']
      coffee: ['app/app.coffee', 'app/scripts/*/index.coffee', 'app/scripts/*/*.coffee']
      css: [
        "node_modules/angular-material/angular-material.min.css"
        "node_modules/angular-material/themes/*.css"
        "node_modules/angular-material-data-table/dist/md-data-table.min.css"
        "app/styles/*.css"
      ]

    watch:
      css:
        files: '<%= assets.css %>'
        tasks: ['cssmin']
        options:
          atBegin: true
          livereload: true

      jade:
        files: ['app/**/*.jade']
        tasks: ['jade', 'ngtemplates', 'concat:templates', 'browserify:app', 'ngAnnotate']
        options:
          livereload: true
          atBegin: true

      browserify:
        files: ['app/**/*.coffee']
        tasks: ['browserify:app', 'ngAnnotate']
        options:
          livereload: true
          atBegin: true

    browserify:
      app:
        src: ["./app/app.coffee"]
        dest: 'build/js/app.js'
        options:
          transform: ['coffeeify']
          browserifyOptions:
            extensions: ['.coffee']

    ngAnnotate:
      app:
        files:
          "build/js/app.annotated.js": "build/js/app.js"

    cssmin:
      production:
        files:
          'build/css/app.css': '<%= assets.css %>'

    nodemon:
      web:
        script: 'server/index.coffee'
        options:
          args: []
          ext: 'coffee'
          delayTime: 1
          watch: ['server/*.coffee', 'server/**/*.coffee']

    concurrent:
      dev:
        tasks: [
          'nodemon:web',
          'watch'
        ]
        options:
          logConcurrentOutput: true
          limit: 6

    jade:
      local:
        options:
          pretty: true
          data: () ->
            require('./conf.coffee').jade
        files:
          "build/index.html": 'app/index.jade'
      template:
        options:
          pretty: true
          doctype: "html"
        files: [
          expand: true
          cwd: 'app/partials'
          src: '*'
          dest: 'build/templates/'
        ]

    ngtemplates:
      "ardoise.templates":
        cwd: 'build/templates'
        src: '*.jade'
        dest: 'build/js/templates.js'
        options:
          standalone: true

    concat:
      templates:
        options:
          banner: "angular = require('angular');"
          footer: "module.exports = 'ardoise.templates';"
        files:
          'build/js/templates_browserify.js': ['build/js/templates.js']

    copy:
      assets:
        expand: true
        cwd: 'app/assets'
        src: '*'
        dest: 'build/'
      icons:
        expand: true
        src: 'node_modules/material-design-icons/*/svg/production/*_24px.svg'
        dest: 'build/css/icons/'
        flatten: true

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-nodemon')
  grunt.loadNpmTasks('grunt-concurrent')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-ng-annotate')
  grunt.loadNpmTasks('grunt-angular-templates')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-contrib-concat')

  grunt.registerTask('default', ['copy', 'concurrent:dev'])
  grunt.registerTask('production', ['copy', 'jade', 'ngtemplates', 'concat:templates', 'browserify:app', 'ngAnnotate', 'cssmin'])
