# kd_utils (My Utils)

[![pub package](https://img.shields.io/badge/pub-v0.2.1-blue.svg)](https://github.com/kundanm881/my_utils)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10.2-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.2.3-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A modern, production-ready collection of Flutter utilities, custom widgets, formatters, and extensions engineered for fast, clean, and reusable cross-platform app development.

---

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [1. Signature Pad Suite](#1-signature-pad-suite)
  - [Interactive Signature Pad Dialog](#interactive-signature-pad-dialog)
  - [Embedded Signature Canvas View](#embedded-signature-canvas-view)
  - [Signature Image Renderer](#signature-image-renderer)
- [2. Labour Attendance & Timesheet Card](#2-labour-attendance--timesheet-card)
- [3. Currency & Indian Number Formatting](#3-currency--indian-number-formatting)
  - [Real-time CurrencyInputFormatter](#real-time-currencyinputformatter)
  - [Indian Rupee Formatting & Words Conversion](#indian-rupee-formatting--words-conversion)
  - [Convenient Number Extensions](#convenient-number-extensions)
- [4. Date & Time Formatters](#4-date--time-formatters)
- [5. Platform Detection (AppPlatform)](#5-platform-detection-appplatform)
- [6. Interactive Date Picker](#6-interactive-date-picker)
- [7. OTP Pin View](#7-otp-pin-view)
- [8. Custom Painters](#8-custom-painters)
- [9. Handy Extensions](#9-handy-extensions)
  - [BuildContext Extensions](#buildcontext-extensions)
  - [SizedBox Spacing Extensions](#sizedbox-spacing-extensions)
- [10. Toast & Floating Snackbar](#10-toast--floating-snackbar)
- [License](#license)

---

## Features

- ✍️ **Signature Pad Suite**: Smooth gesture-based vector drawing canvas, base64 PNG export/import, gallery image picker support, and adaptive theme rendering.
- 📋 **Labour Attendance Card**: Physical bi-column punch-card timesheet preview with attendance tracking, overtime, advances, wage calculation, and shareable snapshot support.
- 💰 **Indian Currency System**: Real-time comma grouping (`1,50,000`), compact Lakh/Crore notation (`₹ 1.50 L`), and English number-to-words converter.
- 📅 **Date & Time Suite**: Indian-standard formatting, month names, weekdays, timestamps, and horizontal date pickers.
- 📱 **AppPlatform Helper**: Cross-platform environment checks (`isAndroid`, `isDesktop`, `isWindows`, `isWeb`), OS names, and icons.
- 🔢 **OTP View**: Flexible, customizable verification pin code input widget.
- ⚡ **Extensions**: `10.height`, `15.width`, `context.screenWidth`, `context.appTheme`, and date formatters.

---

## Getting Started

Add `kd_utils` to your `pubspec.yaml`:

```yaml
dependencies:
  kd_utils:
    path: ../my_utils # or git/hosted URL
```

Import everything with a single line:

```dart
import 'package:kd_utils/kd_utils.dart';
```

---

## 1. Signature Pad Suite

Capture, edit, upload, and render high-resolution digital signatures effortlessly.

### Interactive Signature Pad Dialog

Opens a full signature modal dialog with pencil drawing, undo, redo, clear, background toggle, and image file upload:

```dart
// Launch signature dialog modal
final String? base64Png = await SignaturePadDialog.show(
  context: context,
  title: 'Supervisor Authorization',
  subtitle: 'Please draw your signature below or upload an image',
  initialSignature: existingSignatureBase64,
  penColor: Colors.black,
  penStrokeWidth: 3.0,
);

if (base64Png != null) {
  print('Signature Base64: $base64Png');
}
```

#### Optional: Configure Default Image Picker Provider

Set a global image upload handler once during app startup (e.g., in `main()`):

```dart
import 'package:image_picker/image_picker.dart';

SignaturePadDialog.defaultOnPickImage = () async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked != null) {
    final bytes = await picked.readAsBytes();
    return base64Encode(bytes);
  }
  return null;
};
```

### Embedded Signature Canvas View

Embed the drawing canvas directly into any custom UI:

```dart
final controller = SignatureController(
  penColor: Colors.blueAccent,
  penStrokeWidth: 3.0,
);

// In your widget tree:
SignaturePadView(
  controller: controller,
  width: double.infinity,
  height: 250,
  backgroundColor: Colors.white,
);

// Actions:
controller.undo();
controller.clear();
final String? base64 = await controller.toBase64Png(width: 600, height: 250);
```

### Signature Image Renderer

Safely render any signature (whether stored as Base64 PNG data or network URL) with automatic dark/light mode ink adaptation:

```dart
SignaturePadDialog.buildSignatureImage(
  profile.signature,
  height: 60,
  isDark: Theme.of(context).brightness == Brightness.dark,
);
```

---

## 2. Labour Attendance & Timesheet Card

An authentic monthly bi-column timesheet and attendance card widget designed for workforce management, contractors, and construction sites.

```dart
LabourAttendanceCard(
  workerName: 'Ramesh Kumar',
  workerRole: 'Mason',
  workerPhone: '+91 98765 43210',
  workerId: 'WRK-104',
  siteName: 'Riverside Tower A',
  dailyWage: 850.0,
  month: DateTime.now(),
  dayAttendance: {
    1: LabourDayAttendance(day: 1, present: true, overtime: 2.0),
    2: LabourDayAttendance(day: 2, present: true, advance: 500.0),
    3: LabourDayAttendance(day: 3, absent: true),
  },
  workerSignature: workerBase64Sig,
  adminSignature: adminBase64Sig,
  adminName: 'Supervisor Singh',
  onAdminSign: () => handleAdminSign(),
  onPreviousMonth: () => goToPreviousMonth(),
  onNextMonth: () => goToNextMonth(),
  onShareSnapshot: () => shareCardSnapshot(),
)
```

---

## 3. Currency & Indian Number Formatting

### Real-time CurrencyInputFormatter

Attach to any Flutter `TextField` for automatic Indian comma grouping:

```dart
TextField(
  keyboardType: TextInputType.number,
  inputFormatters: const [
    CurrencyInputFormatter(allowDecimal: true),
  ],
  decoration: const InputDecoration(
    prefixText: '₹ ',
    hintText: 'Enter amount',
  ),
);
```

### Indian Rupee Formatting & Words Conversion

```dart
// Indian grouping
CurrencyInputFormatter.format(150000); // "1,50,000"
CurrencyInputFormatter.format(10000000); // "1,00,00,000"

// Rupee symbol formatting
formatRupees(150000); // "₹ 1,50,000"

// Compact Lakhs / Crores notation
formatCurrency(150000); // "₹ 1.50 L"
formatCurrency(25000000); // "₹ 2.50 Cr"

// Convert numbers into Indian English words
CurrencyInputFormatter.toWords(150000); 
// Output: "One Lakh Fifty Thousand Rupees"

// Parse strings back to double
CurrencyInputFormatter.parse("₹ 1,50,000"); // 150000.0
```

### Convenient Number Extensions

```dart
final double amount = 150000.0;

print(amount.toRupees());          // "₹ 1,50,000"
print(amount.toCurrency());        // "₹ 1.50 L"
print(amount.toIndianCurrency());  // "1,50,000"
print(amount.toRupeesInWords());   // "One Lakh Fifty Thousand Rupees"
```

---

## 4. Date & Time Formatters

```dart
final now = DateTime(2026, 10, 15, 14, 30);

// Global formatting functions
formatDate(now);            // "15 Oct 2026"
formatDateShort(now);       // "15/10/2026"
formatDateVerbose(now);     // "Thursday, 15 Oct 2026"
formatTime(now);            // "02:30 PM"
getCurrentMonthName();      // "October"
getMonthName(3);            // "March"
getWeekDay(1, short: true); // "Mon"

// Using DateTime extensions
now.toFormattedDate();        // "15 Oct 2026"
now.toFormattedDateShort();   // "15/10/2026"
now.toFormattedDateVerbose(); // "Thursday, 15 Oct 2026"
```

---

## 5. Platform Detection (AppPlatform)

Universal platform detection helper for conditional desktop/mobile logic:

```dart
if (AppPlatform.isDesktop) {
  // Windows, macOS, Linux
}

if (AppPlatform.isMobile) {
  // Android, iOS
}

// Operating system info & icon
print(AppPlatform.operatingSystemName); // 'Windows', 'Android', etc.
Icon(AppPlatform.platformIcon);        // Native platform icon
```

---

## 6. Interactive Date Picker

```dart
DatePickerView(
  currentDate: DateTime.now(),
  startDate: DateTime.now().subtract(const Duration(days: 30)),
  endDate: DateTime.now().add(const Duration(days: 30)),
  weekday: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
  onDateClick: (selectedDate) {
    print('Selected date: $selectedDate');
  },
)
```

---

## 7. OTP Pin View

```dart
OTPView(
  otpCount: 6,
  style: OTPStyle(
    cursorColor: Colors.blue,
    maxHeight: 56,
    inputBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    isDense: true,
    space: 12,
  ),
  onSubmit: (otp) {
    print('Entered OTP: $otp');
  },
)
```

---

## 8. Custom Painters

### DotLinePainter

Draw horizontal or vertical dotted separator lines with custom spacing, radius, and stroke caps:

```dart
CustomPaint(
  size: const Size(double.infinity, 1),
  painter: DotLinePainter(
    paintColor: Colors.grey.shade400,
    strokeWidth: 2,
    dotHeight: 4,
    space: 6,
    strokeCap: StrokeCap.round,
    axis: Axis.horizontal,
  ),
)
```

---

## 9. Handy Extensions

### BuildContext Extensions

```dart
final theme = context.appTheme;
final width = context.screenWidth;
final height = context.screenHeight;
final padding = context.viewPadding;
```

### SizedBox Spacing Extensions

Eliminate verbose `const SizedBox(height: ...)` widgets:

```dart
Column(
  children: [
    const Text('Header'),
    16.height, // SizedBox(height: 16.0)
    const Text('Body'),
    24.height, // SizedBox(height: 24.0)
  ],
);

Row(
  children: [
    const Icon(Icons.star),
    8.width,   // SizedBox(width: 8.0)
    const Text('Rating'),
  ],
);
```

---

## 10. Toast & Floating Snackbar

Display lightweight, overlay-based toast snackbars without requiring a `ScaffoldMessenger`:

```dart
kSnackBar(
  context,
  message: 'Worker details saved successfully!',
  duration: const Duration(seconds: 3),
  backgroundColor: const Color(0xFF059669),
);
```

---

## License

This package is licensed under the [MIT License](LICENSE).
