# 💸 Expense Tracker

A modern and user-friendly **Flutter Expense Tracker** application built for the **CyphLab Flutter Developer Internship Practical Task**.

The app helps users record, manage, search, filter, and analyze their daily expenses using a clean **Material 3 UI** with **Firebase Cloud Firestore** for persistent data storage.

---

## ✨ Features

- ➕ Add new expenses
- ✏️ Edit existing expenses
- 🗑️ Delete expenses with confirmation
- ☁️ Store expense data using Firebase Cloud Firestore
- 📊 View monthly expense totals
- 📅 Navigate between previous and current months
- 🧾 View recent expenses on the dashboard
- 📚 View complete expense history
- 🔎 Search expenses by title, category, or note
- 🏷️ Filter expenses by category
- 📆 Filter expenses by:
  - Today
  - This Month
  - Custom Date
- ✅ Form validation
- 📝 Optional notes for expenses
- ⏳ Loading states
- 📭 Empty states
- ⚠️ Error states
- 🌙 Light and Dark mode
- 🎨 Professional light-blue Material 3 design
- 📱 Responsive Android UI

---

## 🧾 Expense Details

Each expense contains:

- 🏷️ Title
- 💰 Amount
- 📂 Category
- 📅 Date
- 📝 Optional note

---

## 🗂️ Categories

The application supports the following expense categories:

- 🍔 Food
- 🚌 Transport
- 🛍️ Shopping
- 🧾 Bills
- 🏥 Health
- 🎬 Entertainment
- 🎓 Education
- 📦 Other

---

## 🛠️ Tech Stack

- **Flutter**
- **Dart**
- **Firebase Core**
- **Cloud Firestore**
- **Material 3**
- **Fake Cloud Firestore** for testing

---

## 📁 Project Structure

```text
lib/
├── firebase_options.dart
├── main.dart
│
├── models/
│   └── expense.dart
│
├── screens/
│   ├── add_edit_expense_screen.dart
│   ├── dashboard_screen.dart
│   └── history_screen.dart
│
└── services/
    └── expense_service.dart

test/
├── add_expense_screen_test.dart
├── dashboard_screen_test.dart
├── expense_service_test.dart
├── expense_test.dart
├── history_screen_test.dart
└── widget_test.dart
```

---

## 🔥 Firebase Integration

The application uses **Firebase Cloud Firestore** to store and manage expense data.

The main Firestore collection is:

```text
expenses
```

Each document contains data similar to:

```text
title: String
amount: Number
category: String
date: Timestamp
note: String | null
```

---

## 🚀 Getting Started

### 1️⃣ Prerequisites

Make sure the following tools are installed:

- Flutter SDK
- Dart SDK
- Android SDK
- Firebase CLI
- FlutterFire CLI

Check your Flutter installation:

```bash
flutter doctor
```

---

### 2️⃣ Clone the Repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
cd expense_tracker
```

---

### 3️⃣ Install Dependencies

```bash
flutter pub get
```

---

### 4️⃣ Configure Firebase

Login to Firebase:

```bash
firebase login
```

Configure FlutterFire:

```bash
flutterfire configure
```

Select your Firebase project and Android platform when prompted.

---

### 5️⃣ Run the Application

Check available devices:

```bash
flutter devices
```

Run the app:

```bash
flutter run
```

---

## 🧪 Testing

Run all automated tests:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

Format the project:

```bash
dart format lib test
```

---

## 📦 Build Release APK

Create a release APK using:

```bash
flutter build apk --release
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎨 UI / UX Design

The application uses a clean finance-inspired interface with:

- 💙 Light-blue color palette
- 🤍 White surface cards
- 🔵 Soft blue accents
- 🔲 Rounded cards and input fields
- 🧭 Clear visual hierarchy
- 🏷️ Category-specific icons and colors
- 📊 Monthly summary dashboard
- 🌙 Dark mode support
- 📱 Responsive layouts

---

## 📊 Dashboard

The dashboard provides:

- Selected month
- Monthly expense total
- Expense count
- Previous month navigation
- Current month navigation
- Recent expenses
- Quick access to expense history
- Quick Add Expense button

---

## 🔍 Search & Filters

Users can search expenses by:

- Title
- Category
- Note

Search is applied when the **Search button** or keyboard **Search action** is pressed.

Users can also filter expenses using:

- Category
- Today
- This Month
- Custom Date

---

## 🔄 CRUD Operations

The application supports complete CRUD functionality:

- **Create** — Add a new expense
- **Read** — View dashboard and expense history
- **Update** — Edit an existing expense
- **Delete** — Remove an expense with confirmation

---

## 🧪 Testing Approach

The project contains automated tests for:

- Expense model
- Firestore service
- Add expense form
- Edit expense flow
- Delete expense flow
- Dashboard
- Monthly totals
- Category filtering
- Date filtering
- Search behavior
- History screen
- UI validation

---

## 🤖 AI Tools Used

AI assistance was used during development for:

- Application planning
- Flutter architecture guidance
- UI/UX improvement ideas
- Debugging
- Test design
- Code review
- Documentation

All AI-generated suggestions were reviewed and integrated into the final implementation.

---

## 🔮 Future Improvements

Possible future enhancements include:

- 🔐 Firebase Authentication
- 📈 Expense charts and analytics
- 💳 Monthly budget limits
- 📊 Category spending breakdown
- 🔁 Recurring expenses
- 📤 Export expense reports
- ☁️ User-specific cloud backup
- 🔔 Budget notifications
- 📱 Additional platform support

---

## 👩‍💻 Author

**Pavani**

Flutter Developer Internship Practical Task

---

## 🔗 Submission Links

### GitHub Repository

```text
ADD_GITHUB_REPOSITORY_LINK_HERE
```

### 🎥 Demo Video

```text
ADD_GOOGLE_DRIVE_OR_YOUTUBE_LINK_HERE
```

### 📦 APK Download

```text
ADD_APK_DOWNLOAD_LINK_HERE
```

---

## 📄 License

This project was created for educational and internship evaluation purposes.

---

⭐ If you find this project useful, feel free to give the repository a star!
