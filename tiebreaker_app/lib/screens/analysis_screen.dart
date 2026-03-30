import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/decision_provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Reset when going back
            context.read<DecisionProvider>().reset();
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.thumbs_up_down), text: 'Pros & Cons'),
            Tab(icon: Icon(Icons.table_chart), text: 'Comparison'),
            Tab(icon: Icon(Icons.analytics), text: 'SWOT'),
          ],
        ),
      ),
      body: Consumer<DecisionProvider>(
        builder: (context, provider, child) {
          if (provider.analysis.error != null) {
            return _buildErrorCard(provider.analysis.error!);
          }
          
          if (provider.analysis.isLoading) {
            return _buildLoadingCard();
          }
          
          if (!provider.hasResults) {
            return _buildEmptyState();
          }
          
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.question_answer, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.currentPrompt,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMarkdownCard(provider.analysis.prosAndCons, Colors.green.shade50),
                    _buildMarkdownCard(provider.analysis.comparisonTable, Colors.blue.shade50),
                    _buildMarkdownCard(provider.analysis.swotAnalysis, Colors.amber.shade50),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<DecisionProvider>().reset();
          Navigator.pop(context);
        },
        icon: const Icon(Icons.refresh),
        label: const Text('New Decision'),
      ),
    );
  }

  Widget _buildMarkdownCard(String content, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: MarkdownBody(
          data: content.isEmpty ? 'No analysis available yet. Please wait or try again.' : content,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontSize: 15, height: 1.5),
            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            h4: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            listBullet: const TextStyle(fontSize: 15),
            tableHead: const TextStyle(fontWeight: FontWeight.bold),
            tableBorder: TableBorder.all(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Center(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                '🤔 Analyzing your decision...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Gemini AI is working on:\n✓ Pros & Cons\n✓ Comparison Table\n✓ SWOT Analysis',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Center(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Unable to analyze decision',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final provider = context.read<DecisionProvider>();
                  provider.analyzeDecision(provider.currentPrompt);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tips_and_updates, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No analysis yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please go back and enter a decision to analyze.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}