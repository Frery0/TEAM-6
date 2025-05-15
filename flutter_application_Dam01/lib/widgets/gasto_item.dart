import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gasto.dart';

class GastoItem extends StatelessWidget {
  final Gasto gasto;

  const GastoItem({super.key, required this.gasto});

  @override
  Widget build(BuildContext context) {
    const darkTextColor = Colors.black87;
    const subtitleTextColor = Colors.black54;
    const dividerColor = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dividerColor,
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Parte izquierda: título y categoría
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gasto.titulo,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    gasto.categoria,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: subtitleTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Parte derecha: monto y fecha
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${gasto.monto}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  _formatFecha(gasto.fecha),
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: subtitleTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(String fecha) {
    final partes = fecha.split('/');
    final date = DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
    return DateFormat("MMMM dd/yyyy", "es_ES").format(date).replaceFirstMapped(
      RegExp(r'(?<=\s)(\d{1})(?=/)'),
      (m) => m.group(1)!.padLeft(2, '0'),
    );
  }
}