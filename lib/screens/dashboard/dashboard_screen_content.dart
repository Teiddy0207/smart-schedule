import 'package:flutter/material.dart';
import 'dashboard_month.dart';
import '../../constants/app_constants.dart';
import '../../utils/date_formatter.dart';

class DashboardScreenContent extends StatelessWidget {
  const DashboardScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingL,
              AppConstants.spacingXXL,
              AppConstants.spacingL,
              0,
            ),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: AppConstants.animationDuration,
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const MainDashboardMonth(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(-1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          final tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          final offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                              position: offsetAnimation, child: child);
                        },
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.chevron_left,
                    color: AppConstants.primaryColor,
                    size: AppConstants.spacing3XL,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormatter.formatVietnameseDate(DateTime.now()),
                  style: AppConstants.headingSmall.copyWith(
                    color: AppConstants.primaryColor,
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: AppConstants.spacingXL,
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: AppConstants.primaryColor,
                    ),
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingXXL,
              AppConstants.spacingXXL,
              0,
              10,
            ),
            child: Text(
              "Lịch hôm nay",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: AppConstants.iconSizeXXL,
                    color: AppConstants.iconGray,
                  ),
                  const SizedBox(height: AppConstants.spacingL),
                  Text(
                    'Không có sự kiện nào hôm nay',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
