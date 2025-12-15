import 'package:flutter/material.dart';
import 'dashboard_year.dart';

class MainDashboardMonth extends StatelessWidget {
  const MainDashboardMonth({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final double calendarBaseHeight = 320.0;
    final double calendarHeight = calendarBaseHeight * 1.2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF7E6DF7),
                Color(0xFF6B5CE6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Airbender',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // "Tháng 4" label and avatars
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (context, animation, secondaryAnimation) => const MainDashboardYear(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            final offsetAnimation = animation.drive(tween);
                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    },
                    child: const Icon(Icons.chevron_left, color: Color(0xFF6B5CE6), size: 32),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Tháng 4',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 26,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF6B5CE6)),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),

            // Calendar box
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 24, 19, 0),
              child: Container(
                width: double.infinity,
                height: calendarHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    width: 1,
                    color: Colors.black.withOpacity(0.14),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.08),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Day labels
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _CalendarDayLabel('T2'),
                          _CalendarDayLabel('T3'),
                          _CalendarDayLabel('T4'),
                          _CalendarDayLabel('T5'),
                          _CalendarDayLabel('T6'),
                          _CalendarDayLabel('T7'),
                          _CalendarDayLabel('CN'),
                        ],
                      ),
                    ),
                    // Calendar grid area, Expanded để dãn đều trong container cao hơn
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: _CalendarGrid(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
class _CalendarDayLabel extends StatelessWidget {
  final String label;
  const _CalendarDayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: SizedBox(
          height: 44,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [Color(0xFF7E6DF7), Color(0xFF6366F1)],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontFamily: 'Lexend',
                fontWeight: FontWeight.w700,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<List<String>> weeks = [
      ['29', '30', '31', '1', '2', '3', '4'],
      ['5', '6', '7', '8', '9', '10', '11'],
      ['12', '13', '14', '15', '16', '17', '18'],
      ['19', '20', '21', '22', '23', '24', '25'],
      ['26', '27', '28', '29', '30', '1', '2'],
    ];
    final List<List<Color>> dayColors = [
      [const Color(0x26001753), const Color(0x26001753), const Color(0x26001753),
        Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B)],
      [Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B),
        Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B)],
      [Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B),
        Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B)],
      [Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B),
        Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B)],
      [Color(0xFF1E293B), Color(0xFF1E293B), Color(0xFF1E293B), const Color(0xFF6366F1),
        Color(0xFF1E293B), Color(0x261E293B), Color(0x261E293B)],
    ];
    return Column(
      children: List.generate(weeks.length, (row) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18), // spacing lớn hơn
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (col) {
                final highlight = weeks[row][col] == '29' && row == 4;
                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: highlight
                        ? const Color(0xFF6366F1)
                        : Colors.white,
                    boxShadow: highlight
                        ? [
                      BoxShadow(
                        color: Color(0x293666F1),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      )
                    ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      weeks[row][col],
                      style: TextStyle(
                        color: highlight
                            ? Colors.white
                            : dayColors[row][col],
                        fontSize: 19,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }
}