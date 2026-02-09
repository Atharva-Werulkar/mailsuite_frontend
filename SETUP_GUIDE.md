# MailSuite Frontend - Quick Setup Guide

## ✅ What Has Been Created

### 📁 Folder Structure (BLoC + MVVM)

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart       ✅ API endpoints & config
│   │   └── app_constants.dart       ✅ App-wide constants
│   ├── network/
│   │   └── api_client.dart          ✅ Dio + Supabase HTTP client
│   ├── theme/
│   │   └── app_theme.dart           ✅ Light & dark themes
│   └── utils/
│       ├── ux_utils.dart            ✅ UX utilities with haptics
│       └── helpers.dart             ✅ Helper functions
│
├── features/
│   ├── bounce/
│   │   ├── models/
│   │   │   └── bounce_model.dart    ✅ Bounce data models
│   │   ├── bloc/
│   │   │   ├── bounce_bloc.dart     ✅ Business logic
│   │   │   ├── bounce_event.dart    ✅ Events
│   │   │   └── bounce_state.dart    ✅ States
│   │   ├── services/
│   │   │   └── bounce_service.dart  ✅ API calls
│   │   ├── ui/
│   │   │   ├── dashboard_screen.dart    ✅ Main dashboard
│   │   │   └── bounce_list_screen.dart  ✅ Bounce list
│   │   └── widgets/
│   │       ├── stats_card.dart          ✅ Stats card widget
│   │       ├── bounce_list_tile.dart    ✅ List tile widget
│   │       └── bounce_breakdown_chart.dart ✅ Pie chart
│   │
│   └── mailbox/
│       ├── models/
│       │   └── mailbox_model.dart       ✅ Mailbox data models
│       ├── bloc/
│       │   ├── mailbox_bloc.dart        ✅ Business logic
│       │   ├── mailbox_event.dart       ✅ Events
│       │   └── mailbox_state.dart       ✅ States
│       ├── services/
│       │   └── mailbox_service.dart     ✅ API calls
│       ├── ui/
│       │   └── mailbox_setup_screen.dart ✅ Setup screen
│       └── widgets/
│           └── mailbox_form.dart        ✅ Form widget
│
└── main.dart                        ✅ App entry with BLoC providers
```

## 🚀 Next Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Configure Environment

Edit `.env` file with your credentials:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# API Configuration
API_BASE_URL=http://localhost:3000
```

### 3. Start Backend API

Make sure your backend is running on `http://localhost:3000`

### 4. Run the App

```bash
flutter run
```

## 📋 Features Implemented

### ✅ Dashboard Screen
- Total failures count card
- Unique failed emails count card
- Bounce breakdown pie chart (Hard/Soft/Unknown)
- Recent trend list (last 7 days)
- Pull-to-refresh
- Navigate to full bounce list

### ✅ Bounce List Screen
- Paginated list of all email bounces
- Shows: email, bounce type, error code, failure count
- Infinite scroll (load more)
- Pull-to-refresh
- Filter by mailbox (placeholder)

### ✅ Mailbox Setup Screen
- Add Gmail IMAP configuration
- Test IMAP connection
- Form validation
- Password visibility toggle
- Setup instructions

### ✅ Core Features
- **State Management**: BLoC pattern with flutter_bloc
- **API Integration**: Dio + Supabase authentication
- **Theming**: Light & Dark theme support
- **UX Enhancements**: Haptic feedback, animated transitions
- **Error Handling**: User-friendly error messages

## 🎯 API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/bounces` | GET | Fetch bounces (paginated) |
| `/bounces/unique` | GET | Get unique failed emails count |
| `/bounces/stats` | GET | Get bounce statistics |
| `/mailboxes` | GET | List user's mailboxes |
| `/mailboxes` | POST | Add new mailbox |
| `/mailboxes/:id` | PUT | Update mailbox |
| `/mailboxes/:id` | DELETE | Delete mailbox |

## 🔧 Configuration Options

