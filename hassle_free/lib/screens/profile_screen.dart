import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<Map<String, dynamic>> _badges = [
    {'title': 'Top Technical', 'icon': Icons.code, 'color': Colors.blue},
    {'title': 'Analytical Expert', 'icon': Icons.analytics, 'color': Colors.purple},
    {'title': 'Effective Communicator', 'icon': Icons.chat_bubble, 'color': Colors.green},
    {'title': 'Fast Learner', 'icon': Icons.bolt, 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width >= 1100;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWeb ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(isWeb),
          const SizedBox(height: 32),
          _buildEmployabilityScore(isWeb),
          const SizedBox(height: 32),
          const Text(
            'Achievements & Badges',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBadgeGrid(isWeb),
          const SizedBox(height: 32),
          const Text(
            'Skills & Endorsements',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSkillsSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isWeb) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: const NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Sarah'),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sarah Johnson',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Lahore, Punjab, Pakistan'),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Senior Python Developer | AI Enthusiast',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatMini('12', 'Projects'),
                    const SizedBox(width: 24),
                    _buildStatMini('4.9', 'AI Rating'),
                    const SizedBox(width: 24),
                    _buildStatMini('24', 'Applied'),
                  ],
                ),
              ],
            ),
          ),
          if (isWeb)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B26F2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Edit Profile'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatMini(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmployabilityScore(bool isWeb) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3B26F2), Color(0xFF9042F6)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Employability Score',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your score is based on technical skills, interview performance, and profile completeness.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildScorePart('Technical', '9.2'),
                    const SizedBox(width: 24),
                    _buildScorePart('Soft Skills', '8.5'),
                    const SizedBox(width: 24),
                    _buildScorePart('Interview', '8.8'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Column(
              children: [
                Text('8.8', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                Text('/ 10', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePart(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildBadgeGrid(bool isWeb) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _badges.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWeb ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        var b = _badges[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            border: Border.all(color: b['color'].withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(b['icon'], color: b['color'], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  b['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillsSection() {
    final skills = ['Python', 'Django', 'FastAPI', 'Flutter', 'TensorFlow', 'PostgreSQL', 'Docker', 'AWS', 'Agile'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: skills
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: Colors.blue, size: 16),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
