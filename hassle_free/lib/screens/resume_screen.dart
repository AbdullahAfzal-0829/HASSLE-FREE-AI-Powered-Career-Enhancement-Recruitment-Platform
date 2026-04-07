import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class ResumeScreen extends StatefulWidget {
  final Function(String)? onNameExtracted;
  const ResumeScreen({super.key, this.onNameExtracted});

  @override
  State<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends State<ResumeScreen> {
  bool _isUploading = false;
  bool _isAnalyzed = false;
  double _uploadProgress = 0.0;

  // Real data from API
  String _filename = "";
  String _category = "Web Developer";
  String _extractedName = "";
  List<String> _skills = [];
  String _textPreview = "";

  Future<void> _pickAndUploadResume() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
      withData: true, // Needed for Web and small files
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _isUploading = true;
        _isAnalyzed = false;
        _uploadProgress = 0.1;
        _filename = file.name;
      });

      try {
        // Prepare multipart request
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:5002/api/upload-resume'),
        );

        if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'resume',
              file.bytes!,
              filename: file.name,
            ),
          );
        } else if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath('resume', file.path!),
          );
        }

        // Send request
        var streamedResponse = await request.send();

        setState(() {
          _uploadProgress = 0.7;
        });

        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          setState(() {
            _isUploading = false;
            _isAnalyzed = true;
            _uploadProgress = 1.0;
            _category = data['category'] ?? "Unknown";
            _extractedName = data['name'] ?? "User";
            _skills = List<String>.from(data['detected_skills'] ?? []);
            _textPreview = data['text_preview'] ?? "";
          });
          if (widget.onNameExtracted != null) {
            widget.onNameExtracted!(_extractedName);
          }
        } else {
          throw Exception("Server error: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return _buildMobileLayout();
        } else {
          return _buildWebLayout();
        }
      },
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFF06B6D4),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'AI-Powered Analysis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Resume Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload your resume and let our AI extract your skills, experience, and\nprovide insights to boost your career',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _buildBannerStat('5sec', 'Analysis Time'),
                    const SizedBox(width: 40),
                    _buildBannerStat('95%', 'Accuracy'),
                    const SizedBox(width: 40),
                    _buildBannerStat('50+', 'Data Points'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildUploadCard(isWeb: true),
                    if (_isAnalyzed) ...[
                      const SizedBox(height: 24),
                      _buildPreviewCard(),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: _isAnalyzed
                    ? _buildAnalysisResults()
                    : _buildEmptyResultsPlaceholder(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resume Analysis',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your resume and let AI do the magic',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildUploadCard(isWeb: false),
          if (_isAnalyzed) ...[
            const SizedBox(height: 24),
            _buildMobileInsights(),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadCard({required bool isWeb}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Resume',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (!_isAnalyzed && !_isUploading)
            GestureDetector(
              onTap: _pickAndUploadResume,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF3B26F2).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFF8FAFC),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B26F2), Color(0xFF9042F6)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.upload_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Drop your resume here',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'or click to browse',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickAndUploadResume,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B26F2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Choose File',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Supported formats: PDF, DOCX',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else if (_isUploading)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analyzing resume...',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF3B26F2),
                  ),
                  minHeight: 8,
                ),
              ],
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Resume uploaded successfully!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              _filename,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _isAnalyzed = false),
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => setState(() => _isAnalyzed = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey.shade300),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Upload New Resume'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description_outlined, color: Colors.grey),
              SizedBox(width: 12),
              Text(
                'Resume Preview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            _textPreview.isEmpty ? "No preview available" : _textPreview,
            style: const TextStyle(color: Colors.grey, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Analysis Results',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildAISummary(),
              const SizedBox(height: 32),
              const Text(
                'Detected Skills',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills
                    .map(
                      (s) => Chip(
                        label: Text(s, style: const TextStyle(fontSize: 12)),
                        backgroundColor: const Color(0xFFF1F5F9),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              if (_skills.isEmpty)
                const Text(
                  "No skills detected",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAISummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B26F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Prediction',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'This resume belongs to: $_extractedName',
                  style: const TextStyle(
                    color: Color(0xFF3B26F2),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Classified as: $_category',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            'No Analysis Yet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your resume to see AI-powered insights and skill analysis',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF3B26F2), size: 20),
              SizedBox(width: 12),
              Text(
                'AI Result',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Name: $_extractedName',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B26F2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Category: $_category',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_skills.join(", "), style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBannerStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
