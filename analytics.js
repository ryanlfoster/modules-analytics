// Generated by CoffeeScript 1.6.3
var accountID, addScript, debug, init, internalTrafficDomains, isHTTP, isHTTPS, log, root, settings, siteName, track, upon,
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

debug = !!window.location.search.match('debug');

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

upon = function(type, selector, func) {
  var del, delegate;
  delegate = function(evt) {
    var el, els, _i, _len;
    if (selector.nodeName || selector === window || selector === document) {
      els = [selector];
    } else {
      els = document.querySelectorAll(selector);
    }
    for (_i = 0, _len = els.length; _i < _len; _i++) {
      el = els[_i];
      if (evt.currentTarget === el) {
        return func.call(evt.target, evt);
      }
    }
  };
  del = selector !== window ? document : window;
  if (del.addEventListener) {
    return del.addEventListener(type, function(e) {
      return delegate(e);
    }, false);
  } else if (del.attachEvent) {
    del.attachEvent('on' + type, function(e) {});
    return delegate(e);
  }
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
  var $body, domain, fireEngagementAfterSec, hasStarted, idx, isTracked, key, lastPlaybackReportTime, lastReportedPlaybackPercent, pageHeight, playbackReportTimes, scrollY, trackAt, url, windowHeight, _i, _len, _ref, _ref1;
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
  $body = document.querySelectorAll("body");
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
  $body.on('click', '.main-nav a, .global-nav a, .social-nav a, .main-nav button, .global-nav button, .social-nav button', function(e) {
    var $navType, $this, navType, trackText;
    $this = $(this);
    $navType = $this.parents('.main-nav, .global-nav, .social-nav').eq(0);
    navType = (function() {
      if ($navType.hasClass('social-nav')) {
        return 'main-nav';
      } else if ($navType.hasClass('.global-nav')) {
        return 'global-nav';
      } else {
        return 'main-nav';
      }
    })();
    trackText = $this.text().trim();
    if (trackText === '') {
      trackText = $this.attr('title');
    }
    if (trackText === '') {
      trackText = $this.attr('id');
    }
    return track(['_trackEvent', 'ngm-nav', navType, trackText]);
  });
  lastReportedPlaybackPercent = -1;
  playbackReportTimes = settings.videoDurationMilestones;
  lastPlaybackReportTime = playbackReportTimes[playbackReportTimes.length - 1];
  hasStarted = false;
  $body.on(settings.videoEvents.join(' '), 'video', function(e) {
    var currentTime, duration, label, percentViewed, time, trackAtTime, trackStart, type, videoTitle, _j, _len1, _results;
    trackAtTime = function(time) {
      track(['_trackEvent', 'video', 'Progress', "Video complete " + time + "%"]);
      return lastReportedPlaybackPercent = time;
    };
    trackStart = function() {
      track(['_trackEvent', 'video', 'Start', videoTitle]);
      return hasStarted = true;
    };
    if (e.type !== 'progress') {
      videoTitle = e.target.title;
      label = videoTitle;
      switch (e.type) {
        case e.type === 'playing':
          type = 'Play';
          break;
        case e.type === 'canplay':
          type = 'Ready';
          break;
        case e.type === 'ended':
          type = 'Complete';
          break;
        default:
          type = e.type;
      }
      track(['_trackEvent', 'video', type, label]);
      if (e.type === 'ended' && lastReportedPlaybackPercent > lastPlaybackReportTime) {
        trackAtTime(lastPlaybackReportTime);
      }
      if (e.type === 'play' && !hasStarted) {
        return trackStart();
      }
    } else {
      duration = e.target.duration;
      currentTime = e.target.currentTime;
      percentViewed = currentTime / duration * 100;
      _results = [];
      for (_j = 0, _len1 = playbackReportTimes.length; _j < _len1; _j++) {
        time = playbackReportTimes[_j];
        if (percentViewed >= time && lastReportedPlaybackPercent < time) {
          _results.push(trackAtTime(time));
        }
      }
      return _results;
    }
  });
  $body.on('click', '.social-media-buttons a', function(e) {
    var service;
    service = e.target.title;
    if (service === 'tweet') {
      service = 'twitter';
    }
    return track(['_trackEvent', 'social', 'outbound-click', service]);
  });
  $body.on('click', ".search_results:nth-child(-n+" + settings.trackFirstNSearchItems + ") a", function(e) {
    var itemNumber;
    itemNumber = $(this).index() + 1;
    return track(['_trackEvent', 'click', "Search-NGM_" + itemNumber]);
  });
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

window.Analytics = (function() {
  function Analytics(options) {
    this.name = options.name, this.accountID = options.accountID;
    init();
  }

  Analytics.prototype.accountID = accountID;

  Analytics.prototype.track = function() {
    return track(arguments[0].splice(1, "" + this.name + "." + arguments[0]));
  };

  Analytics.prototype.upon = upon;

  Analytics.prototype.internalTrafficDomains = internalTrafficDomains;

  Analytics.prototype.videoEvents = [].slice.call(settings.videoEvents);

  return Analytics;

})();

window.analytics = new Analytics({
  name: 'cory'
});
