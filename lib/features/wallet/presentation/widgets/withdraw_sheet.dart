import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../data/models/wallet_transaction.dart';
import '../../utils/eth_address_validator.dart';
import '../wallet_provider.dart';

/// Modo de retiro (design.md §8). Los textos son literales de la spec.
enum WithdrawMode {
  ctc('CTC', 'CTC — para MetaMask u otra wallet no custodial'),
  usdc('USDC', 'USDC — si vas a depositar en Lemon o un exchange');

  final String apiValue;
  final String label;
  const WithdrawMode(this.apiValue, this.label);
}

/// Bottom sheet para retirar puntos a CTC o USDC (spec sidru-mainnet).
///
/// - Valida el FORMATO + checksum EIP-55 client-side (no llama al backend si es
///   inválido) y los puntos (mínimo, máximo = saldo disponible).
/// - El backend revalida todo y responde los errores de negocio.
/// - Por defecto propone retirar el saldo completo; el ciudadano puede retirar
///   una parte (US-MN-01, "Retiro parcial").
class WithdrawSheet extends ConsumerStatefulWidget {
  /// Saldo de puntos disponible (por defecto, el monto propuesto).
  final int pointsBalance;

  /// Mínimo de puntos permitido por retiro (design.md §9).
  final int minWithdrawalPoints;

  const WithdrawSheet({
    super.key,
    required this.pointsBalance,
    required this.minWithdrawalPoints,
  });

  /// Abre el sheet y devuelve el [WalletTransaction] del retiro si se inició
  /// con éxito (EN_PROCESO o ya resuelto), o `null` si se canceló.
  static Future<WalletTransaction?> show(
    BuildContext context, {
    required int pointsBalance,
    required int minWithdrawalPoints,
  }) {
    return showModalBottomSheet<WalletTransaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WithdrawSheet(
        pointsBalance: pointsBalance,
        minWithdrawalPoints: minWithdrawalPoints,
      ),
    );
  }

  @override
  ConsumerState<WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends ConsumerState<WithdrawSheet> {
  late final TextEditingController _addressController;
  late final TextEditingController _pointsController;
  String? _addressError;
  String? _pointsError;
  WithdrawMode _mode = WithdrawMode.ctc;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    // Por defecto, todo el saldo disponible (el ciudadano puede reducirlo).
    _pointsController = TextEditingController(
      text: widget.pointsBalance.toString(),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  /// `null` si los puntos son válidos; el mensaje inline en caso contrario.
  String? _validatePoints(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Ingresa cuántos puntos quieres retirar.';
    final points = int.tryParse(trimmed);
    if (points == null || points <= 0) {
      return 'Ingresa un número de puntos válido.';
    }
    if (points < widget.minWithdrawalPoints) {
      return 'El mínimo de retiro es ${widget.minWithdrawalPoints} puntos.';
    }
    if (points > widget.pointsBalance) {
      return 'No puedes retirar más de tu saldo disponible '
          '(${widget.pointsBalance} puntos).';
    }
    return null;
  }

  Future<void> _submit() async {
    final address = _addressController.text.trim();
    final addressError = EthAddressValidator.validate(address);
    final pointsError = _validatePoints(_pointsController.text);

    if (addressError != null || pointsError != null) {
      setState(() {
        _addressError = addressError;
        _pointsError = pointsError;
      });
      return;
    }

    setState(() {
      _addressError = null;
      _pointsError = null;
      _submitting = true;
    });

    final points = int.parse(_pointsController.text.trim());
    final outcome = await ref.read(walletWithdrawControllerProvider).withdraw(
      toAddress: address,
      points: points,
      mode: _mode.apiValue,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    switch (outcome) {
      case WithdrawSuccess(:final transaction):
        Navigator.of(context).pop(transaction);
      case WithdrawFailure(:final message):
        setState(() => _pointsError = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const Text(
                'Retirar puntos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tienes ${widget.pointsBalance} puntos disponibles '
                '(mínimo ${widget.minWithdrawalPoints} por retiro).',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'PUNTOS A RETIRAR',
                controller: _pointsController,
                errorText: _pointsError,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(
                  Icons.toll_outlined,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
                onChanged: (_) {
                  if (_pointsError != null) setState(() => _pointsError = null);
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'MODO DE RETIRO',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              for (final mode in WithdrawMode.values) ...[
                _ModeOption(
                  mode: mode,
                  selected: _mode == mode,
                  onTap: () => setState(() => _mode = mode),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              AppTextField(
                label: 'DIRECCIÓN DE DESTINO',
                hint: '0x...',
                controller: _addressController,
                errorText: _addressError,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
                onChanged: (_) {
                  if (_addressError != null) {
                    setState(() => _addressError = null);
                  }
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              GradientButton(
                label: 'Confirmar retiro',
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
              const SizedBox(height: 10),
              const Text(
                'No envíes CTC a Lemon ni a un exchange: no lo reconocen y se '
                'pierde.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  final WithdrawMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ModeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('withdraw-mode-${mode.apiValue}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:
                selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.background.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected ? AppColors.primary : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                size: 18,
                color: selected ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  mode.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color:
                        selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
