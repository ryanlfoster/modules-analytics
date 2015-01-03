module.exports =
    options:
        banner: '<%= banner %>'

    dev:
        files:
            './build/video.js': 'index.js'

        options:
            browserifyOptions:
                debug: true
                standalone: 'ngsPlayer'

    dist:
        files:
            './build/video.js': 'index.js'

        options:
            browserifyOptions:
                debug: false
                standalone: 'ngsPlayer'
