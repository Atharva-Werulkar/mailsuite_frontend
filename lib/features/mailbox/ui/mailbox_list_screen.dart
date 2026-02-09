import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/ux_utils.dart';
import '../bloc/mailbox_bloc.dart';
import '../bloc/mailbox_event.dart';
import '../bloc/mailbox_state.dart';
import '../widgets/mailbox_list_tile.dart';
import 'mailbox_setup_screen.dart';

/// Mailbox List Screen - Show all configured mailboxes
class MailboxListScreen extends StatefulWidget {
  const MailboxListScreen({super.key});

  @override
  State<MailboxListScreen> createState() => _MailboxListScreenState();
}

class _MailboxListScreenState extends State<MailboxListScreen> {
  @override
  void initState() {
    super.initState();
    _loadMailboxes();
  }

  void _loadMailboxes() {
    context.read<MailboxBloc>().add(LoadMailboxesEvent());
  }

  void _addMailbox() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => const MailboxSetupScreen()),
        )
        .then((_) => _loadMailboxes());
  }

  void _deleteMailbox(String mailboxId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mailbox'),
        content: const Text(
          'Are you sure you want to delete this mailbox? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      UxUtils.buttonTap();
      context.read<MailboxBloc>().add(DeleteMailboxEvent(mailboxId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Mailboxes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMailboxes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<MailboxBloc, MailboxState>(
        listener: (context, state) {
          if (state is MailboxDeleted) {
            UxUtils.showSuccessSnackBar(
              context,
              'Mailbox deleted successfully',
            );
            _loadMailboxes();
          } else if (state is MailboxError) {
            UxUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is MailboxLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MailboxLoaded) {
            if (state.mailboxes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No mailboxes configured',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first mailbox to start tracking bounces',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _addMailbox,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Mailbox'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadMailboxes(),
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.mailboxes.length,
                itemBuilder: (context, index) {
                  final mailbox = state.mailboxes[index];
                  return MailboxListTile(
                    mailbox: mailbox,
                    onDelete: () => _deleteMailbox(mailbox.id),
                  );
                },
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.email, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load mailboxes',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMailboxes,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMailbox,
        icon: const Icon(Icons.add),
        label: const Text('Add Mailbox'),
      ),
    );
  }
}
