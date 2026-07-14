import 'package:flutter/material.dart';
import '../core/config/api_config.dart';
import 'login_view.dart';
import 'dashboard_view.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  List<dynamic> _trainers = [];
  List<dynamic> _classes = [];
  List<dynamic> _memberships = [];
  Map<String, int> _stats = {};
  bool _loading = true;
  bool _connectionError = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _msgController = TextEditingController();
  bool _sending = false;

  static const _bg = Color(0xFF111113);
  static const _cardBg = Color(0xFF1C1C1E);
  static const _red = Color(0xFFFF3B30);
  static const _gray = Color(0xFFB0B0B5);
  static const _border = Color(0xFF3A3A3C);

  final _aboutKey = GlobalKey();
  final _membershipKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final auth = AuthService();
    final hasSession = await auth.verifyToken();
    if (hasSession && mounted) {
      final role = (await auth.getRole()) ?? 'ATLETA';
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => DashboardView(role: role)),
        );
      }
    }
  }

  Future<void> _loadData() async {
    final api = ApiService();
    bool anySuccess = false;
    try {
      final trainersRes = await api.get(ApiConfig.trainers);
      if (trainersRes.data is Map && trainersRes.data['data'] is List) { _trainers = trainersRes.data['data']; anySuccess = true; }
    } catch (_) {}
    try {
      final classesRes = await api.get(ApiConfig.classesAvailable);
      if (classesRes.data is Map && classesRes.data['data'] is List) { _classes = classesRes.data['data']; anySuccess = true; }
    } catch (_) {}
    try {
      final membersRes = await api.get(ApiConfig.membershipsEndpoint);
      if (membersRes.data is Map && membersRes.data['data'] is List) { _memberships = membersRes.data['data']; anySuccess = true; }
    } catch (_) {}
    try {
      final statsRes = await api.get('/api/public/stats');
      if (statsRes.data is Map && statsRes.data['data'] is Map) {
        _stats = Map<String, int>.from((statsRes.data['data'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
        anySuccess = true;
      }
    } catch (_) {}
    if (mounted) {
      _connectionError = !anySuccess && !_trainers.isNotEmpty && !_classes.isNotEmpty && !_memberships.isNotEmpty;
      setState(() => _loading = false);
    }
  }

  Future<void> _sendContact() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final msg = _msgController.text.trim();
    if (name.isEmpty || email.isEmpty || msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa nombre, email y mensaje')));
      return;
    }
    setState(() => _sending = true);
    try {
      await ApiService().post(ApiConfig.contact, data: {'name': name, 'email': email, 'phone': _phoneController.text.trim(), 'message': msg, 'website': ''});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mensaje enviado exitosamente!'), backgroundColor: Colors.green));
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _msgController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _sending = false);
  }

  void _goToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: _red, size: 22),
            const SizedBox(width: 6),
            FittedBox(child: Text('IRONCLADBOX', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1, color: Colors.white))),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _goToLogin,
              style: ElevatedButton.styleFrom(backgroundColor: _red, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
              child: const Text('Iniciar Sesion', style: TextStyle(fontSize: 11)),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _red),
                  SizedBox(height: 16),
                  Text('Conectando con el servidor...',
                      style: TextStyle(color: _gray, fontSize: 13)),
                  SizedBox(height: 4),
                  Text('Puede tomar hasta 2 minutos la primera vez',
                      style: TextStyle(color: _gray, fontSize: 11)),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_connectionError)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: Colors.red.shade800,
                            child: const Column(
                              children: [
                                Icon(Icons.cloud_off, color: Colors.white, size: 32),
                                SizedBox(height: 8),
                                Text('SIN CONEXION AL SERVIDOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                                SizedBox(height: 4),
                                Text('Verifica que el backend esté corriendo en la laptop\ny que el celular esté en el mismo WiFi', style: TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        _buildHero(w),
                      _buildAbout(w),
                      _buildClasses(w),
                      _buildTrainers(w),
                      _buildMemberships(w),
                      _buildContact(w),
                      _buildFooter(),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHero(double w) {
    final isSmall = w < 400;
    return Container(
      width: w,
      color: const Color(0xFF0D0D0F),
      padding: EdgeInsets.symmetric(vertical: isSmall ? 40 : 60, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: isSmall ? 45 : 60, color: _red),
          const SizedBox(height: 12),
          FittedBox(child: Text('BIENVENIDO A', style: TextStyle(color: _gray, fontSize: isSmall ? 12 : 14, fontWeight: FontWeight.w600, letterSpacing: 2))),
          const SizedBox(height: 6),
          FittedBox(child: Text('IRONCLADBOX', style: TextStyle(color: _red, fontSize: isSmall ? 32 : 44, fontWeight: FontWeight.w900, letterSpacing: 4))),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('FORJANDO ATLETAS EN EL CORAZON DE QUITO', style: TextStyle(color: _gray, fontSize: isSmall ? 10 : 12, letterSpacing: 1), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Scrollable.ensureVisible(_membershipKey.currentContext!, duration: const Duration(milliseconds: 500)),
                  style: ElevatedButton.styleFrom(backgroundColor: _red, padding: EdgeInsets.symmetric(horizontal: isSmall ? 14 : 20, vertical: 10)),
                  child: Text('COMENZAR AHORA', style: TextStyle(fontSize: isSmall ? 10 : 12)),
                ),
              ),
              SizedBox(width: isSmall ? 8 : 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Scrollable.ensureVisible(_aboutKey.currentContext!, duration: const Duration(milliseconds: 500)),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: _border), padding: EdgeInsets.symmetric(horizontal: isSmall ? 14 : 20, vertical: 10)),
                  child: Text('CONOCE MAS', style: TextStyle(fontSize: isSmall ? 10 : 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbout(double w) {
    final isSmall = w < 380;
    return Container(
      key: _aboutKey,
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          FittedBox(child: Text('SOBRE NOSOTROS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2))),
          Container(width: 50, height: 3, color: _red, margin: const EdgeInsets.only(top: 8, bottom: 10)),
          FittedBox(child: Text('EL MEJOR CROSSFIT DE QUITO', style: const TextStyle(color: _red, fontSize: 13, fontWeight: FontWeight.w700))),
          const SizedBox(height: 8),
          const Text('IroncladBox es mas que un gimnasio, es una comunidad dedicada a transformar vidas a traves del fitness funcional.', style: TextStyle(color: _gray, fontSize: 11, height: 1.4), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Nuestras instalaciones cuentan con el mejor equipo y un ambiente motivador donde atletas de todos los niveles pueden alcanzar sus objetivos.', style: TextStyle(color: _gray, fontSize: 11, height: 1.4), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _featureCard(Icons.fitness_center, 'Equipo', 'Instalaciones'),
            _featureCard(Icons.groups, 'Comunidad', 'Ambiente familiar'),
            _featureCard(Icons.verified, 'Coaches', 'Certificados'),
          ]),
          const SizedBox(height: 16),
          Wrap(spacing: isSmall ? 10 : 16, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _statCard(_stats['totalAthletes']?.toString() ?? '0', 'Atletas'),
            _statCard(_stats['activeAthletes']?.toString() ?? '0', 'Activos'),
            _statCard(_stats['totalTrainers']?.toString() ?? '2', 'Coaches'),
            _statCard(_stats['totalWODs']?.toString() ?? '0', 'WODs'),
            _statCard(_stats['totalMemberships']?.toString() ?? '4', 'Planes'),
          ]),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _red, size: 20),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
        Text(desc, style: const TextStyle(color: _gray, fontSize: 9), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        FittedBox(child: Text(value, style: const TextStyle(color: _red, fontSize: 20, fontWeight: FontWeight.w900))),
        Text(label, style: const TextStyle(color: _gray, fontSize: 9)),
      ]),
    );
  }

  Widget _buildClasses(double w) {
    final isSmall = w < 380;
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
      child: Column(children: [
        FittedBox(child: Text('NUESTRAS CLASES', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2))),
        Container(width: 50, height: 3, color: _red, margin: const EdgeInsets.only(top: 8, bottom: 6)),
        Text('Clases para todos los niveles', style: TextStyle(color: _gray, fontSize: isSmall ? 11 : 12)),
        const SizedBox(height: 14),
        _classes.isEmpty
            ? const Text('Cargando clases...', style: TextStyle(color: _gray))
            : Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: _classes.take(6).map<Widget>((c) => _classCard(w, c)).toList()),
      ]),
    );
  }

  Widget _classCard(double screenW, dynamic c) {
    final name = c['nombre'] ?? 'Clase';
    final hora = c['hora']?.toString();
    final horaShort = hora != null && hora.length >= 5 ? hora.substring(0, 5) : '';
    final trainer = c['entrenador_nombre'] ?? '';
    final cardW = screenW > 500 ? 220.0 : screenW * 0.42;
    return Container(
      width: cardW,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), textAlign: TextAlign.center),
        if (horaShort.isNotEmpty) Text(horaShort, style: const TextStyle(color: _red, fontWeight: FontWeight.w700, fontSize: 11)),
        if (trainer.isNotEmpty) Text(trainer, style: const TextStyle(color: _gray, fontSize: 9), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildTrainers(double w) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
      child: Column(children: [
        FittedBox(child: Text('NUESTRO EQUIPO', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2))),
        Container(width: 50, height: 3, color: _red, margin: const EdgeInsets.only(top: 8, bottom: 6)),
        const Text('Coaches certificados y apasionados', style: TextStyle(color: _gray, fontSize: 12)),
        const SizedBox(height: 14),
        _trainers.isEmpty
            ? const Text('Cargando entrenadores...', style: TextStyle(color: _gray))
            : Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: _trainers.take(4).map<Widget>((t) => _trainerCard(w, t)).toList()),
      ]),
    );
  }

  Widget _trainerCard(double screenW, dynamic t) {
    final fullName = '${t['nombre'] ?? ''} ${t['apellido'] ?? ''}'.trim();
    final especialidad = t['especialidad'] ?? '';
    final cardW = screenW > 500 ? 160.0 : screenW * 0.4;
    return Container(
      width: cardW,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.person, size: 32, color: _gray),
        const SizedBox(height: 4),
        Text(fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12), textAlign: TextAlign.center),
        if (especialidad.isNotEmpty) Text(especialidad, style: const TextStyle(color: _red, fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildMemberships(double w) {
    return Container(
      key: _membershipKey,
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
      child: Column(children: [
        FittedBox(child: Text('MEMBRESIAS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2))),
        Container(width: 50, height: 3, color: _red, margin: const EdgeInsets.only(top: 8, bottom: 6)),
        const Text('Elige el plan que mejor se adapte a ti', style: TextStyle(color: _gray, fontSize: 12)),
        const SizedBox(height: 14),
        _memberships.isEmpty
            ? const Text('Cargando membresias...', style: TextStyle(color: _gray))
            : Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: _memberships.map<Widget>((m) => _membershipCard(w, m)).toList()),
      ]),
    );
  }

  Widget _membershipCard(double screenW, dynamic m) {
    final cardW = screenW > 500 ? 170.0 : screenW * 0.4;
    return Container(
      width: cardW,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: _red, width: 1.5)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        FittedBox(child: Text(m['nombre'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14))),
        const SizedBox(height: 2),
        FittedBox(child: Text('\$${m['precio'] ?? '0'}', style: const TextStyle(color: _red, fontSize: 22, fontWeight: FontWeight.w900))),
        Text('${m['duracion_dias'] ?? 0} dias', style: const TextStyle(color: _gray, fontSize: 10)),
        if (m['beneficios'] != null) const SizedBox(height: 4),
        if (m['beneficios'] != null)
          ...(m['beneficios'].toString().split(',')).take(3).map((b) => Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(b.trim(), style: const TextStyle(color: _gray, fontSize: 9), textAlign: TextAlign.center),
              )),
      ]),
    );
  }

  Widget _buildContact(double w) {
    return Container(
      width: w,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      child: Column(children: [
        FittedBox(child: Text('CONTACTANOS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2))),
        Container(width: 50, height: 3, color: _red, margin: const EdgeInsets.only(top: 8, bottom: 6)),
        const Text('Estamos aqui para ayudarte', style: TextStyle(color: _gray, fontSize: 11)),
        const SizedBox(height: 14),
        _infoRow(Icons.location_on, 'Ubicacion', 'Quito, Ecuador'),
        _infoRow(Icons.phone, 'Telefono', '+593 99 666 6672'),
        _infoRow(Icons.email, 'Email', 'info@ironcladbox.com'),
        _infoRow(Icons.access_time, 'Horarios', 'Lun-Vie: 06:00-21:00 | Sab: 08:00-14:00'),
        const SizedBox(height: 14),
        const Align(alignment: Alignment.centerLeft, child: Text('Envianos un mensaje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
        const SizedBox(height: 8),
        TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Nombre completo', hintStyle: TextStyle(color: _gray), isDense: true), style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        TextField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email', hintStyle: TextStyle(color: _gray), isDense: true), style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        TextField(controller: _phoneController, decoration: const InputDecoration(hintText: 'Telefono', hintStyle: TextStyle(color: _gray), isDense: true), style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 6),
        TextField(controller: _msgController, maxLines: 3, decoration: const InputDecoration(hintText: 'Mensaje', hintStyle: TextStyle(color: _gray), isDense: true), style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 10),
        SizedBox(width: w, child: ElevatedButton(
          onPressed: _sending ? null : _sendContact,
          child: _sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('ENVIAR MENSAJE'),
        )),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, color: _red, size: 18),
        const SizedBox(width: 8),
        Flexible(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
            Text(value, style: const TextStyle(color: _gray, fontSize: 10), overflow: TextOverflow.ellipsis, maxLines: 2),
          ],
        )),
      ]),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A0A0C),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(children: [
        const Text('IRONCLADBOX', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)),
        const SizedBox(height: 2),
        const Text('Forjando atletas desde 2024', style: TextStyle(color: _gray, fontSize: 10)),
        const SizedBox(height: 8),
        Wrap(spacing: 12, alignment: WrapAlignment.center, children: [
          TextButton(onPressed: () {}, child: const Text('FB', style: TextStyle(color: _red, fontSize: 11))),
          TextButton(onPressed: () {}, child: const Text('IG', style: TextStyle(color: _red, fontSize: 11))),
          TextButton(onPressed: () {}, child: const Text('WA', style: TextStyle(color: _red, fontSize: 11))),
          TextButton(onPressed: () {}, child: const Text('YT', style: TextStyle(color: _red, fontSize: 11))),
        ]),
        const SizedBox(height: 6),
        const Text('Lun-Vie: 06:00-21:00 | Sab: 08:00-14:00 | Dom: Cerrado', style: TextStyle(color: _gray, fontSize: 9), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        ElevatedButton.icon(onPressed: _goToLogin, icon: const Icon(Icons.login, size: 14), label: const Text('INICIAR SESION'), style: ElevatedButton.styleFrom(backgroundColor: _red, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), textStyle: const TextStyle(fontSize: 11))),
        const SizedBox(height: 8),
        const Text('(c) 2026 IroncladBox CrossFit', style: TextStyle(color: _gray, fontSize: 9)),
      ]),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _msgController.dispose();
    super.dispose();
  }
}
