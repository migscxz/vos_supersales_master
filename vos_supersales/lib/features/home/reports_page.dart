import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../auth/user_model.dart'; // 🔵 Import the UserModel

class ReportsPage extends StatelessWidget {
  final UserModel currentUser; // 🔵 Accept UserModel
  const ReportsPage({super.key, required this.currentUser}); // 🔵 Require it

  final List<Map<String, dynamic>> reports = const [
    {'title': 'Sales Report - July 9', 'amount': 12400},
    {'title': 'Sales Report - July 8', 'amount': 8900},
    {'title': 'Sales Report - July 7', 'amount': 10500},
    {'title': 'Sales Report - July 6', 'amount': 9700},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textFill,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              itemCount: reports.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final report = reports[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          report['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textFill,
                          ),
                        ),
                      ),
                      Text(
                        '₱${report['amount']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
