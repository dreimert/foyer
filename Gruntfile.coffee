'use strict'

module.exports = (grunt) ->

  grunt.initConfig
    assets:
      jade: ['app/index.static.jade']
      coffee: ['app/app.coffee', 'app/scripts/*/index.coffee', 'app/scripts/*/*.coffee']
      js: [
        'bower_components/moment/moment.js'
        'bower_components/moment/locale/fr.js'
        'bower_components/angular/angular.min.js'
        'bower_components/angular-material/angular-material.min.js'
        'bower_components/angular-animate/angular-animate.min.js'
        'bower_components/angular-aria/angular-aria.min.js'
        'bower_components/angular-moment/angular-moment.min.js'
        'bower_components/angular-ui-router/release/angular-ui-router.min.js'
        'bower_components/eventEmitter/EventEmitter.min.js'
        'bower_components/hammerjs/hammer.min.js'
      ]
      css: [
        "bower_components/angular-material/angular-material.min.css"
        "bower_components/angular-material/themes/*.css"
        "app/styles/*.css"
      ]

    watch:
      js:
        files: '<%= assets.js %>'
        tasks: ['uglify']
        options:
          atBegin: true
          livereload: true

      css:
        files: '<%= assets.css %>'
        tasks: ['cssmin']
        options:
          atBegin: true
          livereload: true

      coffee:
        files: '<%= assets.coffee %>'
        tasks: ['coffee:frontend', 'ngAnnotate']
        options:
          livereload: true
          atBegin: true

      jade:
        files: ['app/**/*.jade']
        tasks: ['jade', 'ngtemplates']
        options:
          livereload: true
          atBegin: true

    coffee:
      frontend:
        files:
          'build/js/app.js': '<%= assets.coffee %>'

    ngAnnotate:
      app:
        files:
          "build/js/app.annotated.js": "build/js/app.js"

    uglify:
      vendor:
        options:
          beautify: true
        files:
          'build/js/vendor.js': '<%= assets.js %>'

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

    copy:
      assets:
        expand: true
        cwd: 'app/assets'
        src: '*'
        dest: 'build/'
      images:
        expand: true
        src: 'bower_components/*/dist/images/*.png'
        dest: 'build/css/images/'
        flatten: true
      icons:
        expand: true
        src: 'bower_components/material-design-icons/*/svg/production/*_24px.svg'
        dest: 'build/css/icons/'
        flatten: true

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-nodemon')
  grunt.loadNpmTasks('grunt-concurrent')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-ng-annotate')
  grunt.loadNpmTasks('grunt-angular-templates')

  grunt.registerTask('default', ['copy', 'concurrent:dev'])
  grunt.registerTask('production', ['copy', 'jade', 'ngtemplates', 'coffee', 'ngAnnotate', 'uglify', 'cssmin'])
