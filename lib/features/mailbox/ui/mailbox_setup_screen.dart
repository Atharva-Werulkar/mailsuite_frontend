import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/ux_utils.dart';
import '../bloc/mailbox_bloc.dart';
import '../bloc/mailbox_event.dart';
import '../bloc/mailbox_state.dart';
import '../models/mailbox_model.dart';

/// Mailbox Setup Screen - Add or configure email mailbox
class MailboxSetupScreen extends StatefulWidget {
  const MailboxSetupScreen({super.key});

  @override
  State<MailboxSetupScreen> createState() => _MailboxSetupScreenState();
}

class _MailboxSetupScreenState extends State<MailboxSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _imapHostController = TextEditingController(text: 'imap.gmail.com');
  final _imapPortController = TextEditingController(text: '993');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isTestingConnection = false;

  @override
  void dispose() {
    _emailController.dispose();
    _imapHostController.dispose();
    _imapPortController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _testConnection() {
    if (!_formKey.currentState!.validate()) return;

    UxUtils.buttonTap();
    context.read<MailboxBloc>().add(
      TestMailboxConnectionEvent(
        imapHost: _imapHostController.text,
        imapPort: int.parse(_imapPortController.text),
        username: _usernameController.text,
        password: _passwordController.text,
      ),
    );
  }

  void _saveMailbox() {
    if (!_formKey.currentState!.validate()) return;

    UxUtils.buttonTap();

    final request = MailboxCreateRequest(
      emailAddress: _emailController.text,
      imapHost: _imapHostController.text,
      imapPort: int.parse(_imapPortController.text),
      imapUsername: _usernameController.text,
      imapPassword: _passwordController.text,
      provider: 'gmail',
    );

    context.read<MailboxBloc>().add(AddMailboxEvent(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Mailbox')),
      body: BlocConsumer<MailboxBloc, MailboxState>(
        listener: (context, state) {
          if (state is MailboxConnectionTesting) {
            setState(() => _isTestingConnection = true);
          } else if (state is MailboxConnectionSuccess) {
            setState(() => _isTestingConnection = false);
            UxUtils.showSuccessSnackBar(context, state.message);
          } else if (state is MailboxConnectionFailed) {
            setState(() => _isTestingConnection = false);
            UxUtils.showErrorSnackBar(context, state.message);
          } else if (state is MailboxAdded) {
            UxUtils.showSuccessSnackBar(context, 'Mailbox added successfully!');
            Navigator.of(context).pop();
          } else if (state is MailboxError) {
            UxUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is MailboxLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Gmail IMAP Configuration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your Gmail credentials to connect your mailbox',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Email Address
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter your email address';
                      }
                      if (!value!.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // IMAP Host
                  TextFormField(
                    controller: _imapHostController,
                    decoration: const InputDecoration(
                      labelText: 'IMAP Host',
                      prefixIcon: Icon(Icons.dns),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter IMAP host';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // IMAP Port
                  TextFormField(
                    controller: _imapPortController,
                    decoration: const InputDecoration(
                      labelText: 'IMAP Port',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter IMAP port';
                      }
                      final port = int.tryParse(value!);
                      if (port == null || port < 1 || port > 65535) {
                        return 'Please enter a valid port number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'IMAP Username',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'IMAP Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          UxUtils.toggle();
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Test Connection Button
                  OutlinedButton.icon(
                    onPressed: isLoading || _isTestingConnection
                        ? null
                        : _testConnection,
                    icon: _isTestingConnection
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering),
                    label: Text(
                      _isTestingConnection
                          ? 'Testing Connection...'
                          : 'Test Connection',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _saveMailbox,
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(isLoading ? 'Saving...' : 'Save Mailbox'),
                  ),
                  const SizedBox(height: 24),

                  // Help Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Gmail Setup Instructions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Enable IMAP in Gmail settings\n'
                          '2. Use App Password instead of regular password\n'
                          '3. Host: imap.gmail.com\n'
                          '4. Port: 993\n'
                          '5. Enter your full email address as username',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
