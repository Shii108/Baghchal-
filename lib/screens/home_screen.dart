import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/baghchal_screen.dart';
import '../theme/app_theme.dart';
import '../models/ai_difficulty.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    try {
      final isGuest = await ApiService.isGuest();
      setState(() => _isGuest = isGuest);
      
      if (!isGuest) {
        await _loadUser();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error checking user status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await ApiService.getCurrentUser();
      setState(() => _user = user);
    } catch (e) {
      print('Error loading user: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      if (_isGuest) {
        await ApiService.clearGuest();
      } else {
        await ApiService.logout();
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baghchal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_user != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${_user!['username']}!',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Wins: ${_user!['wins']} | Losses: ${_user!['losses']}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else if (_isGuest) ...[
                    Card(
                      color: Colors.grey[800],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, color: Colors.amber),
                                const SizedBox(width: 12),
                                Text(
                                  'Guest Mode',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Your progress won\'t be saved. Sign up or login to keep your stats!',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildGameModeCard(
                        context,
                        icon: Icons.sports_esports,
                        title: 'Play vs AI',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BaghchalScreen(
                              theme: AppTheme.green,
                              onThemeChange: () {},
                              difficulty: AIDifficulty.medium,
                              onDifficultyChange: () {},
                            ),
                          ),
                        ),
                      ),
                      _buildGameModeCard(
                        context,
                        icon: Icons.people,
                        title: 'Play with Friend',
                        onTap: () => Navigator.of(context).pushNamed('/play-with-friend'),
                      ),
                      _buildGameModeCard(
                        context,
                        icon: Icons.history,
                        title: 'Statistics',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon!')),
                          );
                        },
                      ),
                      _buildGameModeCard(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
