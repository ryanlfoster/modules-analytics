############
#
# USAGE:
# require 'analytics', () ->
#    options = {...}
#    window.analytics = new Analytics(options)
#
# options
#----------
#   accountID: String    // Override the default GA accountID for reporting.
#                        // The current value of accountID can be
#                        // obtained with analytics.accountID
#
#   version: String      // Can be classic, universal or both
#                        // Used to set the support level for GA versions
#
#   natGeoDomains: Array // Add to the list of NatGeo domians that should be
#                        // tracked as internal traffic.
#                        // The current list of natGeoDomains can be obtained
#                        // with analytics.internalTrafficDomains
#
#   trackFirstNSearchItems: Number // A number representing the first N items
#                                  // to report a click event on for Google
#                                  // Analytics reporting.
#
#   videoEvents: Array  // An array of video events to track.
#
############

############
#
# window.location.siteName reduces either the documents url if no
# parameters are passed or a given url to the top most site name.
# i.e. ngm.nataionalgeographic.com would return nationalgeographic.com,
# mysubdomain.mywebsite.co.uk would return mywebsite.co.uk.
#
############

settings =
    accountID: 'UA-28236326-1'
    version: 'classic'

    ######
    #   A hardcoded list of NatGeo domains hardly seems like
    #   the best way to go here.
    ######
    natGeoDomains: [ # to track inter-society vs outer-society links correctly
        'nationalgeographicexpeditions.com'
        'scienceblogs.com'
        'buysub.com'
        'ngtravelerseminars.com'
        'greatenergychallengeblog.com'
        '360energydiet.com'
        'nationalgeographic.org'
        'nationalgeographic.com'
        'ngstudentexpeditions.com'
        'natgeotakeaction.org'
        'customersvc.com'
        'killinglincolnconspiracy.com'
    ]
    trackFirstNSearchItems: 4
    videoEvents: ['canplay', 'playing', 'pause', 'progress', 'ended']

    # Granularity of when progress is reported can be adjusted here.
    videoDurationMilestones: [0, 25, 50, 75, 100]
    scrollMilestones: [30, 60, 90]

# Utilities
isClassic = version is 'classic'
isHTTPS = !!document.location.protocol.match 'https:'
isHTTP = !!document.location.protocol.match 'http:'
root = document.documentElement
siteName = window.location.siteName = window.location.siteName or (url) ->
    hostName = url or window.location.hostname

    # Don't want any http:// or similar stuff.
    hostName = hostName.replace /^\w+?:\d*?\/\//, ''

    # Drop any path info from url.
    hostName = hostName.split('/')[0]
    hostName = hostName.split('.')
    hostNamePosFromEnd = if hostName.length >= 2 then ( if hostName[hostName.length - 2].length is 2 then 3 else 2) else 1
    hostName.shift() while hostName.length > hostNamePosFromEnd
    return hostName.join '.'

debug = !!window.location.search.match 'debug'

log = (msg) ->
    if debug
        if window.console && window.console.log
            window.console.log msg

track = (item) ->
    if isClassic
        window._gaq.push item
        log item
        return

    window.ga item
    log item

# track.help = "Usage: track(['_trackEvent', category, action, opt_label, opt_value, opt_noninteraction])"

hasClass = (element, className) ->
    return element.className && new RegExp("(^|\\s)" + className + "(\\s|$)").test element.className

upon = (type, selector, func) ->
    if selector is window
        del = [window]
    else if selector is document
        del = [document]
    else
        try
            del = document.querySelectorAll selector
        catch e
            del = ''

    for sel in del
        if sel.addEventListener
            sel.addEventListener type, (e) ->
                func.call(e.target, e)
            , false
        else if del.attachEvent
            sel.attachEvent 'on' + type, (e) ->
                func.call(e.target, e)

trackHashChange = (hash, func) ->
    if window.addEventListener
        window.addEventListener 'hashchange', (e) ->
            if location.hash is hash
                func.call(e.target, e)
    else if window.attachEvent
        window.attachEvent 'on' + type, (e) ->
            if location.hash is hash
                func.call(e.target, e)

addScript = (src, cb, async) ->
    root = document.documentElement
    s = document.createElement 'script'
    if typeof cb is 'function'
        upon 'load', s, cb
    s.src = src
    s.async = if async is undefined then true else async
    root.insertBefore s, root.childNodes[0]
    return s

