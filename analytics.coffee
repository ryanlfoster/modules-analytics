############
#
# USAGE:
# require 'analytics', () ->
#    options = {...}
#    analytics.init(options)
#
# options
#----------
#   accountID: String    // Override the default GA accountID for reporting. The current value of accountID can be
#                        // obtained with analytics.accountID
#
#   natGeoDomains: Array // Add to the list of NatGeo domians that should be tracked as internal traffic.
#                        // The current list of natGeoDomains can be obtained with analytics.internalTrafficDomains
#
#   trackFirstNSearchItems: Number // A number representing the first N items to report a click event on for Google
#                                  // Analytics reporting.
#
#   videoEvents: Array  // An array of video events to track.
#
############

define ['jquery'], ($) ->

    ############
    #
    # window.location.siteName reduces either the documents url if no
    # parameters are passed or a given url to the top most site name.
    # i.e. ngm.nataionalgeographic.com would return nationalgeographic.com,
    # mysubdomain.mywebsite.co.uk would return mywebsite.co.uk.
    #
    ############
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

    if String.prototype.trim is undefined
       String.prototype.trim = () ->
           return this.replace(/^\s\s*/, '').replace /\s\s*$/, ''

    debug = !!window.location.search.match 'debug'
    log = (msg) ->
        if debug
            if window.console && window.console.log
                window.console.log msg
    track = (item) ->
        window._gaq.push item
        log item

    track.help = "Usage: track(['_trackEvent', category, action, opt_label, opt_value, opt_noninteraction])"

    # Utilities
    isHTTPS = !!document.location.protocol.match 'https:'
    isHTTP = !!document.location.protocol.match 'http:'
    root = document.documentElement

    upon = (type, el, func) ->
        if el.addEventListener
            el.addEventListener type, func, false
        else if el.attachEvent
            el.attachEvent 'on' + type, func
        else
            if typeof el['on' + type] is 'function'
                oldOn = el['on' + type]
                onContainer = (oldOn, newOn) ->
                    if typeof oldOn is 'function'
                        oldOn()
                    newOn()
                el['on' + type] = onContainer
            else
                el['on' + type] = func
        return el

    addScript = (src, cb, async) ->
        root = document.documentElement
        s = document.createElement 'script'
        if typeof cb is 'function'
            upon 'load', s, cb
        s.src = src
        s.async = if async is undefined then true else async;
        root.insertBefore s, root.childNodes[0]
        return s

    ######
    #   TODO: Confirm that comscore is still required.
    ######
    csScript = do () ->
        window._comscore = window._comscore or []
        window._comscore.push c1: "2", c2: "3005368"
        addScript "#{if isHTTPS then 'https://s' else 'http://'}b.scorecardresearch.com/beacon.js?"

    # Gigya Google Analytics integration
    gigyaIntScript = addScript "#{ if isHTTPS then 'https://cdns' else 'http://cdn'}.gigya.com/js/gigyaGAIntegration.js"


    ######
    #   TODO: Confirm that quantserve is still required.
    ######
    qcScript = do () ->
        #only loads for http
        if isHTTP
            qs = addScript 'http://edge.quantserve.com/quant.js'
            upon 'load', qs, () ->
                if typeof window.quantserve is 'function'
                   window._qacct = "p-c8v-iKfiW8tsY"
                   window.quantserve()
            return qs;


    ######
    #   TODO: Confirm that SiteCensus is still required.
    ######
    # Nielsen Online SiteCensus V6.0 | COPYRIGHT 2010 Nielsen Online
    nielsen = do () ->
        d = new Image 1, 1
        d.onerror = d.onload = () ->
            d.onerror = d.onload = null
        d.src = "#{ document.location.protocol }//secure-us.imrworldwide.com/cgi-bin/m?ci=us-301776h&cg=0&cc=1&si=#{ window.escape window.location.href}&rp=#{ window.escape document.referrer }&ts=compact&rnd=#{(new Date()).getTime()}"
        return d

    settings =
        accountID: 'UA-28236326-1'

        ######
        #   A hardcoded list of NatGeo domains hardly seems like the best way to go here.
        #   Still, the list can be
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

    init = (options) ->

        # Extend settings
        for key of options

            ######
            #   For natGeoDomanins, extend rather than overwrite the Array.
            ######
            if key is 'natGeoDomains'
                for domain in options[key]
                    if not $.inArray domain settings[key]
                        settings[key].push domain
            else
                settings[key] = options[key]

        # Google Analytics Custom Implimentation
        window._gaq = window._gaq or []
        track ['_setAccount', settings.accountID]
        track ['_setDomainName', siteName()]
        track ['_setAllowLinker', true]
        track ['_addIgnoredRef', 'nationalgeographic']

        $body = $('body')


        ##################
        # Membership status
        ##################
        onMMDBHeaderLoaded? (context) ->
            context.isLoggedIn().done (authenticated) ->
                if authenticated

                    user = context.getUser()
                    memberLevel = user.attributes.memberLevel
                    userToken = user.attributes.userHash

                    track ['_setCustomVar', 3, 'isLoged', 'true', 3]
                    track ['_setCustomVar', 8, 'userToken', userToken, 3]
                    track ['_setCustomVar', 9, 'memberLevel', memberLevel, 3]
                else
                    track ['_setCustomVar', 3, 'isLoged', 'false', 3]

                # Login/out events
                ##################

                context.onUserLoggedIn () ->
                    track ['_trackEvent', 'Membership', 'General', 'Sign In']

                context.onUserLoggedOut () ->
                    track ['_trackEvent', 'Membership', 'General', 'Log Out']

        ##################
        # Load the GA script now so that setup items like _setAccount, etc. are in the queue
        # and so membership event listeners are in place. Ideally these would be in the pre-_trackPageview
        # queue, but it's all asnyc, so w'll smoke 'em if we've got 'em. Otherwise we'll wait till it fires.
        ##################
        # track ['_trackPageview']
        addScript "#{if isHTTPS then "https://ssl" else "http://www"}.google-analytics.com/ga.js"



        ##################
        # Log Link clicks
        ##################
        $body.on 'click', "a[href*='//']:not([href*='#{ siteName() }'])", (e) ->
            targetA = this;

            # NatGeo TLDs
            if $.inArray siteName(targetA.href), settings.natGeoDomains >= 0
                track ['_link', targetA.href]
            # Third Party TLDs
            else
                track ['_trackEvent', 'engagement', 'outbound-click', targetA.title or siteName(targetA.href) ]

        ###################
        # Log Nav clicks
        #
        # (most) Nav Clicks will be reported as
        # a standard link click and a nav click.
        ##################
        $body.on 'click', '.main-nav a, .global-nav a, .social-nav a, .main-nav button, .global-nav button, .social-nav button', (e) ->

            $this = $(this)
            $navType = $this.parents('.main-nav, .global-nav, .social-nav').eq(0)

            # Determin which nav was clicked on
            navType = do () ->
                if $navType.hasClass 'social-nav'
                    'main-nav'
                else if $navType.hasClass '.global-nav'
                    'global-nav'
                else
                    'main-nav'

            # Determin which text to report with
            trackText = $this.text().trim()
            trackText = $this.attr('title') if trackText is ''
            trackText = $this.attr('id') if trackText is ''

            ######
            #   TODO:
            #   Confirm reporting structure with Mia
            #   https://docs.google.com/a/ngs.org/spreadsheet/ccc?key=0At8KEiOsNIXUdHd1M2J2Zy1NM2xoeDJ3dXBmdHBMRWc#gid=7
            ######

            track ['_trackEvent', 'ngm-nav', navType, trackText]

        #################
        # Video Events
        # Requirements for video event tracking can be found here:
        # https://docs.google.com/a/ngs.org/spreadsheet/ccc?key=0At8KEiOsNIXUdHd1M2J2Zy1NM2xoeDJ3dXBmdHBMRWc#gid=7
        #################

        lastReportedPlaybackPercent = -1

        # Granularity of when progress is reported can be adjusted here.
        playbackReportTimes = [0, 25, 50, 75, 100]
        lastPlaybackReportTime = playbackReportTimes[playbackReportTimes.length - 1]
        hasStarted = false

        # Native video implemntation
        $body.on settings.videoEvents.join(' '), 'video', (e) ->
            trackAtTime = (time) ->
                track ['_trackEvent', 'video', 'Progress', "Video complete #{time}%"]
                lastReportedPlaybackPercent = time

            trackStart = () ->
                track ['_trackEvent', 'video', 'Start', videoTitle]
                hasStarted = true;

            if e.type isnt 'progress'

                # videoDuration = this
                videoTitle = e.target.title

                label = videoTitle

                switch e.type
                    when e.type is 'playing' then type = 'Play'
                    when e.type is 'canplay' then type = 'Ready'
                    when e.type is 'ended'   then type = 'Complete'
                    else type = e.type

                track ['_trackEvent', 'video', type, label]

                # Captures the 100% senario that may not be captured by duration event.
                trackAtTime lastPlaybackReportTime if e.type is 'ended' and lastReportedPlaybackPercent > lastPlaybackReportTime


                trackStart() if e.type is 'play' and not hasStarted

            else
                duration = e.target.duration
                currentTime = e.target.currentTime
                percentViewed = currentTime / duration * 100

                trackAtTime time for time in playbackReportTimes when percentViewed >= time and lastReportedPlaybackPercent < time

        ###################
        # Social Engagement
        ###################
        $body.on 'click', '.social-media-buttons a', (e) ->
            service = e.target.title
            service = 'twitter' if service is 'tweet'
            track ['_trackEvent', 'social', 'outbound-click', service]


        ###################
        # Search Reporting
        ###################
        $body.on 'click', ".search_results:nth-child(-n+#{settings.trackFirstNSearchItems}) a", (e) ->
            itemNumber = $(this).index() + 1
            track ['_trackEvent', 'click', "Search-NGM_#{itemNumber}"]

        ###################
        # Scroll Tracking
        ###################
        scrollY = () ->
            window.self.pageYOffset or (root and root.scrollTop) or document.body.scrollTop

        pageHeight = () ->
            document.body.scrollHeight

        windowHeight = () ->
            window.self.innerHeight or (root and root.clientHeight) or document.body.clientHeight

        trackAt =
            engagementA : 0.3
            engagementB : 0.6
            engagementC : 0.9

        isTracked =
            engagementA : false
            engagementB : false
            engagementC : false

        upon 'scroll', window, () ->

            percentScroll = (scrollY() + windowHeight())/pageHeight()
            pxScroll      = scrollY()
            page          = window.location.pathname
            search        = window.location.search
            url           = page + search

            trackScroll = (engagement, mileMarker) ->
                track ['_trackEvent', 'engagement', "scrolled past #{mileMarker * 100}", url]
                isTracked[engagement] = true

            for engagement, distanceMark of trackAt
                if not isTracked[engagement] and pxScroll > distanceMark
                    trackScroll engagement, distanceMark

        ###################
        # Bounce modification
        ###################
        fireEngagementAfterSec = 20;
        url = window.location.pathname + window.location.search
        window.setTimeout () ->
            track ['_trackEvent', 'engagement', 'Dwell time (more than ' + fireEngagementAfterSec + ' seconds)', url]
        , fireEngagementAfterSec * 1000

    accountID = () ->
        return settings.accountID

    internalTrafficDomains = () ->
        return settings.natGeoDomains

    ######
    #   The analytics API.
    #   Here be public methods.
    ######
    window.analytics = analytics =
        accountID: accountID # Returns what accountID is being used.
        track: track
        init: init
        internalTrafficDomains: internalTrafficDomains
        videoEvents: settings.videoEvents

    #run analytics.init(settings) to begin tracking
    return analytics
