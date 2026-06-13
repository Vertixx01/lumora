import 'dart:convert';

String buildInjectionScript(
  Map<String, dynamic> config,
  Map<String, dynamic> settings,
) {
  // Build a CSS sheet for static hides
  final List<String> cssRules = [];

  // Hide App Prompts and Banners
  cssRules.add('''
    a[href*="play.google.com/store/apps"],
    a[href*="apps.apple.com"],
    a[href*="instagram://"],
    div[class*="AppBanner"],
    div[class*="app-banner"],
    div[class*="AppPromo"],
    div[class*="app-promo"] {
      display: none !important;
    }
  ''');

  final String staticCss = cssRules.join('\n');

  return '''
(function () {
  window.__lumoraConfig = ${jsonEncode(config)};
  window.__lumoraSettings = ${jsonEncode(settings)};
  window.__lumoraStaticCss = `$staticCss`;

  if (window.__lumoraInjected) {
    if (typeof window.__lumoraRefresh === 'function') {
      window.__lumoraRefresh();
    }
    return true;
  }

  window.__lumoraInjected = true;

  let config = window.__lumoraConfig;
  let settings = window.__lumoraSettings;
  if (!config) config = {};
  if (!config.selectors) config.selectors = {};
  if (!config.labelMap) config.labelMap = {};

  const send = (msg) => {
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('bridge', msg);
    }
  };

  // Inject Static CSS Hides to avoid FOUC (Flash of Unstyled Content)
  const style = document.createElement('style');
  style.id = 'lumora-injected-styles';
  style.innerHTML = window.__lumoraStaticCss || '';
  const parent = document.head || document.documentElement;
  if (parent) {
    parent.appendChild(style);
  }

  function hideElement(el, reason) {
    if (!el) return;
    const tag = (el.tagName || '').toLowerCase();
    if (tag === 'html' || tag === 'body' || tag === 'main') return;

    el.setAttribute('data-lumora-hidden', reason || 'true');
    el.style.setProperty('display', 'none', 'important');
  }

  function closestArticle(el) {
    if (!el) return null;
    return el.matches && el.matches('article, [role="article"]')
      ? el
      : el.closest && el.closest('article, [role="article"]');
  }

  function isInsideArticle(el) {
    return !!closestArticle(el);
  }

  function hasPostPermalink(el) {
    if (!el) return false;
    const selector = 'a[href*="/p/"], a[href*="/reel/"], a[href*="/reels/"]';
    if (el.matches && el.matches(selector)) return true;
    return !!(el.querySelector && el.querySelector(selector));
  }

  function isUnsafePostContainer(el) {
    if (!el) return true;
    return !!el.closest('nav, header, footer, aside, [role="dialog"]');
  }

  function postCandidateFor(el) {
    if (!el || !el.closest) return null;

    const article = closestArticle(el);
    if (article) return article;

    if (isUnsafePostContainer(el) || !hasPostPermalink(el)) return null;

    let node = el;
    let depth = 0;
    while (node && depth < 7) {
      const tag = (node.tagName || '').toLowerCase();
      if (tag === 'html' || tag === 'body' || tag === 'main') break;

      if (hasPostPermalink(node) && node.querySelector && node.querySelector('img, video')) {
        return node;
      }

      node = node.parentElement;
      depth++;
    }

    return el.matches && el.matches('a[href*="/p/"], a[href*="/reel/"], a[href*="/reels/"]')
      ? el
      : null;
  }

  function isPostArticle(el) {
    if (!el || !el.matches) return false;
    if (isUnsafePostContainer(el)) return false;

    const isArticle = el.matches('article, [role="article"]');

    if (isArticle) {
      const nestedArticle = el.querySelector('article, [role="article"]');
      if (nestedArticle) return false;
    }

    const hasPostLink = hasPostPermalink(el);
    const hasPostMedia = !!el.querySelector('img, video');
    const hasPostTime = !!el.querySelector('time');

    if (isArticle) return hasPostLink || hasPostMedia || hasPostTime;

    return hasPostLink && hasPostMedia;
  }

  function postSelector() {
    const configured = Array.isArray(config.selectors.postItem)
      ? config.selectors.postItem
      : [];
    const safe = configured.filter((sel) => {
      const value = String(sel || '').trim().toLowerCase();
      return value === 'article' || value === '[role="article"]';
    });

    return safe.length > 0 ? safe.join(',') : 'article, [role="article"]';
  }

  function postCandidateSelector() {
    return postSelector() + ',a[href*="/p/"],a[href*="/reel/"],a[href*="/reels/"]';
  }

  function resetLumoraHidden() {
    document.querySelectorAll('[data-lumora-hidden]').forEach((el) => {
      el.style.removeProperty('display');
      el.removeAttribute('data-lumora-hidden');
    });
  }

  window.__lumoraRefresh = function () {
    config = window.__lumoraConfig || {};
    settings = window.__lumoraSettings || {};
    if (!config.selectors) config.selectors = {};
    if (!config.labelMap) config.labelMap = {};

    const existingStyle = document.getElementById('lumora-injected-styles');
    if (existingStyle) {
      existingStyle.innerHTML = window.__lumoraStaticCss || '';
    }

    resetLumoraHidden();
    if (typeof window.__lumoraTick === 'function') {
      window.__lumoraTick();
    }
  };

  // Text-based element matching helper
  function containsAnyText(el, textList) {
    if (!el || !textList) return false;
    const txt = el.textContent || '';
    return textList.some(t => txt.includes(t));
  }

  function hasLabelMatch(root, labels) {
    if (!root || !labels || labels.length === 0) return false;
    const normalizedLabels = labels
      .filter(Boolean)
      .map(label => String(label).trim().toLowerCase());

    const nodes = root.querySelectorAll('span, div, a, button, p');
    for (const node of nodes) {
      const text = (node.textContent || '').replace(/\\s+/g, ' ').trim().toLowerCase();
      if (!text || text.length > 80) continue;

      for (const label of normalizedLabels) {
        if (!label) continue;
        if (label.length <= 3 && text === label) return true;
        if (label.length > 3 && (text === label || text.includes(label))) return true;
      }
    }

    return false;
  }

  function isSponsoredArticle(article) {
    if (!article) return false;

    const sponsoredLabels = (config.labelMap && config.labelMap.sponsored) || [
      'Ad',
      'Sponsored',
      'Paid partnership'
    ];

    if (hasLabelMatch(article, sponsoredLabels)) return true;

    const header = article.querySelector('header') || article.firstElementChild || article;
    if (hasLabelMatch(header, ['Ad', 'Sponsored', 'Paid partnership'])) return true;

    const text = (article.textContent || '').replace(/\\s+/g, ' ').trim();
    return /(?:^|\\s)(Sponsored|Paid partnership)(?:\\s|\$)/.test(text);
  }

  function hideCategory(cat) {
    if (!config || !config.selectors) return;
    const list = config.selectors[cat] || [];
    list.forEach((sel) => {
      try {
        document.querySelectorAll(sel).forEach((el) => {
          hideElement(el, cat);
        });
      } catch (_) {}
    });
  }

  function hidePostCategory(cat, predicate) {
    const categorySelectors = Array.isArray(config.selectors[cat])
      ? config.selectors[cat]
      : [];
    const selectors = categorySelectors.length > 0
      ? categorySelectors
      : [postSelector()];
    const seen = new Set();

    selectors.forEach((sel) => {
      try {
        document.querySelectorAll(sel).forEach((el) => {
          const article = closestArticle(el);
          if (!article || seen.has(article)) return;
          seen.add(article);
          if (!isPostArticle(article)) return;
          if (predicate(article)) {
            hideElement(article, cat);
          }
        });
      } catch (_) {}
    });
  }

  function applyDynamicHiding() {
    // Hide suggested posts using text contains fallback if needed
    if (settings.hideSuggested) {
      hidePostCategory('suggestedPosts', (art) => {
        const suggestedLabels = (config.labelMap && config.labelMap.suggested) || [];
        return containsAnyText(art, suggestedLabels);
      });
    }

    // Hide sponsored posts
    if (settings.hideSponsored) {
      hidePostCategory('sponsoredPosts', isSponsoredArticle);
    }

    // Hide navigation entry points without touching feed post media links.
    hideBottomNavItems();
  }

  function hideBottomNavItems() {
    // Build patterns for tabs that should be hidden
    const hidePatterns = [];
    if (settings.hideReels) {
      hidePatterns.push({
        hrefs: ['/reels', '/reels/', 'reels'],
        labels: ['Reels', 'reels', 'Reel', 'reel'],
      });
    }
    if (settings.hideExplore) {
      hidePatterns.push({
        hrefs: ['/explore', '/explore/', 'explore'],
        labels: ['Explore', 'explore', 'Search', 'search', 'Search & explore'],
      });
    }
    if (settings.hideLiveShopping) {
      hidePatterns.push({
        hrefs: ['/shopping', '/shop'],
        labels: ['Shop', 'shop', 'Shopping', 'shopping'],
      });
    }

    if (hidePatterns.length === 0) return;

    // Strategy 1: Scan all anchor tags in the page for matching hrefs
    document.querySelectorAll('a').forEach((link) => {
      if (isInsideArticle(link)) return;

      const href = (link.getAttribute('href') || '').toLowerCase();
      const label = (link.getAttribute('aria-label') || '').toLowerCase();

      for (const pattern of hidePatterns) {
        const hrefMatch = pattern.hrefs.some(h => href === h.toLowerCase() || href.startsWith(h.toLowerCase()));
        const labelMatch = pattern.labels.some(l => label.includes(l.toLowerCase()));

        if (hrefMatch || labelMatch) {
          // Hide the link itself
          hideElement(link, 'navigation');

          // Walk up to hide the parent container (nav item wrapper)
          // Instagram wraps each nav icon in 1-3 layers of divs
          let parent = link.parentElement;
          let depth = 0;
          while (parent && depth < 4) {
            // Stop at the navigation bar container itself — don't hide the whole nav
            const tag = parent.tagName.toLowerCase();
            const role = parent.getAttribute('role') || '';
            if (tag === 'article' || role === 'article' || tag === 'nav' || role === 'navigation' || tag === 'body' || tag === 'main') break;

            // Check if this parent contains ONLY the one link we want to hide
            const siblingLinks = parent.querySelectorAll('a');
            if (siblingLinks.length <= 1) {
              // This is a wrapper for just this one nav item — safe to hide
              hideElement(parent, 'navigation');
            } else {
              // Multiple links inside — this is the nav bar itself, stop here
              break;
            }
            parent = parent.parentElement;
            depth++;
          }
          break;
        }
      }
    });

    // Strategy 2: Scan elements with aria-label attributes directly
    for (const pattern of hidePatterns) {
      pattern.labels.forEach(label => {
        try {
          document.querySelectorAll('[aria-label="' + label + '"]').forEach(el => {
            if (isInsideArticle(el)) return;

            hideElement(el, 'navigation');
            // Also hide parent wrapper if it's a single-child container
            let p = el.parentElement;
            if (p && p.querySelectorAll('a, [role="button"]').length <= 1) {
              const tag = p.tagName.toLowerCase();
              const role = p.getAttribute('role') || '';
              if (tag !== 'article' && role !== 'article' && tag !== 'nav' && role !== 'navigation') {
                hideElement(p, 'navigation');
              }
            }
          });
        } catch(_) {}
      });
    }
  }

  function suppressAutoplay() {
    if (!settings.disableAutoplay) return;
    document.querySelectorAll('video').forEach((v) => {
      v.muted = true;
      v.autoplay = false;
      if (!v.paused) v.pause();
    });
  }

  const viewedPosts = new Set();

  function currentPostOffset() {
    const value = Number(settings.currentPostsViewed || 0);
    return Number.isFinite(value) && value > 0 ? Math.floor(value) : 0;
  }

  function isVisiblePost(art) {
    if (!art || !isPostArticle(art)) return false;

    const rect = art.getBoundingClientRect();
    if (rect.width <= 0 || rect.height <= 0) return false;

    const viewportHeight = window.innerHeight || document.documentElement.clientHeight || 0;
    if (viewportHeight <= 0) return false;

    const visibleTop = Math.max(rect.top, 0);
    const visibleBottom = Math.min(rect.bottom, viewportHeight);
    const visibleHeight = Math.max(0, visibleBottom - visibleTop);
    const requiredHeight = Math.min(120, Math.max(32, rect.height * 0.1));

    return visibleHeight >= requiredHeight;
  }

  function countPost(art) {
    if (!art || !isPostArticle(art)) return false;

    const postId = getPostId(art);
    if (viewedPosts.has(postId)) return false;

    viewedPosts.add(postId);
    const count = currentPostOffset() + viewedPosts.size;

    send({ type: 'postCountUpdate', count: count });

    if (count >= settings.sessionLimit) {
      send({ type: 'caughtUp', count: count, limit: settings.sessionLimit });
    }

    return true;
  }

  function getPostId(art) {
    // 1. Try to find a link to the post detail page
    const linkSelector = 'a[href*="/p/"], a[href*="/reel/"], a[href*="/reels/"]';
    const linkEl = art.matches && art.matches(linkSelector)
      ? art
      : art.querySelector(linkSelector);
    if (linkEl) {
      const href = linkEl.getAttribute('href') || '';
      const parts = href.split('?')[0].split('/');
      for (let i = 0; i < parts.length - 1; i++) {
        if (parts[i] === 'p' || parts[i] === 'reel' || parts[i] === 'reels') {
          return '/' + parts[i] + '/' + parts[i + 1];
        }
      }
      return href;
    }

    // 2. Try to find timestamp
    const timeEl = art.querySelector('time');
    if (timeEl) {
      const datetime = timeEl.getAttribute('datetime');
      if (datetime) {
        const userEl = art.querySelector('a[href^="/"]');
        const username = userEl ? userEl.getAttribute('href') : '';
        return 'time_' + username + '_' + datetime;
      }
    }

    // 3. Fallback to existing __lumoraPostId property
    if (art.__lumoraPostId) {
      return art.__lumoraPostId;
    }

    // 4. Fallback to content text hash
    const textContent = art.textContent || '';
    if (textContent.length > 50) {
      const textSample = textContent.substring(0, 200);
      let hash = 0;
      for (let i = 0; i < textSample.length; i++) {
        hash = (hash << 5) - hash + textSample.charCodeAt(i);
        hash |= 0;
      }
      art.__lumoraPostId = 'hash_' + hash;
      return art.__lumoraPostId;
    }

    // 5. Ultimate fallback
    art.__lumoraPostId = 'rand_' + Math.random().toString(36).substr(2, 9);
    return art.__lumoraPostId;
  }

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const art = postCandidateFor(entry.target);

        if (!isPostArticle(art)) return;

        countPost(art);

        // Check if it is sponsored or suggested post
        if (art.matches && art.matches('article, [role="article"]') && settings.hideSuggested) {
          const suggestedLabels = (config.labelMap && config.labelMap.suggested) || [];
          if (containsAnyText(art, suggestedLabels)) {
            hideElement(art, 'suggestedPosts');
            return;
          }
        }
        if (art.matches && art.matches('article, [role="article"]') && settings.hideSponsored) {
          if (isSponsoredArticle(art)) {
            hideElement(art, 'sponsoredPosts');
            return;
          }
        }

      }
    });
  }, {
    threshold: 0.1 // Trigger when 10% of the article is visible
  });

  function observeArticles() {
    if (!config || !config.selectors) return;
    const sel = postCandidateSelector() + ',article[data-post-id]';
    document.querySelectorAll(sel).forEach((art) => {
      const candidate = postCandidateFor(art);
      if (!isPostArticle(candidate)) return;
      if (!candidate.__isObserved) {
        observer.observe(candidate);
        candidate.__isObserved = true;
      }
    });
  }

  function countVisiblePosts() {
    if (!config || !config.selectors) return;
    const sel = postCandidateSelector() + ',article[data-post-id]';
    document.querySelectorAll(sel).forEach((art) => {
      const candidate = postCandidateFor(art);
      if (isVisiblePost(candidate)) {
        countPost(candidate);
      }
    });
  }

  function dismissLoginWalls() {
    const dismissSelectors = [
      '[role="button"][aria-label="Not Now"]',
      'button[aria-label="Not Now"]',
      '[role="dialog"] [role="button"]:last-child',
    ];
    dismissSelectors.forEach(sel => {
      try {
        document.querySelectorAll(sel).forEach(btn => btn.click());
      } catch (_) {}
    });
  }

  function removeAppPrompts() {
    // 1. Target by common app install text
    const texts = [
      'Use the app',
      'Open in App',
      'Get the app',
      'Get the Instagram app',
      'Open app',
      'Install Instagram'
    ];

    document.querySelectorAll('button, a, span, div, p').forEach((el) => {
      // Check text content of element
      const txt = el.textContent ? el.textContent.trim() : '';
      if (texts.includes(txt)) {
        // Ensure it's not inside a post article (avoid comments / captions false positives)
        if (el.closest('article')) return;
        // Try to hide the closest parent banner container
        let parent = el.parentElement;
        let depth = 0;
        while (parent && depth < 5) {
          const style = window.getComputedStyle(parent);
          const pos = style.position;

          // If the container spans full width or is fixed/absolute/sticky
          if (pos === 'fixed' || pos === 'absolute' || pos === 'sticky' || parent.tagName === 'SECTION' || parent.getAttribute('role') === 'dialog' || parent.offsetWidth === window.innerWidth) {
            hideElement(parent, 'appPrompt');
            break;
          }
          parent = parent.parentElement;
          depth++;
        }
        hideElement(el, 'appPrompt');
      }
    });

    // 2. Hide any banners that contain the Play Store or App Store links
    document.querySelectorAll('a[href*="play.google.com/store/apps"], a[href*="apps.apple.com"], a[href*="instagram://"]').forEach((link) => {
      let parent = link.parentElement;
      let depth = 0;
      while (parent && depth < 4) {
        const pos = window.getComputedStyle(parent).position;
        if (pos === 'fixed' || pos === 'absolute' || pos === 'sticky' || parent.tagName === 'SECTION' || parent.offsetWidth === window.innerWidth) {
          hideElement(parent, 'appPrompt');
          break;
        }
        parent = parent.parentElement;
        depth++;
      }
      hideElement(link, 'appPrompt');
    });
  }

  function tick() {
    observeArticles();
    countVisiblePosts();
    applyDynamicHiding();
    suppressAutoplay();
    dismissLoginWalls();
    removeAppPrompts();
  }

  window.__lumoraTick = tick;

  tick();

  // Throttled MutationObserver for SPA changes
  let scheduled = false;
  const obs = new MutationObserver(() => {
    if (scheduled) return;
    scheduled = true;
    setTimeout(() => {
      scheduled = false;
      tick();
    }, 200);
  });
  obs.observe(document.body, { childList: true, subtree: true });

  window.addEventListener('scroll', () => {
    if (scheduled) return;
    scheduled = true;
    setTimeout(() => {
      scheduled = false;
      observeArticles();
      countVisiblePosts();
    }, 120);
  }, { passive: true });

  return true;
})();
  ''';
}
