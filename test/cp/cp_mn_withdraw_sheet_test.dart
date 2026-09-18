import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidru_mobile/features/wallet/presentation/widgets/withdraw_sheet.dart';

/// CpMn — US-MN-01/02/03: validación del formulario de retiro (WithdrawSheet),
/// sin red. La validación inline de puntos y dirección corre ANTES de llamar al
/// backend, así que estas pruebas no necesitan mockear el `WalletApi`: si
/// hubiera una llamada de red real, el `ProviderScope` sin overrides fallaría
/// de inmediato y el test lo delataría.
void main() {
  Future<void> pumpSheet(
    WidgetTester tester, {
    int pointsBalance = 1200,
    int minWithdrawalPoints = 500,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WithdrawSheet(
              pointsBalance: pointsBalance,
              minWithdrawalPoints: minWithdrawalPoints,
            ),
          ),
        ),
      ),
    );
  }

  group('CpMn - WithdrawSheet: puntos', () {
    testWidgets('por defecto propone retirar todo el saldo disponible',
        (tester) async {
      await pumpSheet(tester, pointsBalance: 1200);

      expect(find.text('1200'), findsOneWidget);
    });

    testWidgets('rechaza un monto por debajo del minimo', (tester) async {
      await pumpSheet(
        tester,
        pointsBalance: 1200,
        minWithdrawalPoints: 500,
      );

      await tester.enterText(find.byType(TextFormField).first, '499');
      await tester.tap(find.text('Confirmar retiro'));
      await tester.pump();

      expect(find.textContaining('mínimo de retiro es 500'), findsOneWidget);
    });

    testWidgets('rechaza un monto por encima del saldo disponible',
        (tester) async {
      await pumpSheet(
        tester,
        pointsBalance: 1200,
        minWithdrawalPoints: 500,
      );

      await tester.enterText(find.byType(TextFormField).first, '1201');
      await tester.tap(find.text('Confirmar retiro'));
      await tester.pump();

      expect(
        find.textContaining('No puedes retirar más de tu saldo disponible'),
        findsOneWidget,
      );
    });

    testWidgets('rechaza un monto no numerico', (tester) async {
      await pumpSheet(tester);

      await tester.enterText(find.byType(TextFormField).first, 'abc');
      await tester.tap(find.text('Confirmar retiro'));
      await tester.pump();

      expect(
        find.textContaining('Ingresa un número de puntos válido'),
        findsOneWidget,
      );
    });

    testWidgets('un monto valido dentro de rango no muestra error de puntos',
        (tester) async {
      await pumpSheet(
        tester,
        pointsBalance: 1200,
        minWithdrawalPoints: 500,
      );

      await tester.enterText(find.byType(TextFormField).first, '700');
      await tester.tap(find.text('Confirmar retiro'));
      await tester.pump();

      // La direccion sigue vacia, asi que el submit no prospera, pero el error
      // de puntos (si lo hubiera) ya no debe aparecer.
      expect(find.textContaining('mínimo de retiro'), findsNothing);
      expect(find.textContaining('No puedes retirar más'), findsNothing);
    });
  });

  group('CpMn - WithdrawSheet: selector de modo', () {
    testWidgets('CTC esta seleccionado por defecto', (tester) async {
      await pumpSheet(tester);

      expect(
        find.text('CTC — para MetaMask u otra wallet no custodial'),
        findsOneWidget,
      );
      expect(
        find.text('USDC — si vas a depositar en Lemon o un exchange'),
        findsOneWidget,
      );
    });

    testWidgets('tocar USDC lo selecciona y CTC deja de estarlo',
        (tester) async {
      await pumpSheet(tester);

      final ctcOption = find.byKey(const Key('withdraw-mode-CTC'));
      final usdcOption = find.byKey(const Key('withdraw-mode-USDC'));

      expect(
        find.descendant(
          of: ctcOption,
          matching: find.byIcon(Icons.radio_button_checked_rounded),
        ),
        findsOneWidget,
        reason: 'CTC empieza seleccionado',
      );

      await tester.tap(usdcOption);
      await tester.pump();

      expect(
        find.descendant(
          of: usdcOption,
          matching: find.byIcon(Icons.radio_button_checked_rounded),
        ),
        findsOneWidget,
        reason: 'USDC queda seleccionado tras tocarlo',
      );
      expect(
        find.descendant(
          of: ctcOption,
          matching: find.byIcon(Icons.radio_button_off_rounded),
        ),
        findsOneWidget,
        reason: 'CTC deja de estar seleccionado',
      );
    });

    testWidgets('el aviso fijo sobre Lemon/exchange esta siempre visible',
        (tester) async {
      await pumpSheet(tester);

      expect(
        find.text(
          'No envíes CTC a Lemon ni a un exchange: no lo reconocen y se '
          'pierde.',
        ),
        findsOneWidget,
      );
    });
  });
}
