import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/ticket_service.dart';
import '../../auth/data/dummy_auth_service.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  String selectedCategory = 'Jaringan';
  String selectedPriority = 'Sedang';

  final List<String> categories = ['Jaringan', 'Perangkat', 'Akun', 'Lainnya'];
  final List<String> priorities = ['Rendah', 'Sedang', 'Tinggi'];

  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!DummyAuthService.canCreateTicket()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hanya User yang dapat membuat tiket'),
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> pickImageFromGallery() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void showImageSourcePicker() {
    if (!DummyAuthService.canCreateTicket()) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const accent = Color(0xFF2563EB);
    final iconBg = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pilih Sumber Gambar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kamera atau galeri',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                _BottomSheetOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Kamera',
                  subtitle: 'Ambil foto baru',
                  iconBg: iconBg,
                  border: border,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  isDark: isDark,
                  onTap: () async {
                    Navigator.pop(context);
                    await pickImageFromCamera();
                  },
                ),
                const SizedBox(height: 8),
                _BottomSheetOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Galeri',
                  subtitle: 'Pilih dari galeri',
                  iconBg: iconBg,
                  border: border,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  isDark: isDark,
                  onTap: () async {
                    Navigator.pop(context);
                    await pickImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void submitTicket() {
    if (!DummyAuthService.canCreateTicket()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya User yang dapat membuat tiket'),
        ),
      );
      return;
    }

    final title = titleController.text.trim();
    final desc = descController.text.trim();
    final currentUser = DummyAuthService.currentUser;

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan deskripsi wajib diisi')),
      );
      return;
    }

    if (title.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul minimal 5 karakter')),
      );
      return;
    }

    if (desc.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi terlalu pendek')),
      );
      return;
    }

    final newTicket = {
      'id': '#HD-00${TicketService.tickets.length + 1}',
      'title': title,
      'status': 'Open',
      'date': 'Hari ini',
      'category': selectedCategory,
      'priority': selectedPriority,
      'reporter': currentUser?.fullName ?? 'User',
      'description': desc,
      'assignee': 'Belum di-assign',
      'tracking': [
        {'title': 'Tiket Dibuat', 'time': 'Baru saja', 'done': true},
        {'title': 'Menunggu Penanganan', 'time': 'Baru saja', 'done': false},
        {'title': 'Diproses', 'time': '-', 'done': false},
        {'title': 'Selesai', 'time': '-', 'done': false},
      ],
    };

    TicketService.addTicket(newTicket);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tiket berhasil dibuat')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary =
    isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textMuted =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final fieldBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final iconBg = isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);
    const accent = Color(0xFF2563EB);
    final canCreate = DummyAuthService.canCreateTicket();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textMuted),
        title: Text(
          'Buat Tiket',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: textPrimary,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: canCreate
            ? LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Form Keluhan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Isi detail keluhan dengan lengkap agar helpdesk bisa menindaklanjuti lebih cepat.',
                                style: TextStyle(
                                  color:
                                  Colors.white.withOpacity(0.72),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Form Card ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DETAIL TIKET',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Judul
                        _FieldLabel(
                            label: 'Judul Keluhan',
                            textMuted: textMuted),
                        const SizedBox(height: 5),
                        TextField(
                          controller: titleController,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Masukkan judul keluhan',
                            hintStyle: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                            prefixIcon: Icon(Icons.title_rounded,
                                color: textMuted, size: 18),
                            filled: true,
                            fillColor: fieldBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: border, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: border, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: accent, width: 1.5),
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 10),

                        // Kategori
                        _FieldLabel(
                            label: 'Kategori', textMuted: textMuted),
                        const SizedBox(height: 5),
                        _StyledDropdown<String>(
                          value: selectedCategory,
                          items: categories,
                          prefixIcon: Icons.category_outlined,
                          fieldBg: fieldBg,
                          border: border,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          isDark: isDark,
                          onChanged: (value) => setState(
                                  () => selectedCategory = value!),
                        ),

                        const SizedBox(height: 10),

                        // Prioritas
                        _FieldLabel(
                            label: 'Prioritas', textMuted: textMuted),
                        const SizedBox(height: 5),
                        _StyledDropdown<String>(
                          value: selectedPriority,
                          items: priorities,
                          prefixIcon: Icons.flag_outlined,
                          fieldBg: fieldBg,
                          border: border,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          isDark: isDark,
                          onChanged: (value) => setState(
                                  () => selectedPriority = value!),
                        ),

                        const SizedBox(height: 10),

                        // Deskripsi
                        _FieldLabel(
                            label: 'Deskripsi Keluhan',
                            textMuted: textMuted),
                        const SizedBox(height: 5),
                        TextField(
                          controller: descController,
                          maxLines: 3,
                          minLines: 3,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText:
                            'Jelaskan keluhan secara detail...',
                            hintStyle: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w400),
                            filled: true,
                            fillColor: fieldBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: border, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: border, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: accent, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 10),

                        // Upload lampiran
                        _FieldLabel(
                            label: 'Lampiran (Opsional)',
                            textMuted: textMuted),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: showImageSourcePicker,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: fieldBg,
                              borderRadius:
                              BorderRadius.circular(12),
                              border:
                              Border.all(color: border, width: 1),
                            ),
                            child: selectedImage != null
                                ? Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                  child: Image.file(
                                    selectedImage!,
                                    height: 56,
                                    width: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        'Lampiran dipilih',
                                        style: TextStyle(
                                          color: textPrimary,
                                          fontWeight:
                                          FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Tap untuk ganti gambar',
                                        style: TextStyle(
                                          color: textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedImage =
                                            null;
                                          });
                                        },
                                        child: Row(
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons
                                                  .delete_outline_rounded,
                                              size: 14,
                                              color: const Color(
                                                  0xFFEF4444),
                                            ),
                                            const SizedBox(
                                                width: 4),
                                            const Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Color(
                                                    0xFFEF4444),
                                                fontSize: 12,
                                                fontWeight:
                                                FontWeight
                                                    .w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                                : Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    borderRadius:
                                    BorderRadius.circular(
                                        10),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 18,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Upload Lampiran',
                                        style: TextStyle(
                                          fontWeight:
                                          FontWeight.w700,
                                          color: textPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'Pilih dari kamera atau galeri',
                                        style: TextStyle(
                                          color: textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: textMuted,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Submit
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (titleController.text
                                .trim()
                                .isEmpty ||
                                descController.text
                                    .trim()
                                    .isEmpty)
                                ? null
                                : submitTicket,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: border,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Submit Tiket',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        )
            : Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E3A5F)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 26,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Akses Ditolak',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Halaman ini hanya dapat diakses oleh User untuk membuat tiket.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textMuted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: border, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kembali',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final Color textMuted;
  const _FieldLabel({required this.label, required this.textMuted});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: textMuted,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ─── Styled Dropdown ──────────────────────────────────────────────
class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final IconData prefixIcon;
  final Color fieldBg;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final bool isDark;
  final ValueChanged<T?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.prefixIcon,
    required this.fieldBg,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2563EB);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: fieldBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          Icon(prefixIcon, color: textMuted, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: textMuted, size: 20),
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                items: items
                    .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    item.toString(),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Sheet Option ──────────────────────────────────────────
class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final bool isDark;
  final VoidCallback onTap;

  const _BottomSheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF2563EB);
    final tileBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Material(
      color: tileBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}