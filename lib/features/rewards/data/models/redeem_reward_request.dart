import 'package:freezed_annotation/freezed_annotation.dart';

part 'redeem_reward_request.freezed.dart';
part 'redeem_reward_request.g.dart';

/// Body de POST /rewards/redeem
@freezed
class RedeemRewardRequest with _$RedeemRewardRequest {
  const factory RedeemRewardRequest({required int rewardId}) =
      _RedeemRewardRequest;

  factory RedeemRewardRequest.fromJson(Map<String, dynamic> json) =>
      _$RedeemRewardRequestFromJson(json);
}
