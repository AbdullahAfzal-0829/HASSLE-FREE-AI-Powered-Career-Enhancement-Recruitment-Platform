import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  bool _isInterviewStarted = false;
  bool _isAnalyzing = false;
  int _currentQuestionIndex = 0;
  List<dynamic> _backendFeedback = [];

  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _isCameraMuted = false;
  bool _isMicMuted = false;
  final List<String> _questions = [
    "Tell me about yourself and your background.",
    "Why are you interested in this role?",
    "Describe a challenging project you worked on and how you handled it.",
    "What are your greatest strengths and weaknesses?",
    "Where do you see yourself in five years?",
  ];

  // Simulated real-time metrics
  double _clarity = 0.0;
  double _confidence = 0.0;
  double _technicalDepth = 0.0;
  double _communication = 0.0;

  Timer? _metricsTimer;

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isDenied || micStatus.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera and Microphone permissions are required.'),
          ),
        );
      }
    }
  }

  Future<void> _startInterview() async {
    // 1. Request permissions first
    await _requestPermissions();
    if (!(await Permission.camera.isGranted) ||
        !(await Permission.microphone.isGranted)) {
      return;
    }

    // 2. Initialize Camera
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Try to find the front camera specifically for interviews
        CameraDescription selectedCamera = cameras.first;
        try {
          selectedCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
          );
        } catch (_) {}

        _cameraController = CameraController(
          selectedCamera,
          ResolutionPreset.medium,
        );
        _initializeControllerFuture = _cameraController!.initialize();
        await _initializeControllerFuture;
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }

    setState(() {
      _isInterviewStarted = true;
      _isAnalyzing = false;
      _backendFeedback = [];
      _currentQuestionIndex = 0;
      _clarity = 0.85;
      _confidence = 0.78;
      _technicalDepth = 0.92;
      _communication = 0.80;
    });

    // Simulate real-time fluctuations
    _metricsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _isInterviewStarted) {
        setState(() {
          _clarity = (0.7 + (DateTime.now().second % 30) / 100).clamp(0, 1);
          _confidence = (0.6 + (DateTime.now().second % 40) / 100).clamp(0, 1);
        });
      }
    });
  }

  Future<void> _finishInterview() async {
    setState(() {
      _isInterviewStarted = false;
      _isAnalyzing = true;
    });
    _metricsTimer?.cancel();
    _cameraController?.dispose();
    _cameraController = null;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5002/api/analyze-interview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clarity': _clarity,
          'confidence': _confidence,
          'technical_depth': _technicalDepth,
          'communication': _communication,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _backendFeedback = data['detailed_feedback'];
        });
      }
    } catch (e) {
      debugPrint("Error calling backend: $e");
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  void dispose() {
    _metricsTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
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
          const Text(
            'AI Mock Interview',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Practice your interview skills with AI-powered feedback',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Interview Area
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // AI Interviewer Placeholder
                        Expanded(
                          child: _buildVideoPlaceholder(
                            'AI Interviewer',
                            'Sarah AI',
                            const Color(0xFFE0E7FF),
                            Icons.auto_awesome,
                            true,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // User Camera Placeholder
                        Expanded(
                          child: _buildVideoPlaceholder(
                            'You',
                            _isCameraMuted
                                ? 'Camera is OFF'
                                : 'Your camera feed',
                            const Color(0xFF1E293B),
                            Icons.person,
                            false,
                            isCamera: true,
                            child:
                                (_isInterviewStarted &&
                                    _cameraController != null)
                                ? FutureBuilder<void>(
                                    future: _initializeControllerFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        return Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CameraPreview(_cameraController!),
                                            if (_isCameraMuted)
                                              Container(
                                                color: const Color(0xFF1E293B),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.videocam_off,
                                                        color: Colors.white,
                                                        size: 48,
                                                      ),
                                                      const SizedBox(
                                                        height: 12,
                                                      ),
                                                      const Text(
                                                        'Camera is OFF',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        );
                                      }
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Current Question Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3B26F2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _questions[_currentQuestionIndex],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _isCameraMuted
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                                    : const Color(0xFFF1F5F9),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isCameraMuted = !_isCameraMuted;
                                      if (_cameraController != null) {
                                        if (_isCameraMuted) {
                                          _cameraController?.pausePreview();
                                        } else {
                                          _cameraController?.resumePreview();
                                        }
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    _isCameraMuted
                                        ? Icons.videocam_off
                                        : Icons.videocam,
                                    size: 18,
                                    color: _isCameraMuted
                                        ? const Color(0xFFEF4444)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              CircleAvatar(
                                backgroundColor: _isMicMuted
                                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                                    : const Color(0xFFF1F5F9),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isMicMuted = !_isMicMuted;
                                    });
                                  },
                                  icon: Icon(
                                    _isMicMuted ? Icons.mic_off : Icons.mic,
                                    size: 18,
                                    color: _isMicMuted
                                        ? const Color(0xFFEF4444)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (!_isInterviewStarted)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B26F2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _startInterview,
                                  icon: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Start Interview',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isInterviewStarted = false;
                                        });
                                      },
                                      child: const Text('End Interview'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF3B26F2,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (_currentQuestionIndex <
                                              _questions.length - 1) {
                                            _currentQuestionIndex++;
                                          } else {
                                            _finishInterview();
                                          }
                                        });
                                      },
                                      child: const Text(
                                        'Next Question',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Feedback Panel
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Feedback',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'AI is analyzing your response',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 32),
                      if (!_isInterviewStarted)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.grey[300],
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Start the interview to see\nlive feedback',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            _buildProgressMetric('Clarity', _clarity),
                            const SizedBox(height: 20),
                            _buildProgressMetric('Confidence', _confidence),
                            const SizedBox(height: 20),
                            _buildProgressMetric(
                              'Technical Depth',
                              _technicalDepth,
                            ),
                            const SizedBox(height: 20),
                            _buildProgressMetric(
                              'Communication',
                              _communication,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          if (_isAnalyzing)
            const Center(child: CircularProgressIndicator())
          else if (!_isInterviewStarted && _clarity > 0) ...[
            const Text(
              'Detailed Feedback',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (_backendFeedback.isNotEmpty)
              GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 3,
                ),
                itemCount: _backendFeedback.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final f = _backendFeedback[index];
                  return _buildFeedbackCard(
                    f['label'],
                    '${f['score'].toInt()}/100',
                    f['text'],
                    f['label'] == 'Communication' ? Colors.green : Colors.blue,
                  );
                },
              )
            else
              const Text('No detailed feedback available yet.'),
            const SizedBox(height: 32),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B26F2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'View Full Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _startInterview,
                  child: const Text(
                    'Practice Again',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
            'AI Mock Interview',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Practice your interview skills with AI-powered feedback',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildVideoPlaceholder(
            'Interview Module',
            _isCameraMuted
                ? 'Camera is OFF'
                : (_isInterviewStarted ? 'Active Session' : 'Ready to start?'),
            const Color(0xFF1E293B),
            Icons.videocam,
            false,
            isCamera: true,
            child: (_isInterviewStarted && _cameraController != null)
                ? FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CameraPreview(_cameraController!),
                            if (_isCameraMuted)
                              Container(
                                color: const Color(0xFF1E293B),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.videocam_off,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Camera is OFF',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }
                    },
                  )
                : null,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: Color(0xFF3B26F2), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Real-time Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildProgressMetric('Clarity', _clarity),
                const SizedBox(height: 16),
                _buildProgressMetric('Confidence', _confidence),
                const SizedBox(height: 16),
                _buildProgressMetric('Technical Depth', _technicalDepth),
                const SizedBox(height: 16),
                _buildProgressMetric('Communication', _communication),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (!_isInterviewStarted)
            ElevatedButton(
              onPressed: _startInterview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B26F2),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Interview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _questions[_currentQuestionIndex],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _isCameraMuted
                          ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _isCameraMuted = !_isCameraMuted;
                            if (_cameraController != null) {
                              if (_isCameraMuted) {
                                _cameraController?.pausePreview();
                              } else {
                                _cameraController?.resumePreview();
                              }
                            }
                          });
                        },
                        icon: Icon(
                          _isCameraMuted ? Icons.videocam_off : Icons.videocam,
                          size: 18,
                          color: _isCameraMuted
                              ? const Color(0xFFEF4444)
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: _isMicMuted
                          ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _isMicMuted = !_isMicMuted;
                          });
                        },
                        icon: Icon(
                          _isMicMuted ? Icons.mic_off : Icons.mic,
                          size: 18,
                          color: _isMicMuted
                              ? const Color(0xFFEF4444)
                              : Colors.black87,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isInterviewStarted = false;
                        });
                      },
                      child: const Text(
                        'End',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_currentQuestionIndex < _questions.length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    } else {
                      _finishInterview();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B26F2),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1
                        ? 'Next Question'
                        : 'Finish & Analyze',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder(
    String label,
    String subtitle,
    Color bgColor,
    IconData icon,
    bool isLive, {
    bool isCamera = false,
    Widget? child,
  }) {
    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          ?child,
          if (child == null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCamera && !_isInterviewStarted)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 32,
                      ),
                    )
                  else if (isCamera && _isInterviewStarted)
                    const Icon(Icons.person, color: Colors.white54, size: 64)
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B26F2), Color(0xFF9042F6)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: isCamera ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isCamera ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          if (isLive)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isCamera)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressMetric(String label, double value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B26F2)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackCard(
    String label,
    String score,
    String detail,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(score, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
