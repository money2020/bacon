module.exports = (grunt) ->

    # load all grunt plugins defined in package.json
    require('load-grunt-tasks') grunt

    # Project configuration.
    grunt.initConfig

        pkg: grunt.file.readJSON('package.json')

        dirs:
            src:    'src'
            tmp:    'tmp'
            build:  'build' # if you change this, update the `symlink` task
            config: 'config'

        cacheBust:
            options:
                encoding:   'utf8'
                algorithm:  'md5'
                length:     16
                rename:     true
            assets:
                files: [{
                    src: ['<%= dirs.build %>/index.html']
                }]

        clean:
            tmp:       '<%= dirs.tmp %>'
            build:     '<%= dirs.build %>'
            sasscache: '.sass-cache'

        coffee:
            dev:
                cwd:    '<%= dirs.src %>/scripts'
                src:    '**/*.coffee'
                expand: true
                rename: (src, dest) ->
                    '<%= dirs.build %>/assets/js/' + dest.replace('.coffee', '.js')
            prod:
                cwd:    '<%= dirs.src %>/scripts'
                src:    '**/*.coffee'
                expand: true
                rename: (src, dest) ->
                    '<%= dirs.tmp %>/assets/js/' + dest.replace('.coffee', '.js')

        connect:
            options:
                port: 2121
                base: '<%= dirs.build %>'
                middleware: (connect, options) -> [
                    (request, response, next) ->
                        response.setHeader 'Access-Control-Allow-Origin',  'http://127.0.0.1:15000'
                        response.setHeader 'Access-Control-Allow-Headers', 'Accept,Accept-Version,Content-Length,Content-MD5,Content-Type,Date,X-Api-Version,Origin,X-Requested-With,X-Frame-Options'
                        response.setHeader 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS'
                        next()
                    connect.static(options.base)
                ]
            dev:
                options:
                    keepalive: false
            prod:
                options:
                    keepalive: true

        copy:
            static:
                files: [{
                        expand: true
                        cwd:    '<%= dirs.src %>/fonts'
                        src:    '**/*'
                        dest:   '<%= dirs.build %>/assets/fonts'
                    },
                    {
                        expand: true
                        cwd:    '<%= dirs.src %>/images'
                        src:    '**/*'
                        dest:   '<%= dirs.build %>/assets/images'
                    },
                    {
                        src:  '<%= dirs.src %>/images/42logo-black.png'
                        dest: '<%= dirs.build %>/favicon.ico'
                    }
                ]
            js_libs_dev:
                src:     '<%= dirs.src %>/scripts/libs/**/*.js'
                dest:    '<%= dirs.build %>/assets/js/libs/'
                expand:  true
                flatten: true
            js_libs_prod:
                src:     '<%= dirs.src %>/scripts/libs/**/*.js'
                dest:    '<%= dirs.tmp %>/assets/js/libs/'
                expand:  true
                flatten: true

        cssmin:
            prod:
                expand: true
                cwd:    '<%= dirs.build %>/assets/css'
                src:    '*.css'
                dest:   '<%= dirs.build %>/assets/css'
                ext:    '.css'

        jade:
            index:
                src:  'src/jade/index.jade'
                dest: '<%= dirs.build %>/index.html'
                options:
                    client:         false
                    pretty:         true
                    compileDebug:   true
            partials:
                cwd:  '<%= dirs.src %>/jade/partials'
                src:  '**/*.jade'
                dest: '<%= dirs.build %>/partials/'
                expand: true
                ext: '.html'
                options:
                    client: false
                    pretty: true
                    compileDebug: true
            widgets:
                cwd:  '<%= dirs.src %>/jade/widgets'
                src:  '**/*.jade'
                dest: '<%= dirs.build %>/widgets'
                expand: true
                ext: '.html'
                options:
                    client: false
                    pretty: true
                    compileDebug: true
            templates:
                cwd:  '<%= dirs.src %>/jade/templates'
                src:  '**/*.jade'
                dest: '<%= dirs.build %>/templates'
                expand: true
                ext: '.html'
                options:
                    client: false
                    pretty: true
                    compileDebug: true

        sass: dev:
            options:
                includePaths:   require('node-bourbon').includePaths
                sassDir:        '<%= dirs.src %>/styles'
                cssDir:         '<%= dirs.build %>/assets/css'
                outputStyle:    'nested'
            files: [{
                cwd:    '<%= dirs.src %>/styles'
                src:    '**/*.scss'
                dest:   '<%= dirs.build %>/assets/css'
                ext:    '.css'
                expand: true
            }]

        uglify:
            js_app:
                options:
                    mangle: false
                files: [
                  expand:   true
                  cwd:      '<%= dirs.tmp %>/assets/js/app'
                  src:      '**/*.js'
                  dest:     '<%= dirs.build %>/assets/js/app'
                ]

            js_libs:
                files: [
                  expand:   true
                  cwd:      '<%= dirs.tmp %>/assets/js/libs'
                  src:      '**/*.js'
                  dest:     '<%= dirs.build %>/assets/js/libs'
                ]

        watch:
            index:
                files: [
                    '<%= dirs.src %>/jade/index.jade'
                    '<%= dirs.src %>/jade/mixins/**/*'
                    '<%= dirs.src %>/jade/includes/**/*'
                ]
                tasks: ['jade:index']
            jade:
                files: [
                    '<%= dirs.src %>/jade/partials/**/*'
                    '<%= dirs.src %>/jade/widgets/**/*'
                ]
                tasks: [
                    'jade:partials'
                    'jade:widgets'
                ]
            coffee:
                files: ['<%= dirs.src %>/scripts/**/*.coffee']
                tasks: ['coffee:dev']
            js:
                files: ['<%= dirs.src %>/scripts/**/*.js']
                tasks: [
                    'copy:js_libs_dev'
                ]
            sass:
                files: ['<%= dirs.src %>/styles/**/*']
                tasks: ['sass']
            options:
                spawn: false
                livereload: false

    grunt.registerTask 'default', [
        'build'
    ]

    grunt.registerTask 'run', [
        'default'
        'connect:dev'
        'watch'
    ]

    grunt.registerTask 'run:dev', [
        'run'
    ]

    grunt.registerTask 'run:prod', [
        'build:prod'
        'connect:prod'
        'watch'
    ]

    grunt.registerTask 'build', [
        'build:dev'
    ]

    grunt.registerTask 'build:dev', [
        'clean:build'
        'jade'
        'sass'
        'coffee:dev'
        'copy:static'
        'copy:js_libs_dev'
        'symlink:config'
        'banner'
    ]

    grunt.registerTask 'build:prod', [
        'clean:build'
        'jade'
        'sass'
        'coffee:prod'
        'copy:static'
        'copy:js_libs_prod'
        'uglify'
        'cssmin:prod'
        'clean:tmp'
        'cacheBust'
        'symlink:config'
    ]

    grunt.task.registerTask 'banner', 'prints the banner', ->
        grunt.log.write grunt.file.read('./banner.txt')
