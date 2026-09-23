import 'package:flutter/material.dart';

import '../../core/mock_runtime/demo_session_store.dart';
import '../../mock_data/demo_patient_home.dart';
import '../../mock_data/demo_patients.dart';
import '../patient_appointments/patient_appointments_screen.dart';
import '../patient_clinics/patient_clinics_screen.dart';
import '../patient_documents/patient_documents_screen.dart';
import '../patient_home/patient_home_screen.dart';
import '../patient_profile/patient_profile_screen.dart';

class PatientShellPlaceholder extends StatefulWidget {
  const PatientShellPlaceholder({
    super.key,
    this.sessionStore,
    this.patientId,
    this.phone,
    this.patientName,
  });

  final DemoSessionStore? sessionStore;
  final String? patientId;
  final String? phone;
  final String? patientName;

  @override
  State<PatientShellPlaceholder> createState() =>
      _PatientShellPlaceholderState();
}

class _PatientShellPlaceholderState extends State<PatientShellPlaceholder> {
  late final DemoSessionStore _sessionStore;
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _sessionStore = widget.sessionStore ?? DemoSessionStore();
  }

  PatientHomeState get _homeState => switch (DemoPatientHome.stateForPatient(
    widget.patientId,
  )) {
    DemoPatientHomeState.upcomingAppointment =>
      PatientHomeState.upcomingAppointment,
    DemoPatientHomeState.completedAppointment =>
      PatientHomeState.completedAppointment,
    DemoPatientHomeState.noConnectedData => PatientHomeState.noConnectedData,
  };

  String get _profilePhone {
    final storedPhone = widget.phone;
    if (storedPhone != null && storedPhone.isNotEmpty) {
      return storedPhone;
    }
    for (final patient in DemoPatients.values) {
      if (patient.id == widget.patientId) {
        return patient.phone;
      }
    }
    return '+7 (921) 000-00-00';
  }

  String get _patientName {
    final storedName = widget.patientName;
    if (storedName != null && storedName.isNotEmpty) return storedName;
    for (final patient in DemoPatients.values) {
      if (patient.id == widget.patientId) return patient.name;
    }
    return 'Новый пациент';
  }

  String get _patientFirstName => _patientName.split(RegExp(r'\s+')).first;

  void _onNavigationSelected(int index) {
    if ((index < 0 || index > 4) || index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex == 1) {
      return PatientAppointmentsScreen(
        patientId: widget.patientId,
        patientName: _patientName,
        bottomNavigation: PatientBottomNavigation(
          selectedIndex: _selectedIndex,
          onSelected: _onNavigationSelected,
        ),
      );
    }

    if (_selectedIndex == 4) {
      return PatientProfileScreen(
        patientId: widget.patientId,
        patientName: _patientName,
        phone: _profilePhone,
        sessionStore: _sessionStore,
        onNavigationSelected: _onNavigationSelected,
      );
    }

    if (_selectedIndex == 2) {
      return PatientDocumentsScreen(
        patientName: _patientName,
        bottomNavigation: PatientBottomNavigation(
          selectedIndex: _selectedIndex,
          onSelected: _onNavigationSelected,
        ),
      );
    }

    if (_selectedIndex == 3) {
      return PatientClinicsScreen(
        bottomNavigation: PatientBottomNavigation(
          selectedIndex: _selectedIndex,
          onSelected: _onNavigationSelected,
        ),
      );
    }

    return PatientHomeScreen(
      patientId: widget.patientId,
      patientName: _patientFirstName,
      patientFullName: _patientName,
      homeState: _homeState,
      bottomNavigation: PatientBottomNavigation(
        selectedIndex: _selectedIndex,
        onSelected: _onNavigationSelected,
      ),
    );
  }
}
