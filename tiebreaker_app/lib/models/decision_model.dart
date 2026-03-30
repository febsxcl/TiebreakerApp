class DecisionAnalysis {
  final String prosAndCons;
  final String comparisonTable;
  final String swotAnalysis;
  final bool isLoading;
  final String? error;

  DecisionAnalysis({
    required this.prosAndCons,
    required this.comparisonTable,
    required this.swotAnalysis,
    this.isLoading = false,
    this.error,
  });

  factory DecisionAnalysis.initial() {
    return DecisionAnalysis(
      prosAndCons: '',
      comparisonTable: '',
      swotAnalysis: '',
    );
  }

  factory DecisionAnalysis.loading() {
    return DecisionAnalysis(
      prosAndCons: '',
      comparisonTable: '',
      swotAnalysis: '',
      isLoading: true,
    );
  }

  DecisionAnalysis copyWith({
    String? prosAndCons,
    String? comparisonTable,
    String? swotAnalysis,
    bool? isLoading,
    String? error,
  }) {
    return DecisionAnalysis(
      prosAndCons: prosAndCons ?? this.prosAndCons,
      comparisonTable: comparisonTable ?? this.comparisonTable,
      swotAnalysis: swotAnalysis ?? this.swotAnalysis,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}