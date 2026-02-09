import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/email_bloc.dart';
import '../bloc/email_event.dart';
import '../bloc/email_state.dart';
import '../widgets/category_chip.dart';
import 'thread_view_screen.dart';

/// Email Detail Screen - Single email view
class EmailDetailScreen extends StatefulWidget {
  final String emailId;

  const EmailDetailScreen({super.key, required this.emailId});

  @override
  State<EmailDetailScreen> createState() => _EmailDetailScreenState();
}

class _EmailDetailScreenState extends State<EmailDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load email details
    context.read<EmailBloc>().add(LoadEmailDetailEvent(widget.emailId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Details'),
        actions: [
          BlocBuilder<EmailBloc, EmailState>(
            builder: (context, state) {
              if (state is EmailDetailLoaded) {
                final email = state.email;
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        email.isStarred ? Icons.star : Icons.star_border,
                        color: email.isStarred ? Colors.amber : null,
                      ),
                      onPressed: () {
                        context.read<EmailBloc>().add(
                          ToggleEmailStarEvent(
                            emailId: email.id,
                            isStarred: !email.isStarred,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.archive),
                      onPressed: () {
                        context.read<EmailBloc>().add(
                          ToggleEmailArchiveEvent(
                            emailId: email.id,
                            isArchived: true,
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'mark_unread':
                            context.read<EmailBloc>().add(
                              MarkEmailAsReadEvent(
                                emailId: email.id,
                                isRead: false,
                              ),
                            );
                            Navigator.pop(context);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context, email.id);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'mark_unread',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_unread),
                              SizedBox(width: 8),
                              Text('Mark as unread'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<EmailBloc, EmailState>(
        listener: (context, state) {
          if (state is EmailError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is EmailUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EmailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EmailDetailLoaded) {
            final email = state.email;

            // Mark as read when viewed
            if (!email.isRead) {
              Future.microtask(
                () => context.read<EmailBloc>().add(
                  MarkEmailAsReadEvent(emailId: email.id, isRead: true),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject
                  Text(
                    email.subject ?? '(No Subject)',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category badge
                  CategoryChip(category: email.category),
                  const SizedBox(height: 16),

                  // Email header card
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // From
                          _buildHeaderRow(
                            'From:',
                            email.fromName != null
                                ? '${email.fromName} <${email.fromAddress}>'
                                : email.fromAddress,
                          ),
                          const SizedBox(height: 8),

                          // To
                          if (email.toAddresses.isNotEmpty)
                            _buildHeaderRow(
                              'To:',
                              email.toAddresses.join(', '),
                            ),

                          // CC
                          if (email.ccAddresses != null &&
                              email.ccAddresses!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildHeaderRow(
                              'Cc:',
                              email.ccAddresses!.join(', '),
                            ),
                          ],

                          const SizedBox(height: 8),

                          // Date
                          _buildHeaderRow(
                            'Date:',
                            DateFormat.yMMMd().add_jm().format(
                              email.receivedAt,
                            ),
                          ),

                          // Attachments
                          if (email.hasAttachments) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Has attachments',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Email body
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (email.bodyPreview != null) ...[
                            Text(
                              email.bodyPreview!,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Divider(height: 32),
                          ],

                          // TODO: Fetch and render full email body (HTML or plain text)
                          // For now, show preview
                          const Text(
                            'Full email body will be displayed here',
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Thread context
                  if (email.threadId != null) ...[
                    Card(
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.forum),
                        title: const Text('View Full Conversation'),
                        subtitle: const Text('This email is part of a thread'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ThreadViewScreen(threadId: email.threadId!),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement reply
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reply - Coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.reply),
                          label: const Text('Reply'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement forward
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Forward - Coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.forward),
                          label: const Text('Forward'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is EmailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<EmailBloc>().add(
                        LoadEmailDetailEvent(widget.emailId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeaderRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String emailId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Email'),
        content: const Text('Are you sure you want to delete this email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<EmailBloc>().add(DeleteEmailEvent(emailId));
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
