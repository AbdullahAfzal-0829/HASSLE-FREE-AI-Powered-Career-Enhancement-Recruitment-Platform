import 'package:flutter/material.dart';

class EmployerDashboardScreen extends StatelessWidget {
  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildStatsRow(),
          const SizedBox(height: 32),
          const Text(
            'Top Candidate Recommendations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildCandidateTable(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recruitment Overview',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage your job postings and top talent',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Post a New Job', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B26F2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Active Jobs', '12', Icons.business_center, Colors.blue),
        const SizedBox(width: 20),
        _buildStatCard('Total Applicants', '458', Icons.people, Colors.purple),
        const SizedBox(width: 20),
        _buildStatCard('Interviews Scheduled', '24', Icons.calendar_today, Colors.orange),
        const SizedBox(width: 20),
        _buildStatCard('Average Match', '84%', Icons.auto_awesome, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: DataTable(
        columnSpacing: 40,
        columns: const [
          DataColumn(label: Text('Candidate Name')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Skills')),
          DataColumn(label: Text('Score')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Action')),
        ],
        rows: [
          _buildCandidateRow('Muhammad Abdullah', 'Python Developer', ['Python', 'AI', 'NLP'], '9.2', 'Recommended'),
          _buildCandidateRow('Haris Naeem', 'Mobile Developer', ['Flutter', 'Dart', 'Firebase'], '8.8', 'Interested'),
          _buildCandidateRow('Ali Hassan', 'DevOps Engineer', ['AWS', 'Docker', 'K8s'], '8.5', 'In Review'),
          _buildCandidateRow('Waleed Tariq', 'Data Analyst', ['NLP', 'Pandas', 'ML'], '8.2', 'Shortlisted'),
        ],
      ),
    );
  }

  DataRow _buildCandidateRow(String name, String role, List<String> skills, String score, String status) {
    return DataRow(cells: [
      DataCell(Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=$name'),
          ),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      )),
      DataCell(Text(role)),
      DataCell(Row(
        children: skills.map((s) => Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
          child: Text(s, style: const TextStyle(fontSize: 10)),
        )).toList(),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: Text(score, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      )),
      DataCell(Text(status)),
      DataCell(TextButton(onPressed: () {}, child: const Text('View Profile'))),
    ]);
  }
}
