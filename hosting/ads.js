/**
 * AdSense website Display ads (ca-pub-5325876102788151)
 *
 * Auto ads load from the head script once per page.
 * Fixed banners use Display slots from LA_ADSENSE.slots (one slot per page max).
 *
 * Do not paste AdMob ca-app-pub unit IDs here.
 * Do not replace hosting/ads.txt (website AdSense) with app-ads.txt (AdMob).
 *
 * Positions:
 *   homeTop    → hosting/index.html [data-la-slot="homeTop"]
 *   homeBottom → optional second unit (needs its own slot ID in AdSense)
 *   doc        → legal pages [data-la-slot="doc"]
 */
window.LA_ADSENSE = {
  client: 'ca-pub-5325876102788151',
  slots: {
    homeTop: '3346149333',
    // Create a second Display ad unit in AdSense, paste its slot ID here:
    homeBottom: '',
    doc: '3346149333'
  }
};

(function () {
  var cfg = window.LA_ADSENSE;
  if (!cfg || !cfg.client) return;

  function hideBanner(el) {
    var banner = el.closest('.ad-banner');
    if (banner) {
      banner.classList.remove('ad-banner--filled', 'ad-banner--pending');
      banner.classList.add('ad-banner--empty');
    }
  }

  function showBanner(el) {
    var banner = el.closest('.ad-banner');
    if (banner) {
      banner.classList.remove('ad-banner--empty', 'ad-banner--pending');
      banner.classList.add('ad-banner--filled');
    }
  }

  function watchFill(el) {
    function applyStatus() {
      var status = el.getAttribute('data-ad-status');
      if (status === 'unfilled') {
        hideBanner(el);
        return true;
      }
      if (status === 'filled') {
        showBanner(el);
        return true;
      }
      return false;
    }

    if (applyStatus()) return;

    var observer = new MutationObserver(function () {
      if (applyStatus()) observer.disconnect();
    });
    observer.observe(el, {
      attributes: true,
      attributeFilter: ['data-ad-status', 'data-adsbygoogle-status']
    });

    window.setTimeout(function () {
      observer.disconnect();
      applyStatus();
    }, 10000);
  }

  function initAds() {
    var usedSlots = Object.create(null);
    var units = document.querySelectorAll('ins.adsbygoogle[data-la-slot]');

    units.forEach(function (el) {
      var key = el.getAttribute('data-la-slot');
      var slot = cfg.slots && cfg.slots[key];
      if (!slot) {
        hideBanner(el);
        return;
      }
      // AdSense: do not place the same ad unit more than once on a single page.
      if (usedSlots[slot]) {
        hideBanner(el);
        return;
      }
      usedSlots[slot] = true;

      el.setAttribute('data-ad-client', cfg.client);
      el.setAttribute('data-ad-slot', slot);
      el.setAttribute('data-ad-format', el.getAttribute('data-ad-format') || 'auto');
      el.setAttribute('data-full-width-responsive', 'true');

      watchFill(el);

      try {
        (window.adsbygoogle = window.adsbygoogle || []).push({});
      } catch (e) {
        hideBanner(el);
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAds);
  } else {
    initAds();
  }
})();
