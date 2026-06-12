import 'package:flutter/material.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/models/recycling_session.dart';

/// Chip de estado tipado para [RecyclingSessionStatus].
/// Delega el renderizado al [StatusChip] compartido.
class SessionStatusChip extends StatelessWidget {
  final RecyclingSessionStatus status;

  const SessionStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // RecyclingSessionStatus.pending.name = 'pending' → toUpperCase() = 'PENDING'
    // StatusChip + StatusFormatter reconocen el string en mayúsculas.
    return StatusChip(status: status.name.toUpperCase());
  }
}