### API Base URL
Change in `.env`:
```env
API_BASE_URL=http://10.0.2.2:3000  # Android Emulator
API_BASE_URL=http://localhost:3000  # iOS Simulator
API_BASE_URL=https://api.yourdomain.com  # Production
```

### Pagination
Change in `app_constants.dart`:
```dart
static const int defaultPageSize = 50;  // Default: 50
```

### Theme Colors
Modify in `app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF2563EB);
static const Color secondaryColor = Color(0xFF10B981);
```

## 📱 Testing Flow

### 1. Test Dashboard
1. Launch app
2. Should see dashboard with stats
3. If no data, shows "No data available"

### 2. Test Mailbox Setup
1. Navigate to Mailbox Setup (add FAB button to navigate)
2. Fill in Gmail credentials
3. Click "Test Connection"
4. If successful, click "Save Mailbox"

### 3. Test Bounce List
1. Click "View All" on dashboard
2. Should see paginated list
3. Scroll to bottom to load more
4. Pull down to refresh

## 🐛 Common Issues & Solutions

### Issue: "Connection refused"
**Solution**: Update API_BASE_URL in `.env`
- Android Emulator: `http://10.0.2.2:3000`
- iOS Simulator: `http://localhost:3000`

### Issue: "Failed to load .env"
**Solution**: 
1. Check `.env` file exists in project root
2. Verify `pubspec.yaml` includes `.env` in assets
3. Run `flutter clean && flutter pub get`

### Issue: "Supabase not initialized"
**Solution**: Add valid Supabase credentials in `.env`

### Issue: "IMAP connection failed"
**Solution**: 
1. Enable IMAP in Gmail settings
2. Use App Password (not regular password)
3. Check firewall/antivirus

## 📦 Dependencies Installed

```yaml
flutter_bloc: ^8.1.6          # State management
equatable: ^2.0.7             # Value equality
dio: ^5.7.0                   # HTTP client
supabase_flutter: ^2.10.0     # Supabase
fl_chart: ^0.69.2             # Charts
intl: ^0.19.0                 # Date formatting
url_launcher: ^6.3.1          # Launch URLs
flutter_dotenv: ^5.2.1        # Environment config
```

## 🎨 UI Components

All screens use Material Design 3 with:
- Cards with elevation
- Rounded corners (12px)
- Color-coded bounce types (Red/Orange/Gray)
- Haptic feedback on interactions
- Loading indicators
- Error states
- Empty states

## 🔐 Authentication

Using Supabase Auth:
- JWT token automatically added to API requests
- Token refresh handled automatically
- User session management

## 📈 Next Phase Features (Phase 2)

- Email content preview
- Advanced filtering
- Bulk actions
- Export to CSV
- Email search
- Multi-mailbox support
- Notifications
- Analytics dashboard

## ✅ Checklist Before First Run

- [ ] `.env` file created with valid credentials
- [ ] Backend API is running
- [ ] `flutter pub get` executed successfully
- [ ] Database schema is set up (from Phase 1 doc)
- [ ] Supabase project created and configured

## 🎓 Code Structure Guidelines

### Adding New Feature
1. Create folder in `features/`
2. Add: `models/`, `bloc/`, `services/`, `ui/`, `widgets/`
3. Register BLoC in `main.dart`
4. Follow naming conventions

### BLoC Pattern
- Events: `LoadXEvent`, `UpdateXEvent`
- States: `XLoading`, `XLoaded`, `XError`
- Always emit loading state first

### API Service
- Use try-catch for all API calls
- Throw exceptions with clear messages
- Use ApiClient from core/network

## 📞 Need Help?

Refer to:
- `README_PHASE1.md` - Full documentation
- `PHASE_1_CORE_MVP.md` - Original requirements
- Flutter docs: https://flutter.dev
- BLoC docs: https://bloclibrary.dev

---

**Status**: ✅ Phase 1 Frontend Complete
**Next**: Run `flutter pub get` and start the app!
