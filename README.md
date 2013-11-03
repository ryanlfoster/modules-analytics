modules-analytics
=================

Module for setting up Analytics on NGS projects

This will require [NodeJS](http://nodejs.org), [Grunt](http://gruntjs.com/getting-started) and [Bower](http://bower.io) for testing/build. 

# USAGE:
```javascript
require 'analytics', () ->
    options = {...}
    analytics.init(options)
```

## Options
----------
* accountID: String
..* Override the default GA accountID for reporting. The current value of accountID can be obtained with analytics.accountID
* natGeoDomains: Array
..*Add to the list of NatGeo domians that should be tracked as internal traffic. The current list of natGeoDomains can be obtained with analytics.internalTrafficDomains
* trackFirstNSearchItems: Number
..* A number representing the first N items to report a click event on for Google Analytics reporting.
* videoEvents: Array
..* An array of video events to track.