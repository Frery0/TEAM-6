import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/gasto.dart';
import '../database_helper.dart';

class EditarGastoPage extends StatefulWidget {
  final Gasto gasto;

  const EditarGastoPage({super.key, required this.gasto});

  @override
  State<EditarGastoPage> createState() => _EditarGastoPageState();
}

class _EditarGastoPageState extends State<EditarGastoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionController;
  late TextEditingController _montoController;
  String? _categoriaSeleccionada;
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(text: widget.gasto.titulo);
    _montoController = TextEditingController(text: widget.gasto.monto);
    _categoriaSeleccionada = widget.gasto.categoria;

    final partesFecha = widget.gasto.fecha.split('/');
    _fechaSeleccionada = DateTime(
      int.parse(partesFecha[2]),
      int.parse(partesFecha[1]),
      int.parse(partesFecha[0]),
    );
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate() && _fechaSeleccionada != null) {
      final gastoActualizado = Gasto(
        id: widget.gasto.id,
        titulo: _descripcionController.text,
        categoria: _categoriaSeleccionada!,
        monto: _montoController.text,
        fecha:
            '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/${_fechaSeleccionada!.year}',
      );
      Navigator.pop(context, gastoActualizado);
    } else if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar una fecha')),
      );
    }
  }

  void _confirmarEliminar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Seguro que quieres eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      if (widget.gasto.id != null) {
        await DatabaseHelper().eliminarGasto(widget.gasto.id!);
      }
      if (!mounted) return;
      Navigator.pop(context, 'eliminado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Editar Gasto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[500],
        foregroundColor: Colors.white,
        toolbarHeight: 150.0,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: InputDecoration(
                  hintText: 'Categoría',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
                dropdownColor: Colors.white,
                elevation: 8,
                icon: Icon(Icons.arrow_drop_down, color: Colors.green[600], size: 40),
                items: const [
                  DropdownMenuItem(value: 'Comida', child: Text('Comida')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Entretenimiento', child: Text('Entretenimiento')),
                  DropdownMenuItem(value: 'Recibos', child: Text('Recibos')),
                  DropdownMenuItem(value: 'Extras', child: Text('Extras')),
                ],
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*')),
                ],
                decoration: InputDecoration(
                  hintText: 'Monto',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un monto' : null,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Descripción',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 12.0),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaSeleccionada ?? DateTime.now(),
                    firstDate: DateTime(1999),
                    lastDate: DateTime(2025, 12, 31),
                  );
                  if (picked != null) {
                    setState(() {
                      _fechaSeleccionada = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _fechaSeleccionada == null
                              ? 'Seleccione una fecha'
                              : '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/'
                                  '${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/'
                                  '${_fechaSeleccionada!.year}',
                          style: TextStyle(
                            color: _fechaSeleccionada == null ? Colors.grey[700] : Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.green[600]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 5.0,
                      ),
                      child: const Text('GUARDAR', style: TextStyle(fontSize: 16.0)),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirmarEliminar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('ELIMINAR', style: TextStyle(fontSize: 16.0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
