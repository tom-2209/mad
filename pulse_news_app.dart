import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => NewsProvider(),
      child: const PulseDailyApp(),
    ),
  );
}

class PulseDailyApp extends StatelessWidget {
  const PulseDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Mixing Serif and Sans-Serif for an editorial look
        textTheme: GoogleFonts.libreFranklinTextTheme(),
        colorSchemeSeed: Colors.black,
      ),
      home: const NewsDashboard(),
    );
  }
}

// --- DATA MODEL ---
class Article {
  final String id, title, description, imageUrl, category, author, time;
  final bool isBreaking, isTrending;
  bool isBookmarked;

  Article({
    required this.id, required this.title, required this.description,
    required this.imageUrl, required this.category, required this.author,
    required this.time, this.isBreaking = false, this.isTrending = false,
    this.isBookmarked = false,
  });
}

// --- STATE MANAGEMENT ---
class NewsProvider extends ChangeNotifier {
  String _selectedCategory = "All";

  final List<Article> _allArticles = [
    Article(
      id: "1", title: "Global Summit: Historic Accord Signed to Protect High Seas",
      author: "United Press", time: "15m ago",
      description: "After a decade of negotiations, nearly 200 countries have agreed on a legal framework to protect biodiversity in international waters.",
      imageUrl: "https://images.unsplash.com/photo-1439405326854-014607f694d7?w=800",
      category: "World", isBreaking: true,
    ),
    Article(
      id: "2", title: "Tech Stocks Rally as AI Integration Hits Retail Sector",
      author: "Market Watch", time: "1h ago",
      description: "Wall Street gains momentum as major retailers report massive efficiency spikes due to automated supply chains.",
      imageUrl: "https://images.unsplash.com/photo-1611974714851-48206139d733?w=800",
      category: "Business", isTrending: true,
    ),
    Article(
      id: "3", title: "Mars Sample Return Mission Faces Budget Hurdles",
      author: "Science Desk", time: "2h ago",
      description: "NASA officials debate the future of the multi-billion dollar mission as costs exceed initial projections.",
      imageUrl: "https://images.unsplash.com/photo-1614728894747-a83421e2b9c9?w=800",
      category: "Science", isTrending: true,
    ),
    Article(
      id: "4", title: "Wimbledon: New Champion Crowned in Five-Set Thriller",
      author: "Sports Daily", time: "4h ago",
      description: "A grueling match ended in an upset victory for the 20-year-old prodigy from Spain.",
      imageUrl: "https://images.unsplash.com/photo-1595435064214-07d67894448c?w=800",
      category: "Sports",
    ),
    Article(
      id: "5", title: "Art Meets Tech: The Rise of Digital Sculpting",
      author: "Art Review", time: "6h ago",
      description: "Traditional galleries are opening their doors to haptic-based virtual installations.",
      imageUrl: "https://images.unsplash.com/photo-1547826039-bfc35e0f1ea8?w=800",
      category: "Culture",
    ),
  ];

  String get selectedCategory => _selectedCategory;
  List<Article> get breakingNews => _allArticles.where((a) => a.isBreaking).toList();
  List<Article> get trendingNews => _allArticles.where((a) => a.isTrending).toList();
  List<Article> get filteredNews {
    if (_selectedCategory == "All") return _allArticles.where((a) => !a.isBreaking).toList();
    return _allArticles.where((a) => a.category == _selectedCategory).toList();
  }
  List<Article> get bookmarks => _allArticles.where((a) => a.isBookmarked).toList();

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleBookmark(Article article) {
    article.isBookmarked = !article.isBookmarked;
    notifyListeners();
  }
}

