import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/ux_utils.dart';
import '../bloc/bounce_bloc.dart';
import '../bloc/bounce_event.dart';
import '../bloc/bounce_state.dart';
import '../widgets/bounce_list_tile.dart';

/// Bounce List Screen - Shows paginated list of all bounces
class BounceListScreen extends StatefulWidget {
  const BounceListScreen({super.key});

  @override
  State<BounceListScreen> createState() => _BounceListScreenState();
}

class _BounceListScreenState extends State<BounceListScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedMailboxId;

  @override
  void initState() {
    super.initState();
    _loadBounces();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadBounces() {
    context.read<BounceBloc>().add(LoadBouncesEvent(
          mailboxId: _selectedMailboxId,
        ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<BounceBloc>().state;
      if (state is BounceLoaded && state.hasMore) {
        context.read<BounceBloc>().add(LoadMoreBouncesEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Bounces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              UxUtils.buttonTap();
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: BlocConsumer<BounceBloc, BounceState>(
        listener: (context, state) {
          if (state is BounceError) {
            UxUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is BounceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BounceLoaded || state is BounceLoadingMore) {
            final bounces = state is BounceLoaded
                ? state.bounces
                : (state as BounceLoadingMore).currentBounces;

            if (bounces.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<BounceBloc>().add(
                      RefreshBouncesEvent(mailboxId: _selectedMailboxId),
                    );
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: bounces.length + (state is BounceLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == bounces.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  return BounceListTile(bounce: bounces[index]);
                },
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No bounces found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Email bounces will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // TODO: Implement filter dialog for mailbox selection
    UxUtils.showInfoSnackBar(context, 'Filter feature coming soon');
  }
}
