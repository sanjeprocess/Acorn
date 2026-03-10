import 'package:arcon_travel_app/core/theme.dart';
import 'package:flutter/material.dart';

class DocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double width;
  final Color? cardColor;
  final Color? iconColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? subtitleColor;
  final double borderRadius;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final bool showArrow;
  final double iconSize;

  const DocumentCard({
    super.key,
    required this.title,
    required this.onTap,
    this.onLongPress,
    this.subtitle = 'Tap to view',
    this.icon = Icons.picture_as_pdf,
    this.width = 200,
    this.cardColor,
    this.iconColor,
    this.borderColor,
    this.textColor,
    this.subtitleColor,
    this.borderRadius = 12,
    this.margin = const EdgeInsets.only(right: 12),
    this.padding = const EdgeInsets.all(12),
    this.showArrow = true,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultIconColor = iconColor ?? AppTheme.primaryColor;
    final defaultTextColor = textColor ?? AppTheme.primaryColor;
    final defaultSubtitleColor = subtitleColor ?? AppTheme.primaryColor;

    return Container(
      width: width,
      margin: margin,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppTheme.whiteColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: defaultIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: defaultIconColor, size: iconSize),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: defaultTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: defaultSubtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: defaultIconColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
