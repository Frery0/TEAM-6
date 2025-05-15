import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/gasto.dart';
import 'package:intl/intl.dart';

class AgregarGastoPage extends StatefulWidget {
  const AgregarGastoPage({super.key});

  @override
  State<AgregarGastoPage> createState() => _AgregarGastoPageState();
}

class _AgregarGastoPageState extends State<AgregarGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  String? _categoriaSeleccionada;
  DateTime? _fechaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Agregar gasto',
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                icon: Icon(Icons.arrow_drop_down, color: Colors.green[600], size: 30),
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
                    initialDate: DateTime.now(),
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
                              : DateFormat('MMMM dd/yyyy', 'es_ES').format(_fechaSeleccionada!).replaceFirstMapped(
                                  RegExp(r'(?<=\s)(\d{1})(?=/)'),
                                  (m) => m.group(1)!.padLeft(2, '0'),
                                ),
                          style: TextStyle(
                            fontSize: 20.0,
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && _fechaSeleccionada != null) {
                    final nuevoGasto = Gasto(
                      titulo: _descripcionController.text,
                      categoria: _categoriaSeleccionada!,
                      monto: _montoController.text,
                      fecha:
                          '${_fechaSeleccionada!.day.toString().padLeft(2, '0')}/'
                          '${_fechaSeleccionada!.month.toString().padLeft(2, '0')}/'
                          '${_fechaSeleccionada!.year}',
                    );
                    Navigator.pop(context, nuevoGasto);
                  } else if (_fechaSeleccionada == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Debe seleccionar una fecha')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  elevation: 5.0,
                ),
                child: const Text(
                  'AGREGAR',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
