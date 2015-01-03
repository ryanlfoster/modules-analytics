module.exports =
    # basic watch tasks first for development
    coffee:
        files: [
            '*.coffee'
        ]
        tasks: 'coffee:compile'
        options:
            livereload: true
