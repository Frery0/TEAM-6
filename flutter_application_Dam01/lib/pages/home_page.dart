import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/gasto.dart';
import 'agregar_gasto_page.dart';
import 'editar_gasto_page.dart';
import '../widgets/gasto_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Gasto> _gastos = [];
  String? _mensajeExito;
  Color _colorMensaje = Colors.blue[700]!;

  void _mostrarMensaje(String texto, {Color color = const Color(0xFF1976D2)}) {
    setState(() {
      _mensajeExito = texto;
      _colorMensaje = color;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _mensajeExito = null;
        _colorMensaje = Colors.blue[700]!; // Restaurar color base
      });
    });
  }

  void _cargarGastos() async {
    final gastosMap = await DatabaseHelper().obtenerGastos();
    final gastosCargados = gastosMap.map((map) => Gasto.fromMap(map)).toList();

    // Ordenar por fecha descendente (más recientes primero)
    gastosCargados.sort((a, b) {
      final fechaA = _parseFecha(a.fecha);
      final fechaB = _parseFecha(b.fecha);
      return fechaB.compareTo(fechaA);
    });

    if (!mounted) return;
    setState(() {
      _gastos = gastosCargados;
    });
  }

  DateTime _parseFecha(String fecha) {
    final partes = fecha.split('/');
    return DateTime(
      int.parse(partes[2]),
      int.parse(partes[1]),
      int.parse(partes[0]),
    );
  }

  void _agregarGasto(Gasto nuevoGasto) async {
    await DatabaseHelper().insertarGasto(nuevoGasto.toMap());
    if (!mounted) return;
    _cargarGastos();
    _mostrarMensaje("Agregado con éxito");
  }

  void _actualizarGasto(Gasto gasto) async {
    await DatabaseHelper().actualizarGasto(gasto);
    if (!mounted) return;
    _cargarGastos();
    _mostrarMensaje("Guardado con éxito");
  }

  void _eliminarGasto(int id) async {
    await DatabaseHelper().eliminarGasto(id);
    if (!mounted) return;
    _cargarGastos();
    _mostrarMensaje("Eliminado con éxito", color: Colors.red);
  }

  double get _gastoTotal =>
      _gastos.fold(0, (sum, item) => sum + double.tryParse(item.monto)!.toDouble());

  @override
  void initState() {
    super.initState();
    _cargarGastos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Resumen de gastos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        toolbarHeight: 125.0,
        elevation: 4.0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gasto total del mes'),
                        const SizedBox(height: 8.0),
                        Text(
                          '\$ ${_gastoTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(25.0),
                  child: Text(
                    'Historial de gastos',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    itemCount: _gastos.length,
                    itemBuilder: (context, index) {
                      final gasto = _gastos[index];
                      return GestureDetector(
                        onTap: () async {
                          final resultado = await Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditarGastoPage(gasto: gasto),
                            ),
                          );
                          if (!mounted) return;
                          if (resultado is Gasto) {
                            _actualizarGasto(resultado);
                          } else if (resultado == 'eliminado') {
                            _cargarGastos();
                            _mostrarMensaje("Eliminado con éxito", color: Colors.red);
                          } else {
                            _cargarGastos();
                          }
                        },
                        onLongPress: () => _eliminarGasto(gasto.id!),
                        child: GastoItem(gasto: gasto),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(25.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 24.0),
                    label: const Text(
                      'AGREGAR GASTO',
                      style: TextStyle(fontSize: 22.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 5.0,
                    ),
                    onPressed: () async {
                      final resultado = await Navigator.push<Gasto?>(
                        context,
                        MaterialPageRoute(builder: (context) => const AgregarGastoPage()),
                      );
                      if (!mounted) return;
                      if (resultado != null) {
                        _agregarGasto(resultado);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_mensajeExito != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 700),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  color: _colorMensaje,
                  alignment: Alignment.center,
                  child: Text(
                    _mensajeExito!,
                    style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}