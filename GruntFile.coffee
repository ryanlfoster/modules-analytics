'use strict'
module.exports = (grunt) ->
    # determine time to complete tasks
    require('time-grunt') grunt
    # load all grunt tasks using load-grunt-config
    # this assumes grunt-contrib-watch, grunt-contrib-coffee,
    # grunt-coffeelint, grunt-contrib-clean,
    # grunt-contrib-uglify are in the package.json file
    require('load-grunt-config') grunt,
        init: true #auto grunt.initConfig
        config:
            # load in the module information
            pkg: grunt.file.readJSON 'package.json'
            # path to Grunt file for exclusion
            gruntfile: 'Gruntfile.coffee'
            # generalize the module information for banner output
            banner: '/**\n' +
                    ' * NGS Module: <%= pkg.name %> - v<%= pkg.version %>\n' +
                    ' * Description: <%= pkg.description %>\n' +
                    ' * Date Built: <%= grunt.template.today("yyyy-mm-dd") %>\n' +
                    ' * Copyright (c) <%= grunt.template.today("yyyy") %>' +
                    '  | <%= pkg.author.name %>;\n' +
                    '**/\n'
