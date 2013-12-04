(function() {
  var Analytics, accountID, addScript, debug, hasClass, init, internalTrafficDomains, isHTTP, isHTTPS, log, root, settings, siteName, track, trackHashChange, upon,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  siteName = window.location.siteName = window.location.siteName || function(url) {
    var hostName, hostNamePosFromEnd;
    hostName = url || window.location.hostname;
    hostName = hostName.replace(/^\w+?:\d*?\/\//, '');
    hostName = hostName.split('/')[0];
    hostName = hostName.split('.');
    hostNamePosFromEnd = hostName.length >= 2 ? (hostName[hostName.length - 2].length === 2 ? 3 : 2) : 1;
    while (hostName.length > hostNamePosFromEnd) {
      hostName.shift();
    }
    return hostName.join('.');
  };

  if (String.prototype.trim === void 0) {
    String.prototype.trim = function() {
      return this.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
    };
  }

  debug = true;

  log = function(msg) {
    if (debug) {
      if (window.console && window.console.log) {
        return window.console.log(msg);
      }
    }
  };

  track = function(item) {
    window._gaq.push(item);
    return log(item);
  };

  track.help = "Usage: track(['_trackEvent', category, action, opt_label, opt_value, opt_noninteraction])";

  isHTTPS = !!document.location.protocol.match('https:');

  isHTTP = !!document.location.protocol.match('http:');

  root = document.documentElement;

  hasClass = function(element, className) {
    return element.className && new RegExp("(^|\\s)" + className + "(\\s|$)").test(element.className);
  };

  upon = function(type, selector, func) {
    var del, sel, _i, _len, _results;
    if (selector === window) {
      del = [window];
    } else if (selector === document) {
      del = [document];
    } else {
      del = document.querySelectorAll(selector);
    }
    _results = [];
    for (_i = 0, _len = del.length; _i < _len; _i++) {
      sel = del[_i];
      if (sel.addEventListener) {
        _results.push(sel.addEventListener(type, function(e) {
          return func.call(e.target, e);
        }, false));
      } else if (del.attachEvent) {
        _results.push(sel.attachEvent('on' + type, function(e) {
          return func.call(e.target, e);
        }));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  trackHashChange = function(hash, func) {
    return window.addEventListener('hashchange', function(e) {
      if (location.hash === hash) {
        return func.call(e.target, e);
      }
    });
  };

  addScript = function(src, cb, async) {
    var s;
    root = document.documentElement;
    s = document.createElement('script');
    if (typeof cb === 'function') {
      upon('load', s, cb);
    }
    s.src = src;
    s.async = async === void 0 ? true : async;
    root.insertBefore(s, root.childNodes[0]);
    return s;
  };

  settings = {
    accountID: 'UA-28236326-1',
    natGeoDomains: ['nationalgeographicexpeditions.com', 'scienceblogs.com', 'buysub.com', 'ngtravelerseminars.com', 'greatenergychallengeblog.com', '360energydiet.com', 'nationalgeographic.org', 'nationalgeographic.com', 'ngstudentexpeditions.com', 'natgeotakeaction.org', 'customersvc.com', 'killinglincolnconspiracy.com'],
    trackFirstNSearchItems: 4,
    videoEvents: ['canplay', 'playing', 'pause', 'progress', 'ended'],
    videoDurationMilestones: [0, 25, 50, 75, 100],
    scrollMilestones: [30, 60, 90]
  };

  init = function(options) {
    var domain, fireEngagementAfterSec, hasStarted, idx, isTracked, key, lastPlaybackReportTime, lastReportedPlaybackPercent, pageHeight, playbackReportTimes, scrollY, trackAt, url, windowHeight, _i, _len, _ref, _ref1;
    for (key in options) {
      if (key === 'natGeoDomains') {
        _ref = options[key];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          domain = _ref[_i];
          if (_ref1 = !domain, __indexOf.call(settings[key], _ref1) >= 0) {
            settings[key].push(domain);
          }
        }
      } else {
        settings[key] = options[key];
      }
    }
    window._gaq = window._gaq || [];
    track(['_setAccount', settings.accountID]);
    track(['_setDomainName', siteName()]);
    track(['_setAllowLinker', true]);
    track(['_addIgnoredRef', 'nationalgeographic']);
    if (typeof onMMDBHeaderLoaded === "function") {
      onMMDBHeaderLoaded(function(context) {
        return context.isLoggedIn().done(function(authenticated) {
          var memberLevel, user, userToken;
          if (authenticated) {
            user = context.getUser();
            memberLevel = user.attributes.memberLevel;
            userToken = user.attributes.userHash;
            track(['_setCustomVar', 3, 'isLoged', 'true', 3]);
            track(['_setCustomVar', 8, 'userToken', userToken, 3]);
            track(['_setCustomVar', 9, 'memberLevel', memberLevel, 3]);
          } else {
            track(['_setCustomVar', 3, 'isLoged', 'false', 3]);
          }
          context.onUserLoggedIn(function() {
            return track(['_trackEvent', 'Membership', 'General', 'Sign In']);
          });
          return context.onUserLoggedOut(function() {
            return track(['_trackEvent', 'Membership', 'General', 'Log Out']);
          });
        });
      });
    }
    addScript("" + (isHTTPS ? "https://ssl" : "http://www") + ".google-analytics.com/ga.js");
    upon('click', "a[href*='//']:not([href*='" + (siteName()) + "'])", function(e) {
      var targetA, _ref2;
      targetA = e.target;
      if (_ref2 = siteName(targetA.href), __indexOf.call(settings.natGeoDomains, _ref2) >= 0) {
        return track(['_link', targetA.href]);
      } else {
        return track(['_trackEvent', 'engagement', 'outbound-click', targetA.title || siteName(targetA.href)]);
      }
    });
    lastReportedPlaybackPercent = -1;
    playbackReportTimes = settings.videoDurationMilestones;
    lastPlaybackReportTime = playbackReportTimes[playbackReportTimes.length - 1];
    hasStarted = false;
    scrollY = function() {
      return window.self.pageYOffset || (root && root.scrollTop) || document.body.scrollTop;
    };
    pageHeight = function() {
      return document.body.scrollHeight;
    };
    windowHeight = function() {
      return window.self.innerHeight || (root && root.clientHeight) || document.body.clientHeight;
    };
    trackAt = settings.scrollMilestones.slice();
    isTracked = (function() {
      var _j, _len1, _results;
      _results = [];
      for (_j = 0, _len1 = trackAt.length; _j < _len1; _j++) {
        idx = trackAt[_j];
        _results.push(false);
      }
      return _results;
    })();
    upon('scroll', window, function(e) {
      var distanceMark, engagement, page, percentScroll, pxScroll, search, trackScroll, url, _j, _len1, _results;
      percentScroll = (scrollY() + windowHeight()) / pageHeight();
      pxScroll = scrollY();
      page = window.location.pathname;
      search = window.location.search;
      url = page + search;
      trackScroll = function(engagement, mileMarker) {
        track(["_trackEvent", "engagement", "scrolled past " + mileMarker, url]);
        return isTracked[engagement] = true;
      };
      _results = [];
      for (distanceMark = _j = 0, _len1 = trackAt.length; _j < _len1; distanceMark = ++_j) {
        engagement = trackAt[distanceMark];
        if (!isTracked[distanceMark] && pxScroll > engagement) {
          _results.push(trackScroll(distanceMark, engagement));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    });
    fireEngagementAfterSec = 20;
    url = window.location.pathname + window.location.search;
    return window.setTimeout(function() {
      return track(["_trackEvent", "engagement", "Dwell time (more than " + fireEngagementAfterSec + " seconds)", url]);
    }, fireEngagementAfterSec * 1000);
  };

  accountID = function() {
    return settings.accountID;
  };

  internalTrafficDomains = function() {
    return settings.natGeoDomains;
  };

  Analytics = (function() {
    Analytics.prototype.track = track;

    Analytics.prototype.upon = upon;

    Analytics.prototype.internalTrafficDomains = internalTrafficDomains;

    Analytics.prototype.videoEvents = [].slice.call(settings.videoEvents);

    Analytics.prototype.trackHashChange = trackHashChange;

    function Analytics(options) {
      var _ref;
      if (options == null) {
        options = {};
      }
      this.name = (_ref = options.name) != null ? _ref : '';
      init(options);
      this.settings = settings;
    }

    return Analytics;

  })();

  window.Analytics = Analytics;

}).call(this);
