import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PlayWithFriendScreen extends StatefulWidget {
  const PlayWithFriendScreen({Key? key}) : super(key: key);

  @override
  State<PlayWithFriendScreen> createState() => _PlayWithFriendScreenState();
}

class _PlayWithFriendScreenState extends State<PlayWithFriendScreen> {
  late Future<List<dynamic>> _playersFuture;
  late Future<List<dynamic>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _playersFuture = ApiService.getAvailablePlayers();
    _requestsFuture = ApiService.getPendingRequests();
  }

  Future<void> _sendRequest(String playerId) async {
    try {
      await ApiService.sendFriendRequest(playerId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent!')),
      );
      setState(() => _loadData());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await ApiService.acceptRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted!')),
      );
      setState(() => _loadData());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      await ApiService.rejectRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected')),
      );
      setState(() => _loadData());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Play with Friend'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Available Players'),
              Tab(text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Available Players Tab
            FutureBuilder<List<dynamic>>(
              future: _playersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final players = snapshot.data ?? [];

                if (players.isEmpty) {
                  return const Center(
                    child: Text('No online players available'),
                  );
                }

                return ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(player['username']),
                        subtitle: Text(
                          'Wins: ${player['wins']} | Losses: ${player['losses']}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _sendRequest(player['id']),
                          child: const Text('Challenge'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Requests Tab
            FutureBuilder<List<dynamic>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final requests = snapshot.data ?? [];

                if (requests.isEmpty) {
                  return const Center(
                    child: Text('No pending requests'),
                  );
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('${request['username']} challenged you'),
                        subtitle: Text(
                          'Wins: ${request['wins']} | Losses: ${request['losses']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _acceptRequest(request['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text('Accept'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _rejectRequest(request['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Deny'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
