/**
 * AdSense website ads (ca-pub-5325876102788151)
 *
 * Auto ads load from the head script once per page.
 * Fixed units use slots from LA_ADSENSE.slots (one slot per page max).
 *
 * Do not paste AdMob ca-app-pub unit IDs here.
 * Do not replace hosting/ads.txt (website AdSense) with app-ads.txt (AdMob).
 *
 * Positions:
 *   homeTop     → hosting/index.html [data-la-slot="homeTop"] (Display)
 *   homeBottom  → optional second Display unit (needs its own slot ID in AdSense)
 *   doc         → legal pages [data-la-slot="doc"] (Display)
 *   native      → hosting/index.html, between Features and Support
 *                 (needs an "In-article" ad unit created in AdSense — same
 *                 client, just a different ad-unit *type*; paste its slot ID)
 *   support     → hosting/index.html "Support us" reveal — loaded lazily,
 *                 only after the visitor clicks the button (needs its own
 *                 In-article ad unit; must NOT be the same slot as `native`,
 *                 AdSense forbids reusing one ad unit twice on one page)
 *   gamesBottom → hosting/games/dino/index.html, below the game
 *                 (needs its own In-article ad unit)
 */
window.LA_ADSENSE = {
  client: 'ca-pub-5325876102788151',
  slots: {
    homeTop: '3346149333',
    // Create a second Display ad unit in AdSense, paste its slot ID here:
    homeBottom: '',
    doc: '3346149333',
    // Create an "In-article" ad unit in AdSense for each of these three and
    // paste its slot ID — they must be three DIFFERENT ad units (AdSense
    // rejects reusing one ad unit's slot twice on the same page load):
    native: '',
    support: '',
    gamesBottom: ''
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

  // Shared across the initial page-load pass and any later lazy reveal(), so
  // an ad unit already placed at load time can't accidentally be re-pushed.
  var usedSlots = Object.create(null);

  function wireAndPush(el, key) {
    var slot = cfg.slots && cfg.slots[key];
    if (!slot) {
      hideBanner(el);
      return false;
    }
    // AdSense: do not place the same ad unit more than once on a single page.
    if (usedSlots[slot]) {
      hideBanner(el);
      return false;
    }
    usedSlots[slot] = true;

    el.setAttribute('data-ad-client', cfg.client);
    el.setAttribute('data-ad-slot', slot);
    el.setAttribute('data-ad-format', el.getAttribute('data-ad-format') || 'auto');
    el.setAttribute('data-full-width-responsive', 'true');

    watchFill(el);

    try {
      (window.adsbygoogle = window.adsbygoogle || []).push({});
      return true;
    } catch (e) {
      hideBanner(el);
      return false;
    }
  }

  function initAds() {
    var units = document.querySelectorAll('ins.adsbygoogle[data-la-slot]');
    units.forEach(function (el) {
      wireAndPush(el, el.getAttribute('data-la-slot'));
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAds);
  } else {
    initAds();
  }

  /**
   * Lazily creates and loads one In-article ad unit for `key` inside
   * `container`, replacing container's contents. Used by the "Support us"
   * reveal so that ad only loads once a visitor opts in, not on every
   * page view. Returns false (and leaves container empty) if no slot ID
   * is configured for `key` or the slot is already used on this page.
   */
  cfg.reveal = function (key, container) {
    if (!container) return false;
    var slot = cfg.slots && cfg.slots[key];
    if (!slot || usedSlots[slot]) return false;

    var el = document.createElement('ins');
    el.className = 'adsbygoogle';
    el.style.display = 'block';
    el.setAttribute('data-ad-layout', 'in-article');
    el.setAttribute('data-ad-format', 'fluid');
    container.innerHTML = '';
    container.appendChild(el);
    return wireAndPush(el, key);
  };
})();
