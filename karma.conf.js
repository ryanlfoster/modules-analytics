// Karma configuration
// Generated on Wed Dec 17 2014 08:39:13 GMT-0500 (EST)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['browserify', 'mocha', 'sinon', 'jquery-2.1.0'],

    plugins: [
        'karma-jquery',
        'karma-browserify',
        'karma-mocha',
        'karma-chai',
        'karma-sinon',
        'karma-coverage',
        'karma-mocha-reporter',
        'karma-phantomjs-launcher'
    ],

    // list of files / patterns to load in the browser
    files: [
        'index.js',
        // {pattern: 'lib/**/*.js', included: false},
        {pattern: 'spec/**/test-*.js', included: false}
    ],

    // list of files to exclude
    exclude: [
    ],

    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
        'index.js': [ 'browserify' ],
        'spec/**/*.js': [ 'browserify' ],
    },

    // https://github.com/Nikku/karma-browserify
    browserify: {
        debug: true,
        transform: [ 'brfs', 'browserify-istanbul' ]
    },

    // test results reporter to use
    // possible values: 'dots', 'progress', 'mocha', 'coverage'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['mocha', 'coverage'],

    // reporter options - full, autowatch, minimal
    mochaReporter: {
        output: 'full'
    },

    // coverage reporter
    coverageReporter: {
        type : 'text'
    },

    // web server port
    port: 9876,

    // enable / disable colors in the output (reporters and logs)
    colors: true,

    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: false,

    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['PhantomJS'],

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false
  });
};
