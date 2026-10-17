import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kd_utils/widgets/signature_pad/signature_pad_dialog.dart';

/// Representation of a single day's labour attendance and overtime record.
class LabourDayAttendance {
  final int day;
  final bool present;
  final bool absent;
  final bool halfDay;
  final double overtime; // in hours
  final double advance; // cash advance amount
  final String? signature; // Base64 string or URL
  final String? note;

  const LabourDayAttendance({
    required this.day,
    this.present = false,
    this.absent = false,
    this.halfDay = false,
    this.overtime = 0.0,
    this.advance = 0.0,
    this.signature,
    this.note,
  });

  LabourDayAttendance copyWith({
    int? day,
    bool? present,
    bool? absent,
    bool? halfDay,
    double? overtime,
    double? advance,
    String? signature,
    String? note,
  }) {
    return LabourDayAttendance(
      day: day ?? this.day,
      present: present ?? this.present,
      absent: absent ?? this.absent,
      halfDay: halfDay ?? this.halfDay,
      overtime: overtime ?? this.overtime,
      advance: advance ?? this.advance,
      signature: signature ?? this.signature,
      note: note ?? this.note,
    );
  }
}

/// Authentic physical-style monthly labour attendance and overtime timesheet card.
/// Features a bi-column punch table (Days 1–15 on left, Days 16–31 on right)
/// with header metadata, daily attendance sessions, OT hours, advances, and signature blocks.
class LabourAttendanceCard extends StatefulWidget {
  final String workerName;
  final String workerRole;
  final String? workerPhone;
  final String? workerId;
  final String? siteName;
  final double dailyWage;
  final DateTime month;
  final Map<int, LabourDayAttendance> dayAttendance;
  final String? workerSignature;
  final String? adminSignature;
  final String? adminName;
  final VoidCallback? onAdminSign;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;
  final ValueChanged<DateTime>? onSelectMonth;
  final VoidCallback? onShareSnapshot;
  final bool isSharingSnapshot;
  final bool showControls;
  final String currencySymbol;
  final GlobalKey? cardBoundaryKey;

  // Optional manual overrides for summary totals
  final int? totalPresent;
  final int? totalAbsent;
  final double? totalOt;
  final double? totalAdvance;
  final double? grossEarnings;
  final double? netPayable;

  /// Whether the card allows direct inline editing by administrators / users
  final bool isEditable;

  /// Callback fired when an admin updates a day's attendance record directly from the card.
  /// Can return a Future to allow asynchronous remote updates (e.g. Firebase) with loading spinner.
  final FutureOr<bool?> Function(int day, LabourDayAttendance attendance)? onDayUpdate;

  const LabourAttendanceCard({
    super.key,
    required this.workerName,
    this.workerRole = 'Worker',
    this.workerPhone,
    this.workerId,
    this.siteName,
    this.dailyWage = 0.0,
    required this.month,
    this.dayAttendance = const {},
    this.workerSignature,
    this.adminSignature,
    this.adminName,
    this.onAdminSign,
    this.onPreviousMonth,
    this.onNextMonth,
    this.onSelectMonth,
    this.onShareSnapshot,
    this.isSharingSnapshot = false,
    this.showControls = true,
    this.currencySymbol = '₹',
    this.cardBoundaryKey,
    this.totalPresent,
    this.totalAbsent,
    this.totalOt,
    this.totalAdvance,
    this.grossEarnings,
    this.netPayable,
    this.isEditable = true,
    this.onDayUpdate,
  });

  @override
  State<LabourAttendanceCard> createState() => _LabourAttendanceCardState();
}

class _LabourAttendanceCardState extends State<LabourAttendanceCard> {
  // 0 = Full Card, 1 = Days 1-15, 2 = Days 16-31 (Mobile bi-column switcher)
  int _viewMode = 0;
  late Map<int, LabourDayAttendance> _localDayAttendance;
  bool _hasLocalEdits = false;

  @override
  void initState() {
    super.initState();
    _localDayAttendance = Map<int, LabourDayAttendance>.from(widget.dayAttendance);
  }