// --- MAIN UI DASHBOARD ---
class NewsDashboard extends StatelessWidget {
  const NewsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewsProvider>(context);
    final List<String> cats = ["All", "World", "Business", "Science", "Sports", "Culture"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text("THE PULSE DAILY",
            style: GoogleFonts.unifrakturMaguntia(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.bookmark_outline, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksPage())),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. Newspaper Date Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(border: Border(top: BorderSide(), bottom: BorderSide(width: 0.5))),
              child: Center(
                child: Text("WEDNESDAY, APRIL 15, 2026  |  SINCE 1924  |  PRICE: FREE",
                    style: GoogleFonts.libreFranklin(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
            ),
          ),

          // 2. Breaking News Hero
          SliverToBoxAdapter(child: _HeroArticle(article: provider.breakingNews[0])),

          // 3. Trending Carousel
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(title: "TRENDING NOW"),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    itemCount: provider.trendingNews.length,
                    itemBuilder: (context, index) => _TrendingTile(article: provider.trendingNews[index]),
                  ),
                ),
              ],
            ),
          ),

          // 4. Category Navbar
          SliverPersistentHeader(
            pinned: true,
            delegate: _CategoryDelegate(
              child: Container(
                color: Colors.white,
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    bool isSelected = provider.selectedCategory == cats[index];
                    return GestureDetector(
                      onTap: () => provider.setCategory(cats[index]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 30),
                        alignment: Alignment.center,
                        child: Text(cats[index].toUpperCase(),
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.red : Colors.grey.shade400,
                                decoration: isSelected ? TextDecoration.underline : null)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 5. Main Article Feed
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _StandardTile(article: provider.filteredNews[index]),
                childCount: provider.filteredNews.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM WIDGETS ---

class _HeroArticle extends StatelessWidget {
  final Article article;
  const _HeroArticle({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetail(article: article))),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Image.network(article.imageUrl, width: double.infinity, height: 260, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text("BREAKING", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 10),
                Text(article.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.libreBaskerville(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 10),
                Text(article.description, textAlign: TextAlign.center, maxLines: 3, style: const TextStyle(color: Colors.grey, height: 1.5)),
              ],
            ),
          ),
          const Divider(thickness: 1, indent: 20, endIndent: 20),
        ],
      ),
    );
  }
}

class _TrendingTile extends StatelessWidget {
  final Article article;
  const _TrendingTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetail(article: article))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(article.imageUrl, height: 100, width: 160, fit: BoxFit.cover)),
            const SizedBox(height: 10),
            Text(article.title, maxLines: 3, style: GoogleFonts.libreBaskerville(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _StandardTile extends StatelessWidget {
  final Article article;
  const _StandardTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewsDetail(article: article))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.category.toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 10)),
                  const SizedBox(height: 5),
                  Text(article.title, style: GoogleFonts.libreBaskerville(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("${article.time} • ${article.author}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(flex: 1, child: ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(article.imageUrl, height: 80, fit: BoxFit.cover))),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const Expanded(child: Divider(indent: 15)),
        ],
      ),
    );
  }
}

// --- NAVIGATION PAGES ---

class NewsDetail extends StatelessWidget {
  final Article article;
  const NewsDetail({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(article.imageUrl),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.category.toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(article.title, style: GoogleFonts.libreBaskerville(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16),
                      const SizedBox(width: 5),
                      Text("${article.author} • ${article.time}", style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(article.isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                        onPressed: () => provider.toggleBookmark(article),
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  Text(article.description, style: const TextStyle(fontSize: 17, height: 1.8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarks = Provider.of<NewsProvider>(context).bookmarks;
    return Scaffold(
      appBar: AppBar(title: const Text("BOOKMARKED")),
      body: bookmarks.isEmpty
          ? const Center(child: Text("No saved articles."))
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) => _StandardTile(article: bookmarks[index]),
      ),
    );
  }
}

class _CategoryDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _CategoryDelegate({required this.child});
  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}













//name: pulse_daily_news
// description: "A professional editorial news application."
// publish_to: 'none'
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.0
//
// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^1.2.0
//   provider: ^6.1.1
//   google_fonts: ^6.2.1
//
// flutter:
//   uses-material-design: true
