import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../utils/eth_address_validator.dart';
import '../wallet_provider.dart';

/// Bottom sheet para retirar el saldo completo de CTC a la wallet del ciudadano.
///
/// - Valida el FORMATO EIP-55 client-side (no llama al backend si es inválido).
/// - El backend revalida el checksum y responde los errores de negocio
///   (sin saldo, retiro en curso, dirección inválida).
/// - Indica explícitamente que se retira el SALDO COMPLETO (RN-BC-05).
class WithdrawSheet extends ConsumerStatefulWidget {
  /// Saldo CTC mostrado (informativo) para el texto del sheet.
  final String balanceCtc;

  const WithdrawSheet({super.key, required this.balanceCtc});

  /// Abre el sheet y devuelve `true` si el retiro se inició/completó con éxito.
  static Future<bool?> show(
    BuildContext context, {
    required String balanceCtc,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WithdrawSheet(balanceCtc: balanceCtc),
    );
  }

  @override
  ConsumerState<WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends ConsumerState<WithdrawSheet> {
  final _controller = TextEditingController();
  String? _inlineError;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final address = _controller.text.trim();
    final formatError = EthAddressValidator.validate(address);
    if (formatError != null) {
      setState(() => _inlineError = formatError);
      return;
    }

    setState(() {
      _inlineError = null;
      _submitting = true;
    });

    final outcome = await ref
        .read(walletWithdrawControllerProvider)
        .withdraw(address);

    if (!mounted) return;
    setState(() => _submitting = false);

    switch (outcome) {
      case WithdrawSuccess():
        Navigator.of(context).pop(true);
      case WithdrawFailure(:final message):
        setState(() => _inlineError = message);
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
                'Retirar a mi wallet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Se retirará tu saldo completo de ${widget.balanceCtc} CTC a tu '
                'wallet en Polygon Amoy. El movimiento ocurre dentro de la red, '
                'no convierte a soles.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              AppTextField(
                label: 'DIRECCIÓN DE DESTINO',
                hint: '0x...',
                controller: _controller,
                errorText: _inlineError,
                autofocus: true,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
                onChanged: (_) {
                  if (_inlineError != null) {
                    setState(() => _inlineError = null);
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
                'Verifica la dirección: las transacciones on-chain son '
                'irreversibles.',
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