init = (options) ->

    # Extend settings
    for key of options

        ######
        #   For natGeoDomanins, extend rather than overwrite the Array.
        ######
        if key is 'natGeoDomains'
            for domain in options[key]
                if not domain in settings[key]
                    settings[key].push domain
        else
            settings[key] = options[key]

    # Google Analytics Custom Implimentation
    if isClassic
        window._gaq = window._gaq or []
        track ['_setAccount', settings.accountID]
        track ['_setDomainName', siteName()]
        track ['_setAllowLinker', true]
        track ['_addIgnoredRef', 'nationalgeographic']
    else
        window.ga = window.ga or []
        window.ga 'create', settings.accoundID


    ##################
    # Membership status
    ##################
    onMMDBHeaderLoaded? (context) ->
        context.isLoggedIn().done (authenticated) ->
            if authenticated
                user = context.getUser()
                memberLevel = user.attributes.memberLevel
                userToken = user.attributes.userHash
                # https://developers.google.com/analytics/devguides/collection/upgrade/reference/gajs-analyticsjs#custom-vars
                # custom vars in Universal are now done in Admin and referrenced here as dimensions
                # e.g., ga('set', 'dimension1', 'isLoged');
                # therefore are not an option here yet
                if isClassic
                    track ['_setCustomVar', 3, 'isLoged', 'true', 3]
                    track ['_setCustomVar', 8, 'userToken', userToken, 3]
                    track ['_setCustomVar', 9, 'memberLevel', memberLevel, 3]
            else
                if isClassic then track ['_setCustomVar', 3, 'isLoged', 'false', 3]

            # Login/out events
            ##################
            memVars = [ 'Membership', 'General' ].join ','
            context.onUserLoggedIn () ->
                if isClassic
                    track ['_trackEvent', memVars, 'Sign In']
                else
                    track 'send', 'event', memVars, 'Sign In'

            context.onUserLoggedOut () ->
                if isClassic
                    track ['_trackEvent', memVars, 'Log Out']
                else
                    track 'send', 'event', memVars, 'Log Out'

    #adding Enhanced Link Attribution
    pluginUrl = "//www.google-analytics.com/plugins/ga/inpage_linkid.js"
    if isClassic
        window._gaq.push [
          "_require"
          "inpage_linkid"
          pluginUrl
        ]
    else
        ga 'require', 'inpage_linkid', 'inpage_linkid.js'

    ##################
    # Load the GA script now so that setup items like _setAccount, etc. are in the queue
    # and so membership event listeners are in place. Ideally these would be in the pre-_trackPageview
    # queue, but it's all asnyc. Otherwise we'll wait till it fires.
    ##################
    if isClassic and (typeof window._gaq is "undefined" and window._gaq is null)
        addScript "#{if isHTTPS then "https://ssl" else "http://www"}.google-analytics.com/ga.js"

    ##################
    # Log Link clicks
    ##################
    upon 'click', "a[href*='//']:not([href*='#{ siteName() }'])", (e) ->
        targetA = e.target

        # NatGeo TLDs
        if siteName(targetA.href) in settings.natGeoDomains
            track ['_link', targetA.href]
        # Third Party TLDs
        else
            link = targetA.title or siteName(targetA.href)
            if isClassic
                track ['_trackEvent', 'engagement', 'outbound-click', link ]
            else
                track 'send', 'event', 'engagement', 'outboard-click', link

    #################
    # Video Events
    # Requirements for video event tracking can be found here:
    # https://docs.google.com/a/ngs.org/spreadsheet/ccc?key=0At8KEiOsNIXUdHd1M2J2Zy1NM2xoeDJ3dXBmdHBMRWc#gid=7
    #################

    lastReportedPlaybackPercent = -1

    playbackReportTimes = settings.videoDurationMilestones
    lastPlaybackReportTime = playbackReportTimes[playbackReportTimes.length - 1]
    hasStarted = false


accountID = () ->
    return settings.accountID

internalTrafficDomains = () ->
    return settings.natGeoDomains

######
#   The analytics API.
#   Here be public methods.
######
class Analytics
    track: track
    upon: upon
    internalTrafficDomains: internalTrafficDomains
    videoEvents: [].slice.call settings.videoEvents
    trackHashChange: trackHashChange

    constructor: (options = {}) ->
        @name = options.name ? ''
        init(options)
        @settings = settings

window.Analytics = Analytics
