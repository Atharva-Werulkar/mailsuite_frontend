# MailSuite Frontend - Phase 1 Core MVP

Flutter application for email bounce detection and management.

## 📋 Features

- **Email Bounce Detection**: Automatically detect and track email bounces
- **Dashboard**: View bounce statistics and trends
- **Mailbox Management**: Connect Gmail accounts via IMAP
- **Bounce Classification**: Hard, Soft, and Unknown bounce types
- **Real-time Sync**: Automatic email synchronization

## 🏗️ Architecture

This project follows **BLoC (Business Logic Component) + MVVM** architecture:

```
lib/
├── core/                   # Core utilities and configurations
│   ├── constants/         # API and app constants
│   ├── network/           # HTTP client (Dio + Supabase)
│   ├── theme/             # App theming
│   └── utils/             # Helper utilities & UX utils
│
├── features/              # Feature modules
│   ├── bounce/
│   │   ├── models/        # Data models
│   │   ├── bloc/          # BLoC (State Management)
│   │   ├── services/      # API services
│   │   ├── ui/            # Screens/Pages
│   │   └── widgets/       # Reusable widgets
│   │
│   └── mailbox/
│       ├── models/
│       ├── bloc/
│       ├── services/
│       ├── ui/
│       └── widgets/
│
└── main.dart              # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.10.8)
- Dart SDK
- Android Studio / VS Code
- Backend API running (see backend setup)

### Installation

1. **Clone the repository**
   ```bash
   cd mailsuite_frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Create `.env` file in the root directory:
   ```env
   # Supabase Configuration
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key

   # API Configuration
   API_BASE_URL=http://localhost:3000
   ```

4. **Add .env to assets in pubspec.yaml** (already configured)

5. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

- **flutter_bloc**: ^8.1.6 - State management
- **equatable**: ^2.0.7 - Value equality
- **dio**: ^5.7.0 - HTTP client
- **supabase_flutter**: ^2.10.0 - Supabase integration
- **fl_chart**: ^0.69.2 - Charts and graphs
- **intl**: ^0.19.0 - Internationalization
- **url_launcher**: ^6.3.1 - Launch URLs
- **flutter_dotenv**: ^5.2.1 - Environment configuration

## 🔧 Configuration

### Backend API

Update the API base URL in `.env`:
```env
API_BASE_URL=http://localhost:3000  # Local development
# API_BASE_URL=https://api.yourdomain.com  # Production
```

### Supabase Setup

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key
3. Update `.env` with your credentials

### Gmail IMAP Setup

To connect Gmail accounts:
1. Enable IMAP in Gmail settings
2. Generate an App Password (don't use regular password)
3. Use these credentials in the app:
   - Host: `imap.gmail.com`
   - Port: `993`
   - Username: Your Gmail address
   - Password: App Password

## 📱 Screens

### Dashboard Screen
- Total failures count
- Unique failed emails count
- Bounce type breakdown (pie chart)
- Recent trend list

### Bounce List Screen
- Paginated list of all bounces
- Filter by mailbox
- Pull-to-refresh
- Infinite scroll

### Mailbox Setup Screen
- Add new Gmail account
- Test IMAP connection
- Configure IMAP settings
- View setup instructions

## 🎨 Theme

The app supports both light and dark themes with automatic system theme detection.

Primary colors:
- Primary: Blue (#2563EB)
- Secondary: Green (#10B981)
- Error: Red (#EF4444)

## 📝 State Management

Using **BLoC Pattern**:

### Bounce BLoC
- **Events**: LoadBouncesEvent, LoadMoreBouncesEvent, RefreshBouncesEvent
- **States**: BounceLoading, BounceLoaded, BounceError

### Mailbox BLoC
- **Events**: LoadMailboxesEvent, AddMailboxEvent, TestConnectionEvent
- **States**: MailboxLoading, MailboxLoaded, MailboxError

## 🔌 API Integration

The app communicates with the backend API through these endpoints:

- `GET /bounces` - Fetch bounces with pagination
- `GET /bounces/unique` - Get unique failed emails count
- `GET /bounces/stats` - Get bounce statistics
- `POST /mailboxes` - Add new mailbox
- `GET /mailboxes` - List user's mailboxes
- `PUT /mailboxes/:id` - Update mailbox
- `DELETE /mailboxes/:id` - Delete mailbox

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📦 Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🐛 Troubleshooting

### Common Issues

1. **Connection Error**
   - Check backend API is running
   - Verify API_BASE_URL in .env
   - Check network connectivity

2. **IMAP Connection Failed**
   - Enable IMAP in Gmail
   - Use App Password, not regular password
   - Check firewall settings

3. **Build Errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Flutter version compatibility

## 📄 License

This project is part of MailSuite application.

## 👥 Contributors

- Development Team

## 📞 Support

For issues and questions, please open an issue on GitHub.
