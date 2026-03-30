import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/decision_provider.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  final List<String> _exampleDecisions = [
    "Fries or pizza? Which is better to buy for a party?",
    "Should I buy an electric car or a hybrid?",
    "iPhone vs Samsung Galaxy - which should I choose?",
    "Should I start a YouTube channel or a podcast?",
    "Python or JavaScript for web development?",
    "Should I rent an apartment or buy a house?",
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _analyzeAndNavigate() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });
    _focusNode.unfocus();

    final provider = context.read<DecisionProvider>();
    
    // Navigate to analysis screen first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalysisScreen(),
      ),
    ).then((_) {
      // When coming back, reset loading state
      setState(() {
        _isLoading = false;
      });
    });

    // Then start analysis
    await provider.analyzeDecision(_controller.text);
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Tiebreaker AI',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your intelligent decision-making assistant',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 60),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What decision do you need help with?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            hintText: 'e.g., Fries or pizza? Which is better to buy?',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          maxLines: 3,
                          onSubmitted: (_) => _analyzeAndNavigate(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _analyzeAndNavigate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Analyze Decision',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Try these examples:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _exampleDecisions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: 2,
                          child: ListTile(
                            leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                            title: Text(
                              _exampleDecisions[index],
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              _controller.text = _exampleDecisions[index];
                              _analyzeAndNavigate();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}