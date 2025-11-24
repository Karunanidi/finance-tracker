import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_recommendation_service.g.dart';

@riverpod
AiRecommendationService aiRecommendationService(Ref ref) {
  return AiRecommendationService();
}

class AiRecommendationService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  late final GenerativeModel _model;

  AiRecommendationService() {
    debugPrint(
      'AiRecommendationService initialized. API Key present: ${_apiKey.isNotEmpty}',
    );
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
  }

  /// Generate spending recommendation based on financial data
  Future<SpendingRecommendation> generateRecommendation({
    required double totalIncome,
    required double totalExpenses,
    required double currentBalance,
    required Map<String, double> categoryBreakdown,
    required int daysInMonth,
    required int daysRemaining,
  }) async {
    if (_apiKey.isEmpty) {
      // Fallback to rule-based recommendation if no API key
      return _generateRuleBasedRecommendation(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        currentBalance: currentBalance,
        daysInMonth: daysInMonth,
        daysRemaining: daysRemaining,
      );
    }

    try {
      final prompt = _buildPrompt(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        currentBalance: currentBalance,
        categoryBreakdown: categoryBreakdown,
        daysInMonth: daysInMonth,
        daysRemaining: daysRemaining,
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return _parseAiResponse(
        response.text ?? '',
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        currentBalance: currentBalance,
        daysRemaining: daysRemaining,
      );
    } catch (e) {
      // Fallback to rule-based if AI fails
      return _generateRuleBasedRecommendation(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        currentBalance: currentBalance,
        daysInMonth: daysInMonth,
        daysRemaining: daysRemaining,
      );
    }
  }

  String _buildPrompt({
    required double totalIncome,
    required double totalExpenses,
    required double currentBalance,
    required Map<String, double> categoryBreakdown,
    required int daysInMonth,
    required int daysRemaining,
  }) {
    final categoryText = categoryBreakdown.entries
        .map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}')
        .join(', ');

    return '''
You are a financial advisor AI. Analyze the following financial data and provide a spending recommendation.

Financial Data:
- Monthly Income: \$${totalIncome.toStringAsFixed(2)}
- Total Expenses So Far: \$${totalExpenses.toStringAsFixed(2)}
- Current Balance: \$${currentBalance.toStringAsFixed(2)}
- Days in Month: $daysInMonth
- Days Remaining: $daysRemaining
- Category Breakdown: $categoryText

Task: Calculate a "safe zone" daily spending limit for the remaining days to maintain financial health.

Rules:
1. Recommend saving at least 20% of monthly income
2. Consider current spending patterns
3. Account for days remaining in the month
4. Provide a realistic daily spending limit
5. Give a brief, encouraging message (max 50 words)

Response Format (JSON):
{
  "dailyLimit": <number>,
  "message": "<brief encouraging message>",
  "healthStatus": "<healthy|warning|critical>"
}

Respond ONLY with valid JSON, no additional text.
''';
  }

  SpendingRecommendation _parseAiResponse(
    String responseText, {
    required double totalIncome,
    required double totalExpenses,
    required double currentBalance,
    required int daysRemaining,
  }) {
    try {
      // Try to extract JSON from response
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonText = responseText.substring(jsonStart, jsonEnd);
        // Simple parsing (you might want to use dart:convert for production)

        // Extract dailyLimit
        final dailyLimitMatch = RegExp(
          r'"dailyLimit"\s*:\s*(\d+\.?\d*)',
        ).firstMatch(jsonText);
        final dailyLimit = dailyLimitMatch != null
            ? double.parse(dailyLimitMatch.group(1)!)
            : _calculateRuleBasedDailyLimit(currentBalance, daysRemaining);

        // Extract message
        final messageMatch = RegExp(
          r'"message"\s*:\s*"([^"]*)"',
        ).firstMatch(jsonText);
        final message =
            messageMatch?.group(1) ?? 'Keep tracking your spending!';

        // Extract healthStatus
        final statusMatch = RegExp(
          r'"healthStatus"\s*:\s*"([^"]*)"',
        ).firstMatch(jsonText);
        final statusText = statusMatch?.group(1) ?? 'healthy';

        final healthStatus = _parseHealthStatus(statusText);

        return SpendingRecommendation(
          dailySpendingLimit: dailyLimit,
          message: message,
          healthStatus: healthStatus,
        );
      }
    } catch (e) {
      // Parsing failed, use fallback
    }

    // Fallback
    return _generateRuleBasedRecommendation(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      currentBalance: currentBalance,
      daysInMonth: 30,
      daysRemaining: daysRemaining,
    );
  }

  SpendingRecommendation _generateRuleBasedRecommendation({
    required double totalIncome,
    required double totalExpenses,
    required double currentBalance,
    required int daysInMonth,
    required int daysRemaining,
  }) {
    // Rule-based calculation
    final targetSavings = totalIncome * 0.2; // 20% savings goal
    final availableForSpending = currentBalance - targetSavings;
    final dailyLimit = daysRemaining > 0
        ? availableForSpending / daysRemaining
        : 0.0;

    // Determine health status
    final spendingRate = totalIncome > 0 ? totalExpenses / totalIncome : 0.0;
    final FinancialHealthStatus healthStatus;
    final String message;

    if (spendingRate < 0.7) {
      healthStatus = FinancialHealthStatus.healthy;
      message = 'Great job! You\'re on track with your spending goals.';
    } else if (spendingRate < 0.9) {
      healthStatus = FinancialHealthStatus.warning;
      message = 'Watch your spending! Try to cut back on non-essentials.';
    } else {
      healthStatus = FinancialHealthStatus.critical;
      message = 'Alert! You\'re spending too much. Review your expenses now.';
    }

    return SpendingRecommendation(
      dailySpendingLimit: dailyLimit.clamp(0, double.infinity),
      message: message,
      healthStatus: healthStatus,
    );
  }

  double _calculateRuleBasedDailyLimit(
    double currentBalance,
    int daysRemaining,
  ) {
    final targetSavings = currentBalance * 0.2;
    final availableForSpending = currentBalance - targetSavings;
    return daysRemaining > 0 ? availableForSpending / daysRemaining : 0.0;
  }

  FinancialHealthStatus _parseHealthStatus(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return FinancialHealthStatus.healthy;
      case 'warning':
        return FinancialHealthStatus.warning;
      case 'critical':
        return FinancialHealthStatus.critical;
      default:
        return FinancialHealthStatus.healthy;
    }
  }
}

enum FinancialHealthStatus { healthy, warning, critical }

class SpendingRecommendation {
  final double dailySpendingLimit;
  final String message;
  final FinancialHealthStatus healthStatus;

  SpendingRecommendation({
    required this.dailySpendingLimit,
    required this.message,
    required this.healthStatus,
  });

  Color get statusColor {
    switch (healthStatus) {
      case FinancialHealthStatus.healthy:
        return const Color(0xFF10B981); // Green
      case FinancialHealthStatus.warning:
        return const Color(0xFFF59E0B); // Orange
      case FinancialHealthStatus.critical:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData get statusIcon {
    switch (healthStatus) {
      case FinancialHealthStatus.healthy:
        return Icons.check_circle;
      case FinancialHealthStatus.warning:
        return Icons.warning;
      case FinancialHealthStatus.critical:
        return Icons.error;
    }
  }
}
