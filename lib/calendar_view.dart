import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'config.dart';

class CalendarByMonth extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, String> dateImages;
  final ValueChanged<DateTime> onDateChanged;

  const CalendarByMonth({
    super.key,
    required this.selectedDate,
    required this.dateImages,
    required this.onDateChanged,
  });

  @override
  State<CalendarByMonth> createState() => _CalendarByMonthState();
}

class _CalendarByMonthState extends State<CalendarByMonth> {
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            8, 
            60, 
            8,
            MediaQuery.of(context).padding.bottom + 100
          ),
          child: Column(
            children: [
              // Selection Row with GlassPopover (Dropdown Wheel Style)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Month Popover
                    Expanded(
                      child: GlassPopover(
                        popoverWidth: 160,
                        popoverHeight: 240,
                        settings: const LiquidGlassSettings(chromaticAberration: 1.0, blur: 40),
                        triggerBuilder: (context, toggle) => GlassButton.custom(
                          useOwnLayer: true,
                          onTap: toggle,
                          height: 50,
                          quality: GlassQuality.premium,
                          shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                          settings: const LiquidGlassSettings(chromaticAberration: 1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.calendar, size: 16, color: Color(0x80FFFFFF)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  months[widget.selectedDate.month - 1].toUpperCase(),
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(CupertinoIcons.chevron_down, size: 12, color: Color(0x66FFFFFF)),
                            ],
                          ),
                        ),
                        contentBuilder: (context, close) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Center Indicator Lines
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(height: 0.5, width: 100, color: const Color(0x33FFFFFF)),
                                    const SizedBox(height: 40),
                                    Container(height: 0.5, width: 100, color: const Color(0x33FFFFFF)),
                                  ],
                                ),
                                ListWheelScrollView.useDelegate(
                                  itemExtent: 40,
                                  physics: const FixedExtentScrollPhysics(),
                                  controller: FixedExtentScrollController(initialItem: widget.selectedDate.month - 1),
                                  onSelectedItemChanged: (index) {
                                    widget.onDateChanged(DateTime(
                                      widget.selectedDate.year,
                                      index + 1,
                                      widget.selectedDate.day,
                                    ));
                                  },
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: months.length,
                                    builder: (context, index) => Center(
                                      child: Text(
                                        months[index],
                                        style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Year Popover
                    GlassPopover(
                      popoverWidth: 100,
                      popoverHeight: 200,
                      settings: const LiquidGlassSettings(chromaticAberration: 1.0, blur: 40),
                      triggerBuilder: (context, toggle) => GlassButton.custom(
                        useOwnLayer: true,
                        onTap: toggle,
                        width: 90,
                        height: 50,
                        quality: GlassQuality.premium,
                        shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                        settings: const LiquidGlassSettings(chromaticAberration: 1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.selectedDate.year.toString(),
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(CupertinoIcons.chevron_down, size: 12, color: Color(0x66FFFFFF)),
                          ],
                        ),
                      ),
                      contentBuilder: (context, close) {
                        final years = List.generate(50, (i) => DateTime.now().year - 25 + i);
                        int initialIndex = years.indexOf(widget.selectedDate.year);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(height: 0.5, width: 60, color: const Color(0x33FFFFFF)),
                                  const SizedBox(height: 40),
                                  Container(height: 0.5, width: 60, color: const Color(0x33FFFFFF)),
                                ],
                              ),
                              ListWheelScrollView.useDelegate(
                                itemExtent: 40,
                                physics: const FixedExtentScrollPhysics(),
                                controller: FixedExtentScrollController(initialItem: initialIndex),
                                onSelectedItemChanged: (index) {
                                  widget.onDateChanged(DateTime(
                                    years[index],
                                    widget.selectedDate.month,
                                    widget.selectedDate.day,
                                  ));
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: years.length,
                                  builder: (context, index) => Center(
                                    child: Text(
                                      years[index].toString(),
                                      style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Reset Button
                    GlassButton(
                      useOwnLayer: true,
                      settings: const LiquidGlassSettings(chromaticAberration: 1.0),
                      icon: const Icon(
                        CupertinoIcons.arrow_counterclockwise,
                        color: CupertinoColors.activeBlue,
                        size: 20,
                      ),
                      onTap: () {
                        widget.onDateChanged(DateTime.now());
                      },
                      width: 50,
                      height: 50,
                      quality: GlassQuality.premium,
                      shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Calendar View
              MonthGlassCard(
                monthName: months[widget.selectedDate.month - 1],
                year: widget.selectedDate.year,
                selectedDay: widget.selectedDate.day,
                dateImages: widget.dateImages,
                onDaySelected: (day) {
                  widget.onDateChanged(DateTime(widget.selectedDate.year, widget.selectedDate.month, day));
                },
              ),
            ],
          ),
        );
      }
    );
  }
}

class MonthGlassCard extends StatelessWidget {
  final String monthName;
  final int year;
  final int selectedDay;
  final Map<String, String> dateImages;
  final Function(int) onDaySelected;

  const MonthGlassCard({
    super.key,
    required this.monthName,
    required this.year,
    required this.selectedDay,
    required this.dateImages,
    required this.onDaySelected,
  });

  String _getDateKey(int day) {
    final m = _getMonthIndex(monthName).toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        final titleFontSize = (screenWidth * 0.08).clamp(24.0, 36.0);
        final dayFontSize = (screenWidth * 0.04).clamp(14.0, 20.0);
        final padding = (screenWidth * 0.05).clamp(16.0, 24.0);
        
        final daysInMonth = DateTime(year, _getMonthIndex(monthName) + 1, 0).day;
        final firstDayOffset = DateTime(year, _getMonthIndex(monthName), 1).weekday - 1;

        return AdaptiveGlass(
          quality: GlassQuality.premium,
          shape: const LiquidRoundedSuperellipse(borderRadius: 32),
          settings: const LiquidGlassSettings(chromaticAberration: 1.0),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      monthName,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      year.toString(),
                      style: TextStyle(
                        color: const Color(0xCCFFFFFF),
                        fontSize: titleFontSize * 0.7,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    color: Color(0x80FFFFFF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: daysInMonth + firstDayOffset,
                  itemBuilder: (context, index) {
                    if (index < firstDayOffset) return const SizedBox.shrink();
                    
                    final day = index - firstDayOffset + 1;
                    final isSelected = day == selectedDay;
                    
                    final now = DateTime.now();
                    final isToday = day == now.day && 
                                    _getMonthIndex(monthName) == now.month && 
                                    year == now.year;
                    
                    final String? imagePath = dateImages[_getDateKey(day)];
                    
                    return GestureDetector(
                      onTap: () => onDaySelected(day),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0x40FFFFFF) 
                              : (isToday 
                                  ? const Color(0x4D8E8E93)
                                  : const Color(0x0DFFFFFF)),
                          image: imagePath != null 
                              ? DecorationImage(
                                  image: NetworkImage(
                                      ApiConfig.imageUrl(imagePath)),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {},
                                )
                              : null,
                          border: Border.all(
                            color: isSelected || isToday
                                ? const Color(0x66FFFFFF)
                                : const Color(0x1AFFFFFF),
                            width: 0.5,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: dayFontSize,
                              fontWeight: (isSelected || isToday) ? FontWeight.w600 : FontWeight.w300,
                              shadows: imagePath != null ? [
                                const Shadow(
                                  blurRadius: 4.0,
                                  color: Color(0xFF000000),
                                  offset: Offset(1.0, 1.0),
                                ),
                              ] : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getMonthIndex(String name) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months.indexOf(name) + 1;
  }
}
