// lib/features/dashboard/presentation/widgets/developer_chart.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/developer_metric.dart';
import '../providers/dashboard_providers.dart';

class DeveloperChart extends ConsumerStatefulWidget {
  final List<DeveloperMetric> metrics;

  const DeveloperChart({super.key, required this.metrics});

  @override
  ConsumerState<DeveloperChart> createState() => _DeveloperChartState();
}

class _DeveloperChartState extends ConsumerState<DeveloperChart> {
  late ScrollController _scrollController;
  final Map<MetricType, GlobalKey> _chipKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Initialize keys for each metric
    for (final metric in widget.metrics) {
      _chipKeys[metric.type] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedChip(MetricType selectedType) {
    final key = _chipKeys[selectedType];
    if (key?.currentContext != null) {
      // Get the RenderBox of the selected chip
      final RenderBox renderBox =
          key!.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(
        Offset.zero,
        ancestor: context.findRenderObject(),
      );

      // Get the scroll position
      final scrollOffset = _scrollController.offset;
      final viewportWidth = _scrollController.position.viewportDimension;
      final chipWidth = renderBox.size.width;
      final chipPosition = position.dx + scrollOffset;

      // Calculate the desired scroll position to center the chip
      final desiredOffset =
          chipPosition - (viewportWidth / 2) + (chipWidth / 2);

      // Animate to the new position
      _scrollController.animateTo(
        desiredOffset.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedMetric = ref.watch(selectedMetricProvider);
    final selectedMetricData =
        selectedMetric != null
            ? widget.metrics.firstWhere(
              (m) => m.type == selectedMetric,
              orElse: () => widget.metrics.first,
            )
            : widget.metrics.first;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
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
          // Metric Selector with ScrollController
          SizedBox(
            height: 40, // Fixed height for the chip row
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMD,
              ),
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    widget.metrics.map((metric) {
                      final isSelected =
                          metric.type ==
                          (selectedMetric ?? widget.metrics.first.type);
                      return Padding(
                        key: _chipKeys[metric.type],
                        padding: const EdgeInsets.only(
                          right: AppConstants.spaceSM,
                        ),
                        child: ChoiceChip(
                          label: Text(metric.label),
                          selected: isSelected,
                          onSelected: (_) {
                            ref.read(selectedMetricProvider.notifier).state =
                                metric.type;
                            // Scroll to the selected chip after a short delay to ensure the UI has updated
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToSelectedChip(metric.type);
                            });
                          },
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),

          // Metric Value and Change
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD,),
            child: Row(
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
          ),
          const SizedBox(height: AppConstants.spaceLG),

          // Chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppConstants.spaceMD, right: AppConstants.spaceMD, top: AppConstants.spaceMD, bottom: 20),
              // Add padding for date labels
              child: CustomPaint(
                size: Size.infinite,
                painter: _ChartPainter(
                  data: selectedMetricData.chartData,
                  color: theme.colorScheme.primary,
                  textStyle: theme.textTheme.bodySmall!,
                ),
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
    final changePercent =
        metric.previousValue > 0
            ? ((change / metric.previousValue) * 100)
            : 0.0;
    final isPositive = change >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceSM,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:
            isPositive
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

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    final gridPaint =
        Paint()
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
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
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
    final pointPaint =
        Paint()
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
      // Calculate text sizes
      final startDateText = _formatDate(data.first.date);
      final endDateText = _formatDate(data.last.date);

      final startTextPainter = TextPainter(
        text: TextSpan(text: startDateText, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final endTextPainter = TextPainter(
        text: TextSpan(text: endDateText, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      // Start date - ensure it doesn't go beyond left edge
      startTextPainter.paint(canvas, Offset(0, size.height + 5));

      // End date - ensure it doesn't go beyond right edge
      endTextPainter.paint(
        canvas,
        Offset(size.width - endTextPainter.width, size.height + 5),
      );

      // Optional: Add middle date if there are enough data points
      if (data.length >= 5) {
        final middleIndex = data.length ~/ 2;
        final middleDateText = _formatDate(data[middleIndex].date);
        final middleTextPainter = TextPainter(
          text: TextSpan(text: middleDateText, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();

        middleTextPainter.paint(
          canvas,
          Offset((size.width - middleTextPainter.width) / 2, size.height + 5),
        );
      }
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
