import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devhub/core/constants/app_constants.dart';
import 'package:devhub/features/dashboard/domain/entities/developer_metric.dart';
import '../providers/dashboard_providers.dart';

class DeveloperChart extends ConsumerWidget {
  final List<DeveloperMetric> metrics;

  const DeveloperChart({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMetric = ref.watch(selectedMetricProvider);
    final selectedMetricData = selectedMetric != null
        ? metrics.firstWhere(
          (m) => m.type == selectedMetric,
      orElse: () => metrics.first,
    )
        : metrics.first;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: metrics.map((metric) {
                final isSelected = metric.type == (selectedMetric ?? metrics.first.type);
                return Padding(
                  padding: const EdgeInsets.only(right: AppConstants.spaceSM),
                  child: ChoiceChip(
                    label: Text(metric.label),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(selectedMetricProvider.notifier).state = metric.type;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // Metric Value and Change
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selectedMetricData.value.toStringAsFixed(0)} ${selectedMetricData.unit}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedMetricData.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              _buildChangeIndicator(context, selectedMetricData),
            ],
          ),
          const SizedBox(height: AppConstants.spaceLG),

          // Chart
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _ChartPainter(
                data: selectedMetricData.chartData,
                color: theme.colorScheme.primary,
                textStyle: theme.textTheme.bodySmall!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(BuildContext context, DeveloperMetric metric) {
    final theme = Theme.of(context);
    final change = metric.value - metric.previousValue;
    final changePercent = metric.previousValue > 0
        ? ((change / metric.previousValue) * 100)
        : 0.0;
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSM,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${changePercent.abs().toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<ChartPoint> data;
  final Color color;
  final TextStyle textStyle;

  _ChartPainter({
    required this.data,
    required this.color,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Calculate bounds
    final minValue = data.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxValue = data.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;
    final padding = valueRange * 0.1;
    final adjustedMin = minValue - padding;
    final adjustedMax = maxValue + padding;
    final adjustedRange = adjustedMax - adjustedMin;

    // Draw grid lines
    const gridLines = 5;
    for (int i = 0; i <= gridLines; i++) {
      final y = size.height * (i / gridLines);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Create path for the line
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = (data[i].value - adjustedMin) / adjustedRange;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw filled area
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = (data[i].value - adjustedMin) / adjustedRange;
      final y = size.height - (normalizedValue * size.height);

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    // Draw labels
    if (data.length >= 2) {
      // Start date
      _drawText(
        canvas,
        _formatDate(data.first.date),
        Offset(0, size.height + 20),
        textStyle,
      );

      // End date
      _drawText(
        canvas,
        _formatDate(data.last.date),
        Offset(size.width - 40, size.height + 20),
        textStyle,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.textStyle != textStyle;
  }
}
