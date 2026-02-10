import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/thread_bloc.dart';
import '../bloc/thread_event.dart';
import '../bloc/thread_state.dart';
import '../models/email_model.dart';
import '../widgets/category_chip.dart';

/// Thread View Screen - Conversation view with all messages
class ThreadViewScreen extends StatefulWidget {
  final String threadId;

  const ThreadViewScreen({super.key, required this.threadId});

  @override
  State<ThreadViewScreen> createState() => _ThreadViewScreenState();
}

class _ThreadViewScreenState extends State<ThreadViewScreen> {
  @override
  void initState() {
    super.initState();
    // Load thread with all messages
    context.read<ThreadBloc>().add(LoadThreadDetailEvent(widget.threadId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation'),
        actions: [
          BlocBuilder<ThreadBloc, ThreadState>(
            builder: (context, state) {
              if (state is ThreadDetailLoaded) {
                final thread = state.thread;
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.archive),
                      onPressed: () {
                        context.read<ThreadBloc>().add(
                          ToggleThreadArchiveEvent(
                            threadId: thread.id,
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
                            context.read<ThreadBloc>().add(
                              MarkThreadAsReadEvent(
                                threadId: thread.id,
                                isRead: false,
                              ),
                            );
                            Navigator.pop(context);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context, thread.id);
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
                                'Delete conversation',
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
      body: BlocConsumer<ThreadBloc, ThreadState>(
        listener: (context, state) {
          if (state is ThreadError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ThreadLoaded && state.message != null) {
            // Show feedback message from ThreadLoaded state
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                duration: const Duration(seconds: 1),
              ),
            );
          } else if (state is ThreadUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 1),
              ),
            );
          } else if (state is ThreadDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ThreadLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ThreadDetailLoaded) {
            final thread = state.thread;
            final messages = thread.messages ?? [];

            return Column(
              children: [
                // Thread header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        thread.subject,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${thread.participants.length} participants: ${thread.participants.join(", ")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${thread.messageCount} messages',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Messages list
                Expanded(
                  child: messages.isEmpty
                      ? const Center(child: Text('No messages in this thread'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return MessageCard(
                              message: message,
                              isFirst: index == 0,
                              isLast: index == messages.length - 1,
                            );
                          },
                        ),
                ),

                // Quick reply section
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
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
                            // TODO: Implement reply all
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reply All - Coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.reply_all),
                          label: const Text('Reply All'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is ThreadError) {
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
                      context.read<ThreadBloc>().add(
                        LoadThreadDetailEvent(widget.threadId),
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

  void _showDeleteConfirmation(BuildContext context, String threadId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Are you sure you want to delete this entire conversation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ThreadBloc>().add(DeleteThreadEvent(threadId));
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

/// Message Card Widget - Individual message in thread
class MessageCard extends StatefulWidget {
  final EmailModel message;
  final bool isFirst;
  final bool isLast;

  const MessageCard({
    super.key,
    required this.message,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool _isExpanded = true; // Expand first and last messages by default

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isFirst || widget.isLast;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: widget.isLast ? 2 : 1,
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: getCategoryColor(widget.message.category),
                    radius: 16,
                    child: Text(
                      _getInitial(
                        widget.message.fromName ?? widget.message.fromAddress,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.fromName ?? widget.message.fromAddress,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          widget.message.fromAddress,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat.MMMd().add_jm().format(
                      widget.message.receivedAt,
                    ),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                  ),
                ],
              ),

              // Message content (if expanded)
              if (_isExpanded) ...[
                const Divider(height: 24),

                // To addresses
                if (widget.message.toAddresses.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'To: ${widget.message.toAddresses.join(", ")}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),

                // Category
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CategoryChip(
                    category: widget.message.category,
                    mini: true,
                  ),
                ),

                // Body preview
                if (widget.message.bodyPreview != null)
                  Text(
                    widget.message.bodyPreview!,
                    style: const TextStyle(fontSize: 13),
                  )
                else
                  const Text(
                    '(No preview available)',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),

                // Attachments indicator
                if (widget.message.hasAttachments) ...[
                  const SizedBox(height: 12),
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
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                // Preview when collapsed
                const SizedBox(height: 4),
                Text(
                  widget.message.bodyPreview ?? '(No preview)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitial(String text) {
    if (text.isEmpty) return '?';
    return text[0].toUpperCase();
  }
}
