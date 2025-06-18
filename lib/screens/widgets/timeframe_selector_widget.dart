import 'package:flutter/material.dart';
import 'package:moblers_github_trends/utils/enums.dart';

class TimeframeSelectorWidget extends StatefulWidget {
  const TimeframeSelectorWidget({
    super.key,
    required this.onTimeframeChanged,
    required this.initialTimeframe,
  });

  final Function(Timeframe timeframe)? onTimeframeChanged;
  final Timeframe initialTimeframe;

  @override
  State<TimeframeSelectorWidget> createState() =>
      _TimeframeSelectorWidgetState();
}

class _TimeframeSelectorWidgetState extends State<TimeframeSelectorWidget> {
  late Timeframe timeframeView = widget.initialTimeframe;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Timeframe>(
      segments: const <ButtonSegment<Timeframe>>[
        ButtonSegment<Timeframe>(
          value: Timeframe.day,
          label: Text('Day'),
          icon: Icon(Icons.calendar_view_day),
        ),
        ButtonSegment<Timeframe>(
          value: Timeframe.week,
          label: Text('Week'),
          icon: Icon(Icons.calendar_view_week),
        ),
        ButtonSegment<Timeframe>(
          value: Timeframe.month,
          label: Text('Month'),
          icon: Icon(Icons.calendar_view_month),
        ),
      ],
      selected: <Timeframe>{timeframeView},
      onSelectionChanged: (Set<Timeframe> newSelection) {
        setState(() {
          timeframeView = newSelection.first;
          widget.onTimeframeChanged?.call(timeframeView);
        });
      },
    );
  }
}
