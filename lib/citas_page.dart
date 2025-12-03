import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medico.dart';
import '../services/cita_service.dart';

class CitasPage extends StatefulWidget {
  final Medico? medicoSeleccionado;

  const CitasPage({super.key, this.medicoSeleccionado});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CitaService _citaService = CitaService();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _medicoController = TextEditingController();
  final TextEditingController _pacienteController = TextEditingController();

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  String? _citaEnEdicion;
  String? _nombreUsuario;
  Medico? _medico;
  final Set<String> _citasEliminando = {}; // Rastrea citas en proceso de eliminación

  @override
  void initState() {
    super.initState();
    _medico = widget.medicoSeleccionado;
    _cargarNombreUsuario();
    if (_medico != null) {
      _medicoController.text = _medico!.nombre;
    }
  }

  Future<void> _cargarNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      setState(() {
        _nombreUsuario = doc.data()?['nombre'] ?? 'Usuario sin nombre';
        _pacienteController.text = _nombreUsuario ?? '';
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() => _fechaSeleccionada = pickedDate);
    }
  }

  Future<void> _seleccionarHoraInicio() async {
    // Mostrar solo horas en intervalos de 30 minutos
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Ajustar a intervalo de 30 minutos
      final minutosAjustados = (picked.minute / 30).round() * 30;
      final horaAjustada = TimeOfDay(
        hour: picked.hour + (minutosAjustados ~/ 60),
        minute: minutosAjustados % 60,
      );
      
      setState(() {
        _horaInicio = horaAjustada;
        // Calcula automáticamente media hora después
        final finDate = DateTime(0, 0, 0, horaAjustada.hour, horaAjustada.minute)
            .add(const Duration(minutes: 30));
        _horaFin = TimeOfDay(hour: finDate.hour, minute: finDate.minute);
      });
    }
  }


  Future<void> _guardarCita() async {
    if (_motivoController.text.isEmpty ||
        _fechaSeleccionada == null ||
        _horaInicio == null ||
        _horaFin == null ||
        _medicoController.text.isEmpty ||
        _pacienteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    // Si hay médico seleccionado, usar validaciones avanzadas
    if (_medico != null && _pacienteController.text.isNotEmpty) {
      final error = await _citaService.validarCita(
        pacienteNombre: _pacienteController.text.trim(),
        medicoId: _medico!.id!,
        fecha: _fechaSeleccionada!,
        horaInicio: _horaInicio!,
        horaFin: _horaFin!,
        medico: _medico!,
        citaIdExcluir: _citaEnEdicion,
      );

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      // Validación básica si no hay médico seleccionado
      if (_horaInicio!.minute != 0 && _horaInicio!.minute != 30) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("La hora debe ser en intervalos de 30 minutos (ej: 8:00, 8:30, 9:00)"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final inicio = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaInicio!.hour,
        _horaInicio!.minute);
    final fin = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaFin!.hour,
        _horaFin!.minute);

    final data = {
      'nombreUsuario': _nombreUsuario ?? 'Sin nombre',
      'paciente': _pacienteController.text.trim(),
      'medico': _medicoController.text.trim(),
      if (_medico?.id != null) 'medicoId': _medico!.id,
      'motivo': _motivoController.text.trim(),
      'fecha': Timestamp.fromDate(_fechaSeleccionada!),
      'horaInicio': Timestamp.fromDate(inicio),
      'horaFin': Timestamp.fromDate(fin),
      'creadoEn': FieldValue.serverTimestamp(),
      // Campos para borrado lógico
      'estado': 'activa',
      'eliminado': false,
      'razonCancelacion': '',
      'duracionMinutos': 30,
      'tipoCita': 'consulta',
    };

    if (_citaEnEdicion == null) {
      await _firestore.collection('citas').add(data);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cita creada")));
    } else {
      await _firestore.collection('citas').doc(_citaEnEdicion).update(data);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cita actualizada")));
    }

    _motivoController.clear();
    if (_medico == null) {
      _medicoController.clear();
    } else {
      _medicoController.text = _medico!.nombre;
    }
    _horaInicio = null;
    _horaFin = null;
    setState(() {
      _fechaSeleccionada = null;
      _citaEnEdicion = null;
    });
  }


  void _editarCita(String id, Map<String, dynamic> data) {
    setState(() {
      _citaEnEdicion = id;
      _motivoController.text = data['motivo'] ?? '';
      _medicoController.text = data['medico'] ?? '';
      _pacienteController.text = data['paciente'] ?? '';
      _fechaSeleccionada =
          (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now();
      final inicio = (data['horaInicio'] as Timestamp?)?.toDate();
      final fin = (data['horaFin'] as Timestamp?)?.toDate();
      if (inicio != null) _horaInicio = TimeOfDay.fromDateTime(inicio);
      if (fin != null) _horaFin = TimeOfDay.fromDateTime(fin);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Agenda de Citas Médicas'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- FORMULARIO DE CITA ---
            Card(
              elevation: 6,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Registrar nueva cita",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _medicoController,
                      enabled: _medico == null,
                      decoration: InputDecoration(
                        labelText: 'Médico',
                        prefixIcon: const Icon(Icons.person),
                        hintText: _medico != null ? 'Médico preseleccionado' : 'Ingrese el nombre del médico',
                      ),
                    ),
                    if (_medico != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Especialidad: ${_medico!.especialidad}',
                          style: TextStyle(
                            color: Colors.teal[700],
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    TextField(
                      controller: _pacienteController,
                      decoration: const InputDecoration(
                        labelText: 'Paciente',
                        prefixIcon: Icon(Icons.people),
                      ),
                    ),
                    TextField(
                      controller: _motivoController,
                      decoration: const InputDecoration(
                        labelText: 'Motivo de la cita',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(_fechaSeleccionada == null
                              ? 'Seleccionar fecha'
                              : '📅 ${_fechaSeleccionada!.toLocal().toString().split(" ")[0]}'),
                        ),
                        IconButton(
                            onPressed: _seleccionarFecha,
                            icon: const Icon(Icons.calendar_month)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // --- ROW MODIFICADO: ICONO A LA IZQUIERDA ---
                    Row(
                      children: [
                        // Icono del reloj a la izquierda
                        IconButton(
                          icon: const Icon(Icons.access_time, color: Colors.blueAccent),
                          onPressed: _seleccionarHoraInicio,
                        ),
                        const SizedBox(width: 8),
                        // Texto de hora de inicio
                        Expanded(
                          child: Text(
                            _horaInicio == null
                                ? 'Hora de inicio'
                                : 'Inicio: ${_horaInicio!.format(context)}',
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Texto de hora fin
                        Expanded(
                          child: Text(
                            _horaFin == null
                                ? 'Fin (auto 30 min)'
                                : 'Fin: ${_horaFin!.format(context)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _guardarCita,
                      icon: const Icon(Icons.save),
                      label: Text(
                        _citaEnEdicion == null
                            ? 'Programar cita'
                            : 'Guardar cambios',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            const Text(
              "Citas programadas",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('citas')
                  .orderBy('fecha', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No hay citas programadas',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Filtrar por paciente, citas eliminadas y en proceso de eliminación
                final nombrePaciente = _nombreUsuario ?? '';
                final citas = snapshot.data!.docs
                    .where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final paciente = data['paciente']?.toString() ?? '';
                      final eliminado = data['eliminado'] ?? false;
                      return paciente == nombrePaciente && 
                             !eliminado && 
                             !_citasEliminando.contains(doc.id);
                    })
                    .toList();
                
                // Ordenar por fecha después del filtro
                citas.sort((a, b) {
                  final fechaA = (a.data() as Map<String, dynamic>)['fecha'] as Timestamp?;
                  final fechaB = (b.data() as Map<String, dynamic>)['fecha'] as Timestamp?;
                  if (fechaA == null || fechaB == null) return 0;
                  return fechaA.compareTo(fechaB);
                });
                    
                if (citas.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay citas programadas'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: citas.length,
                  itemBuilder: (context, index) {
                    final cita = citas[index];
                    final data = cita.data() as Map<String, dynamic>;
                    final fecha = (data['fecha'] as Timestamp?)?.toDate();
                    final inicio = (data['horaInicio'] as Timestamp?)?.toDate();
                    final fin = (data['horaFin'] as Timestamp?)?.toDate();

                    return Dismissible(
                      key: ValueKey('cita_${cita.id}'),
                      direction: DismissDirection.horizontal,
                      resizeDuration: const Duration(milliseconds: 200),
                      movementDuration: const Duration(milliseconds: 200),
                      // Fondo izquierdo (se muestra al deslizar startToEnd - desde la izquierda hacia la derecha)
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 32),
                            SizedBox(width: 10),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Fondo derecho (se muestra al deslizar endToStart - desde la derecha hacia la izquierda)
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.delete, color: Colors.white, size: 32),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Deslizar hacia la derecha → Editar (NO eliminar el widget)
                          _editarCita(cita.id, data);
                          // Hacer scroll al formulario
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Scrollable.ensureVisible(
                              context,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                          return false; // No eliminar el widget, solo cargar datos
                        } else if (direction == DismissDirection.endToStart) {
                          // Deslizar hacia la izquierda → Eliminar (sí eliminar el widget)
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Cancelar cita"),
                              content: const Text("¿Seguro que deseas cancelar esta cita?\n\nLa cita se marcará como cancelada pero se mantendrá en el historial."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Cancelar cita"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            // Mostrar diálogo para razón de cancelación (opcional)
                            final razon = await showDialog<String>(
                              context: context,
                              builder: (context) {
                                String? razonCancelacion = '';
                                return AlertDialog(
                                  title: const Text('Cancelar Cita'),
                                  content: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Razón de cancelación (opcional)',
                                      hintText: 'Ej: Cambio de planes, emergencia...',
                                    ),
                                    onChanged: (value) => razonCancelacion = value,
                                    maxLines: 3,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, null),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, razonCancelacion ?? ''),
                                      child: const Text('Confirmar'),
                                    ),
                                  ],
                                );
                              },
                            );
                            
                            if (razon != null) {
                              // Marcar como eliminando y cancelar (borrado lógico)
                              if (mounted) {
                                setState(() {
                                  _citasEliminando.add(cita.id);
                                });
                                
                                // Usar borrado lógico en lugar de eliminación física
                                await _citaService.cancelarCita(
                                  citaId: cita.id,
                                  razon: razon,
                                ).then((_) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Cita cancelada"),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    // Limpiar después de un pequeño delay
                                    Future.delayed(const Duration(milliseconds: 100), () {
                                      if (mounted) {
                                        setState(() {
                                          _citasEliminando.remove(cita.id);
                                        });
                                      }
                                    });
                                  }
                                }).catchError((error) {
                                  // Si hay error, quitar de la lista para que vuelva a aparecer
                                  if (mounted) {
                                    setState(() {
                                      _citasEliminando.remove(cita.id);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error al cancelar: $error"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                });
                              }
                            }
                          }
                          return confirm == true;
                        }
                        return false;
                      },
                      onDismissed: (direction) {
                        // La eliminación ya se maneja en confirmDismiss
                        // Este callback existe para cumplir con la API de Dismissible
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(
                            '${data['motivo'] ?? 'Sin motivo'}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            '👨‍⚕️ Médico: ${data['medico'] ?? ''}\n'
                            '🧍 Paciente: ${data['paciente'] ?? ''}\n'
                            '📅 ${fecha?.toLocal().toString().split(" ")[0]}\n'
                            '🕒 ${inicio?.hour}:${inicio?.minute.toString().padLeft(2, '0')} - ${fin?.hour}:${fin?.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}