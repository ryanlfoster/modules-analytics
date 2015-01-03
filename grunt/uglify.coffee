module.exports =
    # clean up, minify and prepare for production use
    options:
        banner: '<%= banner %>'
    build:
        files:
            '<%= pkg.name %>.min.js': '<%= pkg.name %>.js'
