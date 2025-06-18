class DateUtil {
  /// Returns a formatted date string for GitHub API queries.
  ///
  /// The GitHub API for trending repositories uses a 'created:YYYY-MM-DD' format.
  /// This utility calculates a date 'duration' days/weeks/months ago
  /// from the current date and formats it as 'YYYY-MM-DD'.
  ///
  /// [offset]: A Duration object (e.g., Duration(days: 1) for 'last day',
  ///           Duration(days: 7) for 'last week', Duration(days: 30) for 'last month').
  static String getFormattedDateForApi(Duration offset) {
    // Get the current UTC time to avoid timezone issues when querying API.
    final DateTime now = DateTime.now().toUtc();

    // Calculate the date in the past based on the offset
    final DateTime pastDate = now.subtract(offset);

    // Format the date as ISO 8601 string in 'YYYY-MM-DD' format
    return pastDate.toIso8601String();
  }

  /// Formats a DateTime object into a readable string (e.g., "Oct 26, 2017").
  /// This is useful for displaying creation dates on the detail screen.
  static String formatDisplayDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}
