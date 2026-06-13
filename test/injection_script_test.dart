import 'package:flutter_test/flutter_test.dart';
import 'package:lumora/injection/build_injection_script.dart';

void main() {
  const config = {
    'selectors': {
      'reelsTab': ['a[href="/reels/"]'],
      'exploreTab': ['a[href="/explore/"]'],
      'liveAndShopping': ['a[href*="/shopping/"]'],
      'postItem': ['article', '[role="article"]'],
      'suggestedPosts': ['article'],
      'sponsoredPosts': ['article'],
    },
    'labelMap': {
      'sponsored': ['Ad', 'Sponsored'],
      'suggested': ['Suggested for you'],
    },
  };

  const baseSettings = {
    'sessionLimit': 20,
    'confirmBeforeExtending': true,
    'hideReels': true,
    'hideExplore': true,
    'hideSuggested': true,
    'hideSponsored': true,
    'hideLiveShopping': true,
    'disableAutoplay': true,
  };

  test('does not statically hide broad navigation selectors', () {
    final script = buildInjectionScript(config, baseSettings);

    expect(
      script,
      isNot(contains('a[href="/reels/"] { display: none !important; }')),
    );
    expect(
      script,
      isNot(contains('a[href="/explore/"] { display: none !important; }')),
    );
    expect(
      script,
      isNot(contains('a[href*="/shopping/"] { display: none !important; }')),
    );
  });

  test('keeps navigation hiding out of article content', () {
    final script = buildInjectionScript(config, baseSettings);

    expect(script, contains('function isInsideArticle(el)'));
    expect(script, contains('if (isInsideArticle(link)) return;'));
    expect(script, contains("tag === 'article' || role === 'article'"));
    expect(script, contains('if (isInsideArticle(el)) return;'));
  });

  test('requires post-shaped articles before hiding ads or suggestions', () {
    final script = buildInjectionScript(config, baseSettings);

    expect(script, contains('function isPostArticle(el)'));
    expect(
      script,
      contains(
        "const nestedArticle = el.querySelector('article, [role=\"article\"]');",
      ),
    );
    expect(script, contains('if (!isPostArticle(article)) return;'));
    expect(script, contains('if (!isPostArticle(art)) return;'));
  });

  test('counts reel permalink cards as post candidates', () {
    final script = buildInjectionScript(config, baseSettings);

    expect(script, contains('function postCandidateFor(el)'));
    expect(script, contains('function postCandidateSelector()'));
    expect(script, contains('a[href*="/reel/"]'));
    expect(script, contains('a[href*="/reels/"]'));
    expect(script, contains('const candidate = postCandidateFor(art);'));
    expect(
      script,
      contains("el.closest('nav, header, footer, aside, [role=\"dialog\"]')"),
    );
  });

  test('offsets WebView counts by the active session count', () {
    final script = buildInjectionScript(config, {
      ...baseSettings,
      'currentPostsViewed': 6,
    });

    expect(script, contains('function currentPostOffset()'));
    expect(script, contains('settings.currentPostsViewed'));
    expect(script, contains('currentPostOffset() + viewedPosts.size'));
  });

  test('counts visible posts before applying feed filters', () {
    final script = buildInjectionScript(config, baseSettings);

    expect(script, contains('function countVisiblePosts()'));
    expect(script, contains('window.addEventListener(\'scroll\''));
    expect(script, contains('countPost(art);'));
    expect(
      script,
      contains(
        'observeArticles();\n    countVisiblePosts();\n    applyDynamicHiding();',
      ),
    );
  });

  test('keeps release script free of post id console logging', () {
    final script = buildInjectionScript(config, baseSettings);

    expect(script, isNot(contains("console.log('Post viewed:'")));
  });

  test('guards against hiding root document containers', () {
    final script = buildInjectionScript(config, baseSettings);

    expect(script, contains("tag === 'html'"));
    expect(script, contains("tag === 'body'"));
    expect(script, contains("tag === 'main'"));
  });
}
