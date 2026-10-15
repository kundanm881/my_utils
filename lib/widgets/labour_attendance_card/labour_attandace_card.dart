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
  });

  @override
  State<LabourAttendanceCard> createState() => _LabourAttendanceCardState();
}

class _LabourAttendanceCardState extends State<LabourAttendanceCard> {
  // 0 = Full Card, 1 = Days 1-15, 2 = Days 16-31 (Mobile bi-column switcher)
  int _viewMode = 0;

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
      final rec = widget.dayAttendance[d];
      if (rec != null) {
        if (rec.present) computedPresent++;
        if (rec.absent) computedAbsent++;
        computedOt += rec.overtime;
        computedAdvance += rec.advance;
      }
    }

    final int effectivePresent = widget.totalPresent ?? computedPresent;
    final int effectiveAbsent = widget.totalAbsent ?? computedAbsent;
    final double effectiveOt = widget.totalOt ?? computedOt;
    final double effectiveAdvance = widget.totalAdvance ?? computedAdvance;

    final double hourlyRate = widget.dailyWage > 0 ? widget.dailyWage / 8.0 : 0.0;
    final double computedGross = (effectivePresent * widget.dailyWage) + (effectiveOt * hourlyRate);
    final double effectiveGross = widget.grossEarnings ?? computedGross;
    final double effectiveNet = widget.netPayable ?? (effectiveGross - effectiveAdvance);

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
                          _buildCardHeader(isDark, cardWidth, effectiveAdvance),
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
  Widget _buildCardHeader(bool isDark, double cardWidth, double totalAdvancePaid) {
    final borderColor = isDark ? const Color(0xFF475569) : const Color(0xFF1E293B);
    final monthStr = DateFormat('MMMM yyyy').format(widget.month).toUpperCase();

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
          child: Column(
            children: [
              // Row 1: Name, Role, Month
              Row(
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
                      'DESIGNATION / ROLE',
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
                      isLast: true,
                    ),
                  ),
                ],
              ),
              Container(height: 1, color: borderColor),
              // Row 2: Wage, Site, Advances
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _metaCell(
                      'DAILY RATE (WAGE)',
                      widget.dailyWage > 0
                          ? '${widget.currencySymbol}${widget.dailyWage.toInt()} / DAY'
                          : 'NOT SET',
                      isDark: isDark,
                      borderColor: borderColor,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _metaCell(
                      'ASSIGNED SITE',
                      widget.siteName?.toUpperCase() ?? 'GENERAL',
                      isDark: isDark,
                      borderColor: borderColor,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: _metaCell(
                      'ADVANCE PAID',
                      totalAdvancePaid > 0
                          ? '${widget.currencySymbol}${totalAdvancePaid.toInt()}'
                          : '-',
                      isDark: isDark,
                      borderColor: borderColor,
                      isLast: true,
                      highlightColor: totalAdvancePaid > 0 ? const Color(0xFFD97706) : null,
                    ),
                  ),
                ],
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

    final record = widget.dayAttendance[day];
    final double advance = record?.advance ?? 0.0;
    final advanceStr = advance > 0 ? '${widget.currencySymbol}${advance.toInt()}' : '-';
    final advanceColor = advance > 0 ? const Color(0xFFD97706) : null;

    if (record == null) {
      return [
        _cell('$day', isBold: true, isDark: isDark),
        _attendanceCell(first: '-', second: '', isDark: isDark, borderColor: borderColor),
        _cell('-', isDark: isDark),
        _cell(advanceStr, color: advanceColor, isBold: advance > 0, isDark: isDark),
        _cell('-', isDark: isDark),
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
      );
    }

    return [
      _cell('$day', isBold: true, isDark: isDark),
      _attendanceCell(
        first: firstStatus,
        second: '',
        color: statusColor,
        isBold: true,
        isDark: isDark,
        borderColor: borderColor,
      ),
      _cell(
        otStr,
        color: record.overtime > 0 ? const Color(0xFFD97706) : null,
        isBold: record.overtime > 0,
        isDark: isDark,
      ),
      _cell(
        advanceStr,
        color: advanceColor,
        isBold: advance > 0,
        isDark: isDark,
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
  }) {
    Color effectiveColor = color ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    if (isDimmed) effectiveColor = effectiveColor.withValues(alpha: 0.28);

    return SizedBox(
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
  }

  Widget _attendanceCell({
    required String first,
    required String second,
    required bool isDark,
    required Color borderColor,
    Color? color,
    bool isBold = false,
    bool isDimmed = false,
  }) {
    Color effectiveColor = color ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    if (isDimmed) effectiveColor = effectiveColor.withValues(alpha: 0.28);

    return SizedBox(
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
