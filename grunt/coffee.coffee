module.exports =
    # so we can compile the files into
    # something readable on the interwebs.
    compile:
        files:
            '<%= pkg.name %>.js': './src/analytics.coffee'
