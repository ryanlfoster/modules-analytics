module.exports =
    # lint our files to make sure we're keeping to team standards
    files:
        src: ['./{,*/}*.coffee']
    options:
        configFile: 'coffeelint.json'
