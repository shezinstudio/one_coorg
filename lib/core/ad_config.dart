class AdConfig {
  // Use test IDs during development, swap before release
  static const bool isTest = false;

  static String get bannerAdUnitId {
    if (isTest) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android test
    }
    return 'ca-app-pub-2551988852167884/2055080590'; // Your real ID
  }

  static String get interstitialAdUnitId {
    if (isTest) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Android test
    }
    return 'ca-app-pub-2551988852167884/3404389506';
  }

  static String get rewardedAdUnitId {
    if (isTest) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Android test
    }
    return 'ca-app-pub-2551988852167884/2985018884';
  }
}
