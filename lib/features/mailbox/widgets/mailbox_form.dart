import 'package:flutter/material.dart';

/// Mailbox Form Widget - Reusable form for mailbox configuration
class MailboxForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController imapHostController;
  final TextEditingController imapPortController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onTestConnection;
  final VoidCallback onSave;
  final bool isLoading;

  const MailboxForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.imapHostController,
    required this.imapPortController,
    required this.usernameController,
    required this.passwordController,
    required this.onTestConnection,
    required this.onSave,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: imapHostController,
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
          TextFormField(
            controller: imapPortController,
            decoration: const InputDecoration(
              labelText: 'IMAP Port',
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter IMAP port';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
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
          TextFormField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter password';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: isLoading ? null : onTestConnection,
            child: const Text('Test Connection'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading ? null : onSave,
            child: Text(isLoading ? 'Saving...' : 'Save Mailbox'),
          ),
        ],
      ),
    );
  }
}