  @override
  void didUpdateWidget(covariant LabourAttendanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month ||
        oldWidget.dayAttendance != widget.dayAttendance) {
      _hasLocalEdits = false;
      _localDayAttendance = Map<int, LabourDayAttendance>.from(widget.dayAttendance);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 760;

    final daysInMonth = DateUtils.getDaysInMonth(
      widget.month.year,
      widget.month.month,
    );

    // Compute totals if not explicitly overridden
    int computedPresent = 0;
    int computedAbsent = 0;
    double computedOt = 0.0;
    double computedAdvance = 0.0;

    for (int d = 1; d <= daysInMonth; d++) {
      final rec = _localDayAttendance[d];
      if (rec != null) {
        if (rec.present) computedPresent++;
        if (rec.absent) computedAbsent++;
        if (rec.halfDay) computedPresent++;
        computedOt += rec.overtime;
        computedAdvance += rec.advance;
      }
    }

    final int effectivePresent = (_hasLocalEdits ? null : widget.totalPresent) ?? computedPresent;
    final int effectiveAbsent = (_hasLocalEdits ? null : widget.totalAbsent) ?? computedAbsent;
    final double effectiveOt = (_hasLocalEdits ? null : widget.totalOt) ?? computedOt;
    final double effectiveAdvance = (_hasLocalEdits ? null : widget.totalAdvance) ?? computedAdvance;

    final double hourlyRate = widget.dailyWage > 0 ? widget.dailyWage / 8.0 : 0.0;
    final double computedGross = (effectivePresent * widget.dailyWage) + (effectiveOt * hourlyRate);
    final double effectiveGross = (_hasLocalEdits ? null : widget.grossEarnings) ?? computedGross;
    final double effectiveNet = (_hasLocalEdits ? null : widget.netPayable) ?? (effectiveGross - effectiveAdvance);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Optional Controls Bar (Month Switcher, View Selector, Share)
        if (widget.showControls) ...[
          _buildControls(context, theme, isDark, isMobile),
          const SizedBox(height: 12),
        ],

        // The Physical-style Attendance Timesheet Card
        LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = (isMobile && _viewMode != 0) ? 370.0 : 710.0;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Center(
                  child: RepaintBoundary(
                    key: widget.cardBoundaryKey,
                    child: Container(
                      width: cardWidth,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2421) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF475569) : const Color(0xFF1E293B),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Card Header: Title & Worker Metadata Table
                          _buildCardHeader(isDark, cardWidth),
                          const SizedBox(height: 12),

                          // Bi-Column Punch Table (1–15 & 16–31)
                          _buildPunchTable(isDark, daysInMonth, isMobile),
                          const SizedBox(height: 14),

                          // Card Footer: KPI Totals & Authorization Signatures
                          _buildCardFooter(
                            isDark,
                            cardWidth,
                            effectivePresent,
                            effectiveAbsent,
                            effectiveOt,
                            effectiveAdvance,
                            effectiveGross,
                            effectiveNet,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- Top Controls Bar ---
  Widget _buildControls(BuildContext context, ThemeData theme, bool isDark, bool isMobile) {
    final monthStr = DateFormat('MMMM yyyy').format(widget.month);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          // Month navigation
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: widget.onPreviousMonth,
                visualDensity: VisualDensity.compact,
                tooltip: 'Previous Month',
              ),
              InkWell(
                onTap: widget.onSelectMonth != null
                    ? () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: widget.month,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDatePickerMode: DatePickerMode.year,
                        );
                        if (picked != null) {
                          widget.onSelectMonth!(DateTime(picked.year, picked.month, 1));
                        }
                      }
                    : null,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        monthStr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: widget.onNextMonth,
                visualDensity: VisualDensity.compact,
                tooltip: 'Next Month',
              ),
            ],
          ),

          // Mobile View Switcher (Days 1–15 vs 16–31 vs Full)
          if (isMobile)
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Full', style: TextStyle(fontSize: 11))),
                ButtonSegment(value: 1, label: Text('1–15', style: TextStyle(fontSize: 11))),
                ButtonSegment(value: 2, label: Text('16–31', style: TextStyle(fontSize: 11))),
              ],
              selected: {_viewMode},
              onSelectionChanged: (set) {
                setState(() => _viewMode = set.first);
              },
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),

          // Share Snapshot Button
          if (widget.onShareSnapshot != null)
            IconButton(
              icon: widget.isSharingSnapshot
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.share_rounded, size: 18),
              onPressed: widget.isSharingSnapshot ? null : widget.onShareSnapshot,
              tooltip: 'Share Timesheet',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  // --- Card Header ---
  Widget _buildCardHeader(bool isDark, double cardWidth) {
    final borderColor = isDark ? const Color(0xFF475569) : const Color(0xFF1E293B);
    final monthStr = DateFormat('MMMM yyyy').format(widget.month).toUpperCase();
    final isCompact = cardWidth < 520;

    final wageText = widget.dailyWage > 0
        ? '${widget.currencySymbol}${widget.dailyWage.toInt()} / DAY'
        : 'NOT SET';

    return Column(
      children: [
        Text(
          'MONTHLY ATTENDANCE & OVERTIME CARD',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: isCompact
              ? Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _metaCell(
                            'EMPLOYEE NAME',
                            widget.workerName.toUpperCase(),
                            isDark: isDark,
                            borderColor: borderColor,
                          ),
                        ),
                        Expanded(
                          child: _metaCell(
                            'ROLE',
                            widget.workerRole.toUpperCase(),
                            isDark: isDark,
                            borderColor: borderColor,
                            isLast: true,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 1, color: borderColor),
                    Row(
                      children: [
                        Expanded(
                          child: _metaCell(
                            'MONTH / YEAR',
                            monthStr,
                            isDark: isDark,
                            borderColor: borderColor,
                          ),
                        ),
                        Expanded(
                          child: _metaCell(
                            'WAGE',
                            wageText,
                            isDark: isDark,
                            borderColor: borderColor,
                            isLast: true,
                            highlightColor: widget.dailyWage > 0 ? const Color(0xFF0284C7) : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _metaCell(
                        'EMPLOYEE NAME',
                        widget.workerName.toUpperCase(),
                        isDark: isDark,
                        borderColor: borderColor,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _metaCell(
                        'ROLE',
                        widget.workerRole.toUpperCase(),
                        isDark: isDark,
                        borderColor: borderColor,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _metaCell(
                        'MONTH / YEAR',
                        monthStr,
                        isDark: isDark,
                        borderColor: borderColor,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _metaCell(
                        'WAGE',
                        wageText,
                        isDark: isDark,
                        borderColor: borderColor,
                        isLast: true,
                        highlightColor: widget.dailyWage > 0 ? const Color(0xFF0284C7) : null,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _metaCell(
    String label,
    String value, {
    required bool isDark,
    required Color borderColor,
    bool isLast = false,
    Color? highlightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        border: isLast ? null : Border(right: BorderSide(color: borderColor, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black54,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: highlightColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- Bi-Column Punch Table ---
  Widget _buildPunchTable(bool isDark, int daysInMonth, bool isMobile) {
    final borderColor = isDark ? const Color(0xFF475569) : const Color(0xFF1E293B);
    final showLeft = !isMobile || _viewMode == 0 || _viewMode == 1;
    final showRight = !isMobile || _viewMode == 0 || _viewMode == 2;

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(color: borderColor, width: 1.1),
      columnWidths: {
        if (showLeft) ...{
          0: const FixedColumnWidth(44),
          1: const FixedColumnWidth(80),
          2: const FixedColumnWidth(76),
          3: const FixedColumnWidth(58),
          4: const FixedColumnWidth(80),
        },
        if (showRight) ...{
          if (showLeft) ...{
            5: const FixedColumnWidth(44),
            6: const FixedColumnWidth(80),
            7: const FixedColumnWidth(76),
            8: const FixedColumnWidth(58),
            9: const FixedColumnWidth(80),
          } else ...{
            0: const FixedColumnWidth(44),
            1: const FixedColumnWidth(80),
            2: const FixedColumnWidth(76),
            3: const FixedColumnWidth(58),
            4: const FixedColumnWidth(80),
          },
        },
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF232D27) : const Color(0xFFE2E8F0),
          ),
          children: [
            if (showLeft) ..._buildHeaderCells(isDark: isDark, borderColor: borderColor),
            if (showRight) ..._buildHeaderCells(isDark: isDark, borderColor: borderColor),
          ],
        ),

        // 16 rows (Left: 1-15, Right: 16-31)
        for (int i = 0; i < 16; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i % 2 == 1
                  ? (isDark ? const Color(0xFF1B221E) : const Color(0xFFF8FAFC))
                  : null,
            ),
            children: [
              if (showLeft)
                ..._buildDataCells(
                  day: i + 1,
                  daysInMonth: daysInMonth,
                  isDark: isDark,
                  borderColor: borderColor,
                  isExtraRow: i == 15,
                ),
              if (showRight)
                ..._buildDataCells(
                  day: i + 16,
                  daysInMonth: daysInMonth,
                  isDark: isDark,
                  borderColor: borderColor,
                  isExtraRow: false,
                ),
            ],
          ),
      ],
    );
  }

  List<Widget> _buildHeaderCells({required bool isDark, required Color borderColor}) {
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return [
      SizedBox(
        height: 40,
        child: Center(
          child: Text('Date', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textColor)),
        ),
      ),
      SizedBox(
        height: 40,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text('ATTENDANCE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: textColor)),
              ),
            ),
            Container(height: 1, color: borderColor),
            SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(child: Center(child: Text('1st', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: textColor)))),
                  Container(width: 1, color: borderColor),
                  Expanded(child: Center(child: Text('2nd', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: textColor)))),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 40,
        child: Center(
          child: Text('Overtime', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textColor)),
        ),
      ),
      SizedBox(
        height: 40,
        child: Center(
          child: Text('Advance\n(${widget.currencySymbol})', textAlign: TextAlign.center, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: textColor, height: 1.1)),
        ),
      ),
      SizedBox(
        height: 40,
        child: Center(
          child: Text('Signature', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: textColor)),
        ),
      ),
    ];
  }

  List<Widget> _buildDataCells({
    required int day,
    required int daysInMonth,
    required bool isDark,
    required Color borderColor,
    required bool isExtraRow,
  }) {
    if (isExtraRow) {
      return [
        _cell('-', isDark: isDark),
        _attendanceCell(first: '', second: '', isDark: isDark, borderColor: borderColor),
        _cell('-', isDark: isDark),
        _cell('-', isDark: isDark),
        _cell('-', isDark: isDark),
      ];
    }

    if (day > daysInMonth) {
      return [
        _cell('$day', isDark: isDark, isDimmed: true),
        _attendanceCell(first: '-', second: '', isDark: isDark, borderColor: borderColor, isDimmed: true),
        _cell('-', isDark: isDark, isDimmed: true),
        _cell('-', isDark: isDark, isDimmed: true),
        _cell('-', isDark: isDark, isDimmed: true),
      ];
    }

    final VoidCallback? onCellTap = widget.isEditable
        ? () => _showDayEditDialog(context, day, daysInMonth)
        : null;
    final String? cellTooltip = widget.isEditable
        ? 'Click to edit Day $day'
        : null;

    final record = _localDayAttendance[day];
    final double advance = record?.advance ?? 0.0;
    final advanceStr = advance > 0 ? '${widget.currencySymbol}${advance.toInt()}' : '-';
    final advanceColor = advance > 0 ? const Color(0xFFD97706) : null;

    if (record == null) {
      return [
        _cell('$day', isBold: true, isDark: isDark, onTap: onCellTap, tooltip: cellTooltip),
        _attendanceCell(first: '-', second: '', isDark: isDark, borderColor: borderColor, onTap: onCellTap, tooltip: cellTooltip),
        _cell('-', isDark: isDark, onTap: onCellTap, tooltip: cellTooltip),
        _cell(advanceStr, color: advanceColor, isBold: advance > 0, isDark: isDark, onTap: onCellTap, tooltip: cellTooltip),
        _cell('-', isDark: isDark, onTap: onCellTap, tooltip: cellTooltip),
      ];
    }

    final otStr = record.overtime > 0
        ? '${record.overtime % 1 == 0 ? record.overtime.toInt() : record.overtime}h'
        : '-';

    String firstStatus = '-';
    Color? statusColor;
    if (record.present) {
      firstStatus = 'P';
      statusColor = const Color(0xFF10B981);
    } else if (record.absent) {
      firstStatus = 'A';
      statusColor = const Color(0xFFEF4444);
    } else if (record.halfDay) {
      firstStatus = 'HD';
      statusColor = const Color(0xFFF59E0B);
    }

    Widget signatureWidget;
    if (record.signature != null && record.signature!.trim().isNotEmpty) {
      signatureWidget = SizedBox(
        height: 24,
        child: Center(
          child: SignaturePadDialog.buildSignatureImage(
            record.signature!,
            height: 16,
            fit: BoxFit.contain,
            isDark: isDark,
          ),
        ),
      );
    } else {
      signatureWidget = _cell(
        record.present ? '✓' : (record.absent ? 'Absent' : '-'),
        color: record.present
            ? const Color(0xFF10B981)
            : (record.absent ? const Color(0xFFEF4444) : null),
        isBold: record.present,
        isDark: isDark,
        onTap: onCellTap,
        tooltip: cellTooltip,
      );
    }

    if (onCellTap != null && record.signature != null && record.signature!.trim().isNotEmpty) {
      signatureWidget = InkWell(
        onTap: onCellTap,
        hoverColor: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.12) : const Color(0xFF0284C7).withValues(alpha: 0.08),
        child: Tooltip(message: cellTooltip ?? '', child: signatureWidget),
      );
    }

    return [
      _cell('$day', isBold: true, isDark: isDark, onTap: onCellTap, tooltip: cellTooltip),
      _attendanceCell(
        first: firstStatus,
        second: '',
        color: statusColor,
        isBold: true,
        isDark: isDark,
        borderColor: borderColor,
        onTap: onCellTap,
        tooltip: cellTooltip,
      ),
      _cell(
        otStr,
        color: record.overtime > 0 ? const Color(0xFFD97706) : null,
        isBold: record.overtime > 0,
        isDark: isDark,
        onTap: onCellTap,
        tooltip: cellTooltip,
      ),
      _cell(
        advanceStr,
        color: advanceColor,
        isBold: advance > 0,
        isDark: isDark,
        onTap: onCellTap,
        tooltip: cellTooltip,
      ),
      signatureWidget,
    ];
  }

  Widget _cell(
    String text, {
    bool isBold = false,
    bool isDark = false,
    bool isDimmed = false,
    Color? color,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    Color effectiveColor = color ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    if (isDimmed) effectiveColor = effectiveColor.withValues(alpha: 0.28);

    Widget content = SizedBox(
      height: 24,
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: effectiveColor,
          ),
        ),
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        hoverColor: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.12) : const Color(0xFF0284C7).withValues(alpha: 0.08),
        child: content,
      );
    }

    if (tooltip != null && tooltip.isNotEmpty) {
      content = Tooltip(message: tooltip, child: content);
    }

    return content;
  }

  Widget _attendanceCell({
    required String first,
    required String second,
    required bool isDark,
    required Color borderColor,
    Color? color,
    bool isBold = false,
    bool isDimmed = false,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    Color effectiveColor = color ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    if (isDimmed) effectiveColor = effectiveColor.withValues(alpha: 0.28);

    Widget content = SizedBox(
      height: 24,
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                first,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                  color: effectiveColor,
                ),
              ),
            ),
          ),
          Container(width: 1, color: borderColor),
          Expanded(
            child: Center(
              child: Text(
                second,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                  color: effectiveColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        hoverColor: isDark ? const Color(0xFF38BDF8).withValues(alpha: 0.12) : const Color(0xFF0284C7).withValues(alpha: 0.08),
        child: content,
      );
    }

    if (tooltip != null && tooltip.isNotEmpty) {
      content = Tooltip(message: tooltip, child: content);
    }

    return content;
  }

  Future<void> _showDayEditDialog(BuildContext context, int day, int daysInMonth) async {
    if (day > daysInMonth) return;
    final current = _localDayAttendance[day] ?? LabourDayAttendance(day: day);

    String selectedStatus = current.present
        ? 'P'
        : (current.absent
            ? 'A'
            : (current.halfDay ? 'HD' : '-'));
    final otController = TextEditingController(
      text: current.overtime > 0
          ? (current.overtime % 1 == 0 ? current.overtime.toInt().toString() : current.overtime.toString())
          : '',
    );
    final advanceController = TextEditingController(
      text: current.advance > 0 ? current.advance.toInt().toString() : '',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthName = DateFormat('MMMM yyyy').format(widget.month);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSaving = false;
        String? errorMessage;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_calendar_rounded, color: Color(0xFF0284C7), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Day $day Attendance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '$monthName • ${widget.workerName}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Text(
                      'ATTENDANCE STATUS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _statusChip(
                          label: 'Present (P)',
                          code: 'P',
                          selected: selectedStatus == 'P',
                          color: const Color(0xFF10B981),
                          onTap: () => setDialogState(() => selectedStatus = 'P'),
                        ),
                        _statusChip(
                          label: 'Half Day (HD)',
                          code: 'HD',
                          selected: selectedStatus == 'HD',
                          color: const Color(0xFFF59E0B),
                          onTap: () => setDialogState(() => selectedStatus = 'HD'),
                        ),
                        _statusChip(
                          label: 'Absent (A)',
                          code: 'A',
                          selected: selectedStatus == 'A',
                          color: const Color(0xFFEF4444),
                          onTap: () => setDialogState(() => selectedStatus = 'A'),
                        ),
                        _statusChip(
                          label: 'Unmarked (-)',
                          code: '-',
                          selected: selectedStatus == '-',
                          color: Colors.grey,
                          onTap: () => setDialogState(() => selectedStatus = '-'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'OVERTIME (HOURS)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [0.0, 1.0, 1.5, 2.0, 3.0, 4.0].map((h) {
                        final isHSelected = (double.tryParse(otController.text) ?? 0.0) == h;
                        return ChoiceChip(
                          label: Text('${h % 1 == 0 ? h.toInt() : h}h', style: const TextStyle(fontSize: 11)),
                          selected: isHSelected,
                          onSelected: (_) {
                            setDialogState(() {
                              otController.text = h > 0 ? (h % 1 == 0 ? h.toInt().toString() : h.toString()) : '';
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: otController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Custom OT hours (e.g. 2.5)',
                        prefixIcon: const Icon(Icons.timer_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'DAILY ADVANCE PAID',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white70 : Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: advanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        prefixText: '${widget.currencySymbol} ',
                        hintText: 'Advance amount (e.g. 500)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final parsedOt = double.tryParse(otController.text.trim()) ?? 0.0;
                          final parsedAdvance = double.tryParse(advanceController.text.trim()) ?? 0.0;

                          final updatedRecord = current.copyWith(
                            present: selectedStatus == 'P',
                            halfDay: selectedStatus == 'HD',
                            absent: selectedStatus == 'A',
                            overtime: parsedOt,
                            advance: parsedAdvance,
                          );

                          if (widget.onDayUpdate != null) {
                            setDialogState(() {
                              isSaving = true;
                              errorMessage = null;
                            });

                            try {
                              final result = await widget.onDayUpdate!(day, updatedRecord);
                              if (result != false) {
                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }
                                return;
                              } else {
                                if (ctx.mounted) {
                                  setDialogState(() {
                                    isSaving = false;
                                    errorMessage = 'Failed to update on server. Please try again.';
                                  });
                                }
                                return;
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                setDialogState(() {
                                  isSaving = false;
                                  errorMessage = 'Error saving: $e';
                                });
                              }
                              return;
                            }
                          }

                          // Fallback if no callback provided
                          setState(() {
                            _localDayAttendance[day] = updatedRecord;
                          });
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save & Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statusChip({
    required String label,
    required String code,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: selected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }

  // --- Card Footer ---
  Widget _buildCardFooter(
    bool isDark,
    double cardWidth,
    int totalPresent,
    int totalAbsent,
    double totalOt,
    double totalAdvancePaid,
    double grossEarnings,
    double netPayable,
  ) {
    final borderColor = isDark ? const Color(0xFF475569) : const Color(0xFF1E293B);
    final hasWage = widget.dailyWage > 0;
    final isCompact = cardWidth < 500;

    return Column(
      children: [
        // Summary KPI Box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF28322B) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: isCompact
              ? Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _kpiItem('DAYS PRESENT', '$totalPresent DAYS', const Color(0xFF10B981)),
                    _kpiItem('OVERTIME', '${totalOt % 1 == 0 ? totalOt.toInt() : totalOt.toStringAsFixed(1)}h', const Color(0xFFD97706)),
                    if (hasWage) ...[
                      _kpiItem('GROSS WAGE', '${widget.currencySymbol}${grossEarnings.toInt()}', const Color(0xFF0284C7)),
                      _kpiItem('ADVANCE PAID', '${widget.currencySymbol}${totalAdvancePaid.toInt()}', const Color(0xFFD97706)),
                      _kpiItem('NET PAYABLE', '${widget.currencySymbol}${netPayable.toInt()}', netPayable >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                    ] else ...[
                      _kpiItem('DAYS ABSENT', '$totalAbsent DAYS', const Color(0xFFEF4444)),
                    ],
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _kpiItem('DAYS PRESENT', '$totalPresent DAYS', const Color(0xFF10B981)),
                    _kpiItem('OVERTIME (OT)', '${totalOt % 1 == 0 ? totalOt.toInt() : totalOt.toStringAsFixed(1)}h', const Color(0xFFD97706)),
                    if (hasWage) ...[
                      _kpiItem('GROSS WAGE', '${widget.currencySymbol}${grossEarnings.toInt()}', const Color(0xFF0284C7)),
                      _kpiItem('ADVANCE PAID', '${widget.currencySymbol}${totalAdvancePaid.toInt()}', const Color(0xFFD97706)),
                      _kpiItem('NET PAYABLE', '${widget.currencySymbol}${netPayable.toInt()}', netPayable >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                    ] else ...[
                      _kpiItem('DAYS ABSENT', '$totalAbsent DAYS', const Color(0xFFEF4444)),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: 12),

        // Signature Authorization Blocks
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Employee Signature Block
            Expanded(
              child: _signatureBlock(
                title: 'EMPLOYEE SIGNATURE',
                subtitle: widget.workerName,
                signature: widget.workerSignature,
                isDark: isDark,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 14),

            // Verified Date Stamp
            Expanded(
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VERIFICATION DATE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd-MMM-yyyy').format(DateTime.now()).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Authorized Signatory Block
            Expanded(
              child: _signatureBlock(
                title: 'AUTHORIZED SIGNATORY',
                subtitle: widget.adminName ?? 'Site Supervisor / Admin',
                signature: widget.adminSignature,
                isDark: isDark,
                borderColor: borderColor,
                onTap: widget.onAdminSign,
                isInteractive: widget.onAdminSign != null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiItem(String title, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _signatureBlock({
    required String title,
    required String subtitle,
    required String? signature,
    required bool isDark,
    required Color borderColor,
    VoidCallback? onTap,
    bool isInteractive = false,
  }) {
    final hasSig = signature != null && signature.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isInteractive && !hasSig
                ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                : borderColor,
            width: isInteractive && !hasSig ? 1.2 : 0.8,
          ),
          color: isInteractive && !hasSig
              ? (isDark
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.08)
                  : const Color(0xFF0284C7).withValues(alpha: 0.05))
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: hasSig
                  ? Center(
                      child: SignaturePadDialog.buildSignatureImage(
                        signature,
                        height: 28,
                        fit: BoxFit.contain,
                        isDark: isDark,
                      ),
                    )
                  : Center(
                      child: isInteractive
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.draw_rounded,
                                  size: 13,
                                  color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap to sign',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
            ),
            Container(height: 1, color: borderColor.withValues(alpha: 0.6)),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
