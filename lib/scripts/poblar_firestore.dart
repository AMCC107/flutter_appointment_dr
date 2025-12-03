import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Script para poblar Firestore con especialidades y médicos de ejemplo
/// Ejecutar una vez para inicializar la base de datos
Future<void> poblarFirestore() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // 1. Crear especialidades
  final especialidades = [
    {
      'id': 'cardiologia',
      'nombre': 'Cardiología',
      'descripcion': 'Especialidad del corazón y sistema circulatorio',
      'icono': 'heart',
      'color': '#FF5252',
    },
    {
      'id': 'pediatria',
      'nombre': 'Pediatría',
      'descripcion': 'Atención médica para bebés, niños y adolescentes',
      'icono': 'child_care',
      'color': '#4CAF50',
    },
    {
      'id': 'dermatologia',
      'nombre': 'Dermatología',
      'descripcion': 'Cuidado de la piel, cabello y uñas',
      'icono': 'face',
      'color': '#FFC107',
    },
    {
      'id': 'ginecologia',
      'nombre': 'Ginecología',
      'descripcion': 'Salud reproductiva y sistema reproductor femenino',
      'icono': 'pregnant_woman',
      'color': '#E91E63',
    },
    {
      'id': 'ortopedia',
      'nombre': 'Ortopedia',
      'descripcion': 'Tratamiento de huesos, articulaciones y músculos',
      'icono': 'healing',
      'color': '#2196F3',
    },
  ];

  print('Creando especialidades...');
  for (var esp in especialidades) {
    await firestore.collection('especialidades').doc(esp['id']).set(esp);
    print('✓ ${esp['nombre']} creada');
  }

  // 2. Crear médicos
  final medicos = [
    // Cardiología
    {
      'nombre': 'Dr. Carlos Rodríguez',
      'especialidad': 'Cardiología',
      'especialidadId': 'cardiologia',
      'descripcion': 'Especialista en enfermedades del corazón con más de 12 años de experiencia',
      'experiencia': '12 años',
      'calificacion': 4.8,
      'telefono': '+1234567890',
      'email': 'carlos.rodriguez@hospital.com',
      'horario': {
        'lunes': {'inicio': '08:00', 'fin': '17:00'},
        'martes': {'inicio': '08:00', 'fin': '17:00'},
        'miercoles': {'inicio': '08:00', 'fin': '17:00'},
        'jueves': {'inicio': '08:00', 'fin': '17:00'},
        'viernes': {'inicio': '08:00', 'fin': '17:00'},
      },
      'disponibilidad': [],
    },
    {
      'nombre': 'Dra. Ana Martínez',
      'especialidad': 'Cardiología',
      'especialidadId': 'cardiologia',
      'descripcion': 'Cardióloga especializada en arritmias y prevención cardiovascular',
      'experiencia': '10 años',
      'calificacion': 4.9,
      'telefono': '+1234567891',
      'email': 'ana.martinez@hospital.com',
      'horario': {
        'lunes': {'inicio': '08:00', 'fin': '17:00'},
        'martes': {'inicio': '08:00', 'fin': '17:00'},
        'miercoles': {'inicio': '08:00', 'fin': '17:00'},
        'jueves': {'inicio': '08:00', 'fin': '17:00'},
        'viernes': {'inicio': '08:00', 'fin': '17:00'},
      },
      'disponibilidad': [],
    },
    // Pediatría
    {
      'nombre': 'Dr. Luis García',
      'especialidad': 'Pediatría',
      'especialidadId': 'pediatria',
      'descripcion': 'Pediatra con experiencia en atención neonatal y desarrollo infantil',
      'experiencia': '15 años',
      'calificacion': 4.7,
      'telefono': '+1234567892',
      'email': 'luis.garcia@hospital.com',
      'horario': {
        'lunes': {'inicio': '08:00', 'fin': '17:00'},
        'martes': {'inicio': '08:00', 'fin': '17:00'},
        'miercoles': {'inicio': '08:00', 'fin': '17:00'},
        'jueves': {'inicio': '08:00', 'fin': '17:00'},
        'viernes': {'inicio': '08:00', 'fin': '17:00'},
      },
      'disponibilidad': [],
    },
    {
      'nombre': 'Dra. María López',
      'especialidad': 'Pediatría',
      'especialidadId': 'pediatria',
      'descripcion': 'Especialista en enfermedades infecciosas pediátricas',
      'experiencia': '8 años',
      'calificacion': 4.6,
      'telefono': '+1234567893',
      'email': 'maria.lopez@hospital.com',
      'horario': {
        'lunes': {'inicio': '08:00', 'fin': '17:00'},
        'martes': {'inicio': '08:00', 'fin': '17:00'},
        'miercoles': {'inicio': '08:00', 'fin': '17:00'},
        'jueves': {'inicio': '08:00', 'fin': '17:00'},
        'viernes': {'inicio': '08:00', 'fin': '17:00'},
      },
      'disponibilidad': [],
    },
    // Dermatología
    {
      'nombre': 'Dra. Sofía Hernández',
      'especialidad': 'Dermatología',
      'especialidadId': 'dermatologia',
      'descripcion': 'Dermatóloga especializada en acné y enfermedades de la piel',
      'experiencia': '9 años',
      'calificacion': 4.8,
      'telefono': '+1234567894',
      'email': 'sofia.hernandez@hospital.com',
      'horario': {
        'lunes': {'inicio': '08:00', 'fin': '17:00'},
        'martes': {'inicio': '08:00', 'fin': '17:00'},
        'miercoles': {'inicio': '08:00', 'fin': '17:00'},
        'jueves': {'inicio': '08:00', 'fin': '17:00'},
        'viernes': {'inicio': '08:00', 'fin': '17:00'},
      },
      'disponibilidad': [],
    },
    // Ginecología
    {
      'nombre': 'Dra. Carmen Torres',
      'especialidad': 'Ginecología',
      'especialidadId': 'ginecologia',
      'descripcion': 'Ginecóloga especializada en salud reproductiva y obstetricia',
      'experiencia': '14 años',
      'calificacion': 4.9,
      'telefono': '+1234567895',
      'email': 'carmen.torres@hospital.com',
      'horario': {
        'lunes': {'inicio': '08:00', 'fin': '17:00'},
        'martes': {'inicio': '08:00', 'fin': '17:00'},
        'miercoles': {'inicio': '08:00', 'fin': '17:00'},
        'jueves': {'inicio': '08:00', 'fin': '17:00'},
        'viernes': {'inicio': '08:00', 'fin': '17:00'},
      },
      'disponibilidad': [],
    },
    // Ortopedia
    {
      'nombre': 'Dr. Roberto Sánchez',
      'especialidad': 'Ortopedia',
      'especialidadId': 'ortopedia',
      'descripcion': 'Ortopedista especializado en cirugía de columna y traumatología',
      'experiencia': '16 años',
      'calificacion': 4.7,
      'telefono': '+1234567896',
      'email': 'roberto.sanchez@hospital.com',
      'horario': {
        'lunes': {'inicio': '08:00', 'fin': '17:00'},
        'martes': {'inicio': '08:00', 'fin': '17:00'},
        'miercoles': {'inicio': '08:00', 'fin': '17:00'},
        'jueves': {'inicio': '08:00', 'fin': '17:00'},
        'viernes': {'inicio': '08:00', 'fin': '17:00'},
      },
      'disponibilidad': [],
    },
    {
      'nombre': 'Dra. Patricia Morales',
      'especialidad': 'Ortopedia',
      'especialidadId': 'ortopedia',
      'descripcion': 'Especialista en medicina deportiva y lesiones articulares',
      'experiencia': '11 años',
      'calificacion': 4.8,
      'telefono': '+1234567897',
      'email': 'patricia.morales@hospital.com',
      'horario': {
        'lunes': {'inicio': '08:00', 'fin': '17:00'},
        'martes': {'inicio': '08:00', 'fin': '17:00'},
        'miercoles': {'inicio': '08:00', 'fin': '17:00'},
        'jueves': {'inicio': '08:00', 'fin': '17:00'},
        'viernes': {'inicio': '08:00', 'fin': '17:00'},
      },
      'disponibilidad': [],
    },
  ];

  print('\nCreando médicos...');
  for (var medico in medicos) {
    await firestore.collection('medicos').add(medico);
    print('✓ ${medico['nombre']} creado');
  }

  print('\n✓ Base de datos poblada exitosamente!');
}

