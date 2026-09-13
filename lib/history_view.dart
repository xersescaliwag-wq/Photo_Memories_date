import 'package:flutter/cupertino.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'config.dart';

class HistoryView extends StatefulWidget {
  final Map<String, String> dateImages;
  final Function(String) onDeleteImage;

  const HistoryView({
    super.key,
    required this.dateImages,
    required this.onDeleteImage,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  String? filterMonth;
  String? filterYear;
  int currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    var filteredKeys = widget.dateImages.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    if (filterYear != null) {
      filteredKeys = filteredKeys.where((k) => k.startsWith(filterYear!)).toList();
    }
    if (filterMonth != null) {
      final mIdx = (months.indexOf(filterMonth!) + 1).toString().padLeft(2, '0');
      filteredKeys = filteredKeys.where((k) => k.split('-')[1] == mIdx).toList();
    }

    if (widget.dateImages.isEmpty || filteredKeys.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.clock, size: 64, color: Color(0x40FFFFFF)),
                const SizedBox(height: 16),
                Text(
                  filteredKeys.isEmpty && widget.dateImages.isNotEmpty 
                    ? 'No memories for this filter' 
                    : 'No memories yet',
                  style: const TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                if (filteredKeys.isEmpty && widget.dateImages.isNotEmpty)
                  CupertinoButton(
                    child: const Text('Clear Filters'),
                    onPressed: () => setState(() {
                      filterMonth = null;
                      filterYear = null;
                    }),
                  ),
              ],
            ),
          ),
          _buildMenuButton(const []),
        ],
      );
    }

    return Stack(
      children: [
        PageView.builder(
          key: ValueKey('${filterMonth}_$filterYear'), // Force rebuild on filter change
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentPage = index;
            });
          },
          itemCount: filteredKeys.length,
          itemBuilder: (context, index) {
            final dateKey = filteredKeys[index];
            final imagePath = widget.dateImages[dateKey]!;
            final parts = dateKey.split('-');
            final year = parts[0];
            final month = months[int.parse(parts[1]) - 1];
            final day = parts[2];
            final weekday = _getWeekdayName(dateKey);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 140.0),
              child: AdaptiveGlass(
                quality: GlassQuality.premium,
                shape: const LiquidRoundedSuperellipse(borderRadius: 24),
                settings: const LiquidGlassSettings(chromaticAberration: 1.0, blur: 30),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(ApiConfig.imageUrl(imagePath)),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {},
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0x00000000), Color(0x99000000)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 24,
                        left: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$month $day',
                                style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                    shadows: [Shadow(color: Color(0x80000000), blurRadius: 8)])),
                            Text(year,
                                style: const TextStyle(
                                    color: Color(0xB3FFFFFF),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 2,
                                    shadows: [Shadow(color: Color(0x80000000), blurRadius: 8)])),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 28,
                        right: 24,
                        child: Text(weekday.toUpperCase(),
                            style: const TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                                shadows: [Shadow(color: Color(0x80000000), blurRadius: 8)])),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        _buildMenuButton(filteredKeys),
      ],
    );
  }

  Widget _buildMenuButton(List<String> filteredKeys) {
    return Positioned(
      top: 60,
      right: 20,
      child: GlassPopover(
        popoverWidth: 200,
        settings: const LiquidGlassSettings(chromaticAberration: 0.5, blur: 30),
        triggerBuilder: (context, toggle) => GlassButton(
          onTap: toggle,
          width: 44,
          height: 44,
          icon: const Icon(CupertinoIcons.ellipsis_vertical, color: CupertinoColors.white),
          settings: const LiquidGlassSettings(chromaticAberration: 0.5),
        ),
        contentBuilder: (context, close) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'OPTIONS',
                style: TextStyle(
                  color: Color(0x66FFFFFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              // Delete Option
              if (filteredKeys.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassButton.custom(
                    onTap: () {
                      if (currentPage < filteredKeys.length) {
                        widget.onDeleteImage(filteredKeys[currentPage]);
                        close();
                      }
                    },
                    width: double.infinity,
                    height: 44,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(CupertinoIcons.delete, size: 16, color: CupertinoColors.systemRed),
                        SizedBox(width: 8),
                        Text(
                          'DELETE MEMORY',
                          style: TextStyle(color: CupertinoColors.systemRed, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              const GlassMenuDivider(),
              const SizedBox(height: 12),
              // Month Dropdown Pill
              GlassMenu(
                menuWidth: 150,
                menuHeight: 200,
                settings: const LiquidGlassSettings(chromaticAberration: 1.0, blur: 40),
                triggerBuilder: (context, toggle) => GlassButton.custom(
                  onTap: toggle,
                  width: double.infinity,
                  height: 44,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (filterMonth ?? 'Month').toUpperCase(),
                        style: const TextStyle(color: CupertinoColors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                      ),
                      const SizedBox(width: 4),
                      const Icon(CupertinoIcons.chevron_down, size: 10, color: Color(0x66FFFFFF)),
                    ],
                  ),
                ),
                items: List.generate(months.length + 1, (index) {
                  final text = index == 0 ? 'All' : months[index - 1];
                  return GlassMenuItem(
                    title: text,
                    onTap: () {
                      setState(() {
                        filterMonth = index == 0 ? null : months[index - 1];
                        currentPage = 0; // Reset page on filter
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              // Year Dropdown Pill
              GlassMenu(
                menuWidth: 150,
                menuHeight: 200,
                settings: const LiquidGlassSettings(chromaticAberration: 1.0, blur: 40),
                triggerBuilder: (context, toggle) => GlassButton.custom(
                  onTap: toggle,
                  width: double.infinity,
                  height: 44,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (filterYear ?? 'Year').toUpperCase(),
                        style: const TextStyle(color: CupertinoColors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                      ),
                      const SizedBox(width: 4),
                      const Icon(CupertinoIcons.chevron_down, size: 10, color: Color(0x66FFFFFF)),
                    ],
                  ),
                ),
                items: List.generate(11, (i) {
                  final year = (DateTime.now().year - 5 + i).toString();
                  return GlassMenuItem(
                    title: year,
                    onTap: () {
                      setState(() {
                        filterYear = year;
                        currentPage = 0; // Reset page on filter
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              // Reset Filters Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    filterMonth = null;
                    filterYear = null;
                    currentPage = 0;
                  });
                  close();
                },
                child: const Text(
                  'CLEAR ALL FILTERS',
                  style: TextStyle(color: CupertinoColors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWeekdayName(String dateKey) {
    final parts = dateKey.split('-');
    final date = DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return weekdays[date.weekday - 1];
  }
}
