// lib/services/rewarded_ad_service.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ad_config.dart';

class RewardedAdService {
  RewardedAd? _ad;
  bool _isLoading = false;

  void load() {
    if (_isLoading) return;
    _isLoading = true;
    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) => _isLoading = false,
      ),
    );
  }

  bool get isReady => _ad != null;

  void show({required void Function(AdWithoutView, RewardItem) onEarned}) {
    if (_ad == null) return;
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _ad = null;
      },
    );
    _ad!.show(onUserEarnedReward: onEarned);
  }

  void dispose() => _ad?.dispose();
}
