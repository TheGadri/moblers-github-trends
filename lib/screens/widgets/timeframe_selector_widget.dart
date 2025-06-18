import 'package:flutter/material.dart';

enum Timeframe { day, week, month }

class TimeframeSelectorWidget extends StatefulWidget {
  const TimeframeSelectorWidget({super.key, required this.onTimeframeChanged});

  final Function(Timeframe timeframe)? onTimeframeChanged;

  @override
  State<TimeframeSelectorWidget> createState() =>
      _TimeframeSelectorWidgetState();
}

class _TimeframeSelectorWidgetState extends State<TimeframeSelectorWidget> {
  Timeframe timeframeView = Timeframe.day;

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
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          timeframeView = newSelection.first;
          widget.onTimeframeChanged?.call(timeframeView);
        });
      },
    );
  }
}
