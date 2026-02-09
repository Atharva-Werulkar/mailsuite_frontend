import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/api_client.dart';
// Core
import 'core/theme/app_theme.dart';
// Features - Auth
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart' as auth_state;
import 'features/auth/services/auth_service.dart';
import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/register_screen.dart';
// Features - Bounce
import 'features/bounce/bloc/bounce_bloc.dart';
import 'features/bounce/services/bounce_service.dart';
import 'features/bounce/ui/dashboard_screen.dart';
// Features - Email (Phase 2)
import 'features/email/bloc/email_bloc.dart';
import 'features/email/bloc/thread_bloc.dart';
import 'features/email/services/email_service.dart';
import 'features/email/services/thread_service.dart';
import 'features/email/ui/inbox_screen.dart';
// Features - Mailbox
import 'features/mailbox/bloc/mailbox_bloc.dart';
import 'features/mailbox/services/mailbox_service.dart';
import 'features/mailbox/ui/mailbox_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get Supabase client
    final supabase = Supabase.instance.client;

    // Initialize API Client
    final apiClient = ApiClient(supabase);

    // Initialize Services
    final authService = AuthService(apiClient);
    final bounceService = BounceService(apiClient);
    final mailboxService = MailboxService(apiClient);
    final emailService = EmailService(apiClient);
    final threadService = ThreadService(apiClient);

    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authService)..add(CheckAuthStatusEvent()),
        ),

        // Bounce BLoC
        BlocProvider<BounceBloc>(
          create: (context) => BounceBloc(bounceService),
        ),

        // Mailbox BLoC
        BlocProvider<MailboxBloc>(
          create: (context) => MailboxBloc(mailboxService),
        ),

        // Email BLoC (Phase 2)
        BlocProvider<EmailBloc>(create: (context) => EmailBloc(emailService)),

        // Thread BLoC (Phase 2)
        BlocProvider<ThreadBloc>(
          create: (context) => ThreadBloc(threadService),
        ),
      ],
      child: MaterialApp(
        title: 'MailSuite',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/mailboxes': (context) => const MailboxListScreen(),
          '/inbox': (context) => const InboxScreen(),
        },
      ),
    );
  }
}

/// Auth Wrapper - Determines initial screen based on auth status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, auth_state.AuthState>(
      builder: (context, state) {
        if (state is auth_state.AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is auth_state.AuthAuthenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
