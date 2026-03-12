import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =====================
            // 1) CONTAINER (Header)
            // =====================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hai, Ocha 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Selamat datang di dashboard modul 2",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================
            // 2) ROW + COLUMN (Info Cards)
            // =====================
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: "List",
                    value: "Selesai",
                    icon: Icons.list_alt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    title: "Set",
                    value: "Selesai",
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: "Map",
                    value: "Selesai",
                    icon: Icons.map_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    title: "UI",
                    value: "Proses",
                    icon: Icons.dashboard_customize_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // =====================
            // 3) STACK (Banner)
            // =====================
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    top: 16,
                    child: Text(
                      "Tips Hari Ini",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    top: 48,
                    right: 16,
                    child: Text(
                      "Latihan sedikit tiap hari bikin cepat paham 💪",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Icon(Icons.lightbulb, size: 40, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =====================
            // 4) GRIDVIEW (Menu)
            // =====================
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Menu",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: const [
                _MenuTile(icon: Icons.list, label: "List"),
                _MenuTile(icon: Icons.check_box_outlined, label: "Set"),
                _MenuTile(icon: Icons.map, label: "Map"),
                _MenuTile(icon: Icons.design_services, label: "UI/UX"),
              ],
            ),

            const SizedBox(height: 16),

            // =====================
            // 5) LISTVIEW (Aktivitas)
            // =====================
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Aktivitas Terakhir",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 10),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _ActivityTile(
                  title: "Selesai List Input",
                  subtitle: "Tampil/Ubah/Hapus by index",
                  icon: Icons.list_alt,
                ),
                _ActivityTile(
                  title: "Selesai Set Input",
                  subtitle: "Tambah/Hapus/Cek data",
                  icon: Icons.check_circle_outline,
                ),
                _ActivityTile(
                  title: "Selesai Map Input",
                  subtitle: "Data mahasiswa (nim, nama, jurusan, ipk)",
                  icon: Icons.map_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}