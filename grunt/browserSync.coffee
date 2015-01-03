module.exports =
    serve:
        options:
            host: "dev.nationalgeographic.com"
            open: "external"
            port: 9000
            server:
                baseDir: "./"
            watchTask: true
        bsFiles:
            src: [
                "./index.html"
                "./*.js"
            ]
