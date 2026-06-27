import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_coorg/core/ad_config.dart';

class InterstitialAdService {
  InterstitialAd? _ad;

  void load() {
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _ad!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) => _ad = null,
      ),
    );
  }

  /// Shows the ad if loaded, then calls [onComplete] either way.
  void showThenDo(void Function() onComplete) {
    if (_ad == null) {
      onComplete();
      return;
    }
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        load(); // preload next
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _ad = null;
        onComplete();
      },
    );
    _ad!.show();
  }

  void dispose() => _ad?.dispose();
}
