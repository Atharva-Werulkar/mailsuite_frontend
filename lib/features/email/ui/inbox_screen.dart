import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/email_bloc.dart';
import '../bloc/email_event.dart';
import '../bloc/email_state.dart';
import '../widgets/category_chip.dart';
import '../widgets/email_list_tile.dart';
import 'email_detail_screen.dart';

/// Inbox Screen - Main email list view with category filtering
class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  final List<String> categories = [
    'ALL',
    'HUMAN',
    'TRANSACTIONAL',
    'NOTIFICATION',
    'MARKETING',
    'NEWSLETTER',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _scrollController.addListener(_onScroll);

    // Load initial emails (ALL category)
    context.read<EmailBloc>().add(LoadEmailsEvent());
    context.read<EmailBloc>().add(LoadCategoryCountsEvent());

    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadEmailsForCategory(categories[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when scrolled to 90%
      context.read<EmailBloc>().add(LoadMoreEmailsEvent());
    }
  }

  void _loadEmailsForCategory(String category) {
    if (category == 'ALL') {
      context.read<EmailBloc>().add(LoadEmailsEvent());
    } else {
      context.read<EmailBloc>().add(LoadEmailsEvent(category: category));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search emails...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<EmailBloc>().add(LoadEmailsEvent());
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (query) {
                    context.read<EmailBloc>().add(SearchEmailsEvent(query));
                  },
                ),
              ),

              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: categories.map((category) {
                  return Tab(
                    child: Row(
                      children: [
                        Text(category),
                        const SizedBox(width: 4),
                        BlocBuilder<EmailBloc, EmailState>(
                          builder: (context, state) {
                            if (state is EmailLoaded &&
                                state.categoryCounts != null) {
                              final count = category == 'ALL'
                                  ? state.categoryCounts!.total.values.fold(
                                      0,
                                      (a, b) => a + b,
                                    )
                                  : state.categoryCounts!.total[category] ?? 0;
                              if (count > 0) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getCategoryColor(category),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: BlocConsumer<EmailBloc, EmailState>(
        listener: (context, state) {
          if (state is EmailError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is EmailLoaded && state.message != null) {
            // Show feedback message from EmailLoaded state
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                duration: const Duration(seconds: 1),
              ),
            );
            // Clear the message after showing
            Future.microtask(() {
              if (context.mounted) {
                context.read<EmailBloc>().add(ClearMessageEvent());
              }
            });
          } else if (state is EmailUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 1),
              ),
            );
          } else if (state is EmailDeleted) {
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
          } else if (state is EmailEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else if (state is EmailLoaded || state is EmailLoadingMore) {
            final emails = state is EmailLoaded
                ? state.emails
                : (state as EmailLoadingMore).currentEmails;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<EmailBloc>().add(
                  RefreshEmailsEvent(
                    category: categories[_tabController.index] == 'ALL'
                        ? null
                        : categories[_tabController.index],
                  ),
                );
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: emails.length + (state is EmailLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= emails.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final email = emails[index];

                  return EmailListTile(
                    email: email,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EmailDetailScreen(emailId: email.id),
                        ),
                      );
                    },
                    onStar: () {
                      context.read<EmailBloc>().add(
                        ToggleEmailStarEvent(
                          emailId: email.id,
                          isStarred: !email.isStarred,
                        ),
                      );
                    },
                    onArchive: () {
                      context.read<EmailBloc>().add(
                        ToggleEmailArchiveEvent(
                          emailId: email.id,
                          isArchived: true,
                        ),
                      );
                    },
                    onMarkRead: () {
                      context.read<EmailBloc>().add(
                        MarkEmailAsReadEvent(
                          emailId: email.id,
                          isRead: !email.isRead,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement compose email
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compose email - Coming soon!')),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
