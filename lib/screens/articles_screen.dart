import 'package:flutter/material.dart';
import 'dart:math';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _selectedCategoryIndex = 0;
  int _currentTipIndex = 0;
  
  // List of health tips
  final List<Map<String, dynamic>> _healthTips = [
    {
      'tip': 'Drinking water before meals can help reduce overall calorie intake.',
      'icon': Icons.water_drop_outlined,
      'category': 'Nutrition'
    },
    {
      'tip': 'Taking a short walk after meals helps regulate blood sugar levels.',
      'icon': Icons.directions_walk_outlined,
      'category': 'Exercise'
    },
    {
      'tip': 'Deep breathing for 5 minutes can reduce stress hormone levels.',
      'icon': Icons.air_outlined,
      'category': 'Wellness'
    },
    {
      'tip': 'Eating fruits with their skin provides more fiber and nutrients.',
      'icon': Icons.apple_outlined,
      'category': 'Nutrition'
    },
    {
      'tip': 'Regular stretching improves flexibility and reduces risk of injury.',
      'icon': Icons.fitness_center_outlined,
      'category': 'Exercise'
    },
    {
      'tip': 'Getting 7-9 hours of sleep improves cognitive function and mood.',
      'icon': Icons.bedtime_outlined,
      'category': 'Wellness'
    },
    {
      'tip': 'Keeping a food journal increases awareness of eating habits.',
      'icon': Icons.book_outlined,
      'category': 'Nutrition'
    },
    {
      'tip': 'Adding lemon to water can aid digestion and provide vitamin C.',
      'icon': Icons.emoji_food_beverage_outlined,
      'category': 'Nutrition'
    },
    {
      'tip': 'Mindful eating helps prevent overeating and improves satisfaction.',
      'icon': Icons.psychology_outlined,
      'category': 'Mental Health'
    },
    {
      'tip': 'Strength training twice a week helps maintain muscle mass as you age.',
      'icon': Icons.fitness_center_outlined,
      'category': 'Exercise'
    },
    {
      'tip': 'Swapping sugary drinks for water can reduce daily calorie intake by 10%.',
      'icon': Icons.local_drink_outlined,
      'category': 'Nutrition'
    },
    {
      'tip': 'Spending time in nature can lower stress hormones and blood pressure.',
      'icon': Icons.park_outlined,
      'category': 'Wellness'
    }
  ];
  
  // Animation controllers for the tip card
  late AnimationController _tipAnimationController;
  late Animation<double> _tipAnimation;
  
  // Sample progress tracking (in a real app, this would be stored in a database)
  final Map<String, double> _articleProgress = {
    'Tips for a Healthier Life': 0.3,
    'Understanding Nutritional Labels': 0.5,
    'Benefits of Regular Exercise': 0.0,
    'Meal Planning 101': 0.7,
    'Stress Management Techniques': 0.2,
    'Sleep Health Fundamentals': 1.0,
    'Mindful Eating Practices': 0.0,
  };

  final List<String> _categories = [
    'All',
    'Nutrition',
    'Exercise',
    'Wellness',
    'Mental Health'
  ];
  
  final Map<String, String> _articleCategories = {
    'Tips for a Healthier Life': 'Wellness',
    'Understanding Nutritional Labels': 'Nutrition',
    'Benefits of Regular Exercise': 'Exercise',
    'Meal Planning 101': 'Nutrition',
    'Stress Management Techniques': 'Mental Health',
    'Sleep Health Fundamentals': 'Wellness',
    'Mindful Eating Practices': 'Nutrition',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Initialize tip animation controller
    _tipAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _tipAnimation = CurvedAnimation(
      parent: _tipAnimationController,
      curve: Curves.easeInOut,
    );
    
    // Set a random tip to start with
    _currentTipIndex = Random().nextInt(_healthTips.length);
    
    _animationController.forward();
    _tipAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tipAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _refreshTip() {
    setState(() {
      int newIndex;
      // Make sure we get a different tip
      do {
        newIndex = Random().nextInt(_healthTips.length);
      } while (newIndex == _currentTipIndex && _healthTips.length > 1);
      
      _currentTipIndex = newIndex;
    });
    
    // Animate the tip change
    _tipAnimationController.reset();
    _tipAnimationController.forward();
  }

  List<MapEntry<String, String>> _getFilteredArticles() {
    final allArticles = {
      'Tips for a Healthier Life': 
          'Learn the top 10 tips for maintaining a healthy lifestyle and improving your overall wellbeing.',
      'Understanding Nutritional Labels': 
          'A comprehensive guide to reading and understanding nutritional information on food packaging.',
      'Benefits of Regular Exercise': 
          'Discover how regular physical activity can improve your health and quality of life.',
      'Meal Planning 101': 
          'Learn how to plan balanced meals that fit your health goals and lifestyle.',
      'Stress Management Techniques': 
          'Effective ways to manage stress and improve your mental wellbeing.',
      'Sleep Health Fundamentals': 
          'Understand the importance of sleep and how to improve your sleep quality.',
      'Mindful Eating Practices': 
          'Learn how to develop a healthier relationship with food through mindfulness.',
    };
    
    // Filter by category
    var filteredArticles = Map<String, String>.from(allArticles);
    if (_selectedCategoryIndex != 0) { // Not "All"
      final categoryName = _categories[_selectedCategoryIndex];
      filteredArticles.removeWhere((key, _) => 
          _articleCategories[key] != categoryName);
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredArticles.removeWhere((key, value) => 
          !key.toLowerCase().contains(_searchQuery.toLowerCase()) && 
          !value.toLowerCase().contains(_searchQuery.toLowerCase()));
    }
    
    return filteredArticles.entries.toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _getFilteredArticles();
    final random = Random();
    final featuredArticleIndex = filteredArticles.isEmpty 
        ? 0 
        : random.nextInt(filteredArticles.length);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search articles...',
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
              )
            : const Text(
                'Learn',
                style: TextStyle(
                  color: Color(0xFF0B4C37),
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
                _animationController.reset();
                _animationController.forward();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmarks coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show health tip when not searching
          if (!_isSearching) _buildHealthTipCard(),
          _buildCategoriesBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (filteredArticles.isNotEmpty && !_isSearching && filteredArticles.length > 0) ...[
                  _buildFeaturedArticle(
                    filteredArticles[featuredArticleIndex].key, 
                    filteredArticles[featuredArticleIndex].value
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'All Articles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B4C37),
                      ),
                    ),
                  ),
                ],
                
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: filteredArticles.isEmpty 
                      ? _buildEmptyState() 
                      : FadeTransition(
                          opacity: _animation,
                          child: Column(
                            children: filteredArticles.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildArticleCard(
                                  entry.key,
                                  entry.value,
                                  _getIconForArticle(entry.key),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthTipCard() {
    final currentTip = _healthTips[_currentTipIndex];
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: FadeTransition(
        opacity: _tipAnimation,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCategoryColor(currentTip['category']).withOpacity(0.2),
                  _getCategoryColor(currentTip['category']).withOpacity(0.1),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        color: const Color(0xFF0B4C37),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'DAILY HEALTH TIP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B4C37),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          child: Text(
                            currentTip['category'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _getCategoryColor(currentTip['category']),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(currentTip['category']).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          currentTip['icon'],
                          color: _getCategoryColor(currentTip['category']),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentTip['tip'],
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: _refreshTip,
                      icon: const Icon(
                        Icons.refresh,
                        color: Color(0xFF0B4C37),
                        size: 20,
                      ),
                      tooltip: 'Show another tip',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Nutrition':
        return Colors.orange;
      case 'Exercise':
        return Colors.blue;
      case 'Mental Health':
        return Colors.purple;
      case 'Wellness':
        return const Color(0xFF0B4C37);
      default:
        return const Color(0xFF0B4C37);
    }
  }
  
  Widget _buildCategoriesBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: List.generate(
          _categories.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == _categories.length - 1 ? 16 : 0,
            ),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: _selectedCategoryIndex == index,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategoryIndex = index;
                    _animationController.reset();
                    _animationController.forward();
                  });
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: const Color(0xFF0B4C37),
              labelStyle: TextStyle(
                color: _selectedCategoryIndex == index
                    ? Colors.white
                    : Colors.black,
                fontWeight: _selectedCategoryIndex == index
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeaturedArticle(String title, String description) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B4C37), Color(0xFF1A8870)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Featured Article',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _articleProgress.containsKey(title) && _articleProgress[title]! > 0
                      ? Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: _articleProgress[title] ?? 0.0,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Continue Reading (${(_articleProgress[title]! * 100).toInt()}%)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Expanded(
                          child: Text(
                            'Start Reading',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(String title, String description, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle article tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening article: $title')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECF6F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF0B4C37),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B4C37),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _articleCategories[title] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              if (_articleProgress.containsKey(title) && _articleProgress[title]! > 0) ...[
                LinearProgressIndicator(
                  value: _articleProgress[title] ?? 0.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0B4C37)),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 8),
                Text(
                  _articleProgress[title]! >= 1.0 
                      ? 'Completed'
                      : '${(_articleProgress[title]! * 100).toInt()}% complete',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Read Article',
                      style: TextStyle(
                        color: Color(0xFF0B4C37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF0B4C37),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No articles found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or category',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForArticle(String title) {
    final category = _articleCategories[title];
    
    switch (category) {
      case 'Nutrition':
        return Icons.restaurant_menu;
      case 'Exercise':
        return Icons.fitness_center;
      case 'Mental Health':
        return Icons.psychology;
      case 'Wellness':
        return Icons.spa;
      default:
        return Icons.article;
    }
  }
}