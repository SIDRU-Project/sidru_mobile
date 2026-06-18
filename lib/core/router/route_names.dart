class RouteNames {
  // ── Auth ─────────────────────────────────────────────────────────────────────
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';

  // ── Shell principal ──────────────────────────────────────────────────────────
  static const home = '/home';
  static const history = '/history';
  static const scan = '/scan';
  static const rewards = '/rewards';
  static const profile = '/profile';
  static const wallet = '/wallet';
  static const impact = '/impact';

  // ── Subpantallas de sesiones / QR ────────────────────────────────────────────
  static const scanManual = '/scan/manual';
  static const scanSummary = '/scan/summary';
  static const scanConfirm = '/scan/confirm';
  static const scanResult = '/scan/result';
  static const scanError = '/scan/error';
  static const historyDetail = '/history/:id';

  // ── Subpantallas de recompensas ──────────────────────────────────────────────
  static const rewardsTransactions = '/rewards/transactions';
  static const rewardDetail = '/rewards/:id';
  static const rewardRedeemResult = '/rewards/redeem-result';

  // ── Perfil ────────────────────────────────────────────────────────────────────
  static const profileEdit = '/profile/edit';
}
