class Gasto {
  int? id;
  final String titulo;
  final String categoria;
  final String monto;
  final String fecha;

  Gasto({
    this.id,
    required this.titulo,
    required this.categoria,
    required this.monto,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'categoria': categoria,
      'monto': monto,
      'fecha': fecha,
    };
  }

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'],
      titulo: map['titulo'],
      categoria: map['categoria'],
      monto: map['monto'],
      fecha: map['fecha'],
    );
  }
}
