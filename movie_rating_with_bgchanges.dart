import 'package:flutter/material.dart';

void main() => runApp(MovieRatingApp());

class Movie {
  final String title;
  final String genre;
  final String imageUrl;
  double rating;

  Movie({
    required this.title,
    required this.genre,
    required this.imageUrl,
    this.rating = 0,
  });
}

class MovieRatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Rating App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {

  List<Movie> movies = [
    Movie(
      title: "Inception",
      genre: "Sci-Fi",
      imageUrl: "https://picsum.photos/id/1011/400/200",
    ),
    Movie(
      title: "Interstellar",
      genre: "Sci-Fi",
      imageUrl: "https://picsum.photos/id/1012/400/200",
    ),
    Movie(
      title: "The Dark Knight",
      genre: "Action",
      imageUrl: "https://picsum.photos/id/1013/400/200",
    ),
    Movie(
      title: "Avengers: Endgame",
      genre: "Action",
      imageUrl: "https://picsum.photos/id/1015/400/200",
    ),
  ];

  // ⭐ Update rating
  void updateRating(int index, double rating) {
    setState(() {
      movies[index].rating = rating;
    });
  }

  // 🎨 Background color logic
  Color getColor(double rating) {
    if (rating >= 4) return Colors.green;
    if (rating == 3) return Colors.orange;
    if (rating > 0 && rating < 3) return Colors.red;
    return Colors.white;
  }

  // ⭐ Star UI
  Widget buildStarRow(double rating, int index) {
    return Row(
      children: List.generate(5, (i) {
        return IconButton(
          icon: Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => updateRating(index, i + 1.0),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movie Rating App"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: getColor(movie.rating), // 🎯 dynamic color
              borderRadius: BorderRadius.circular(12),
            ),
            child: Card(
              color: Colors.transparent, // important
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 🎬 Movie Image
                  ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      movie.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Icon(Icons.broken_image, size: 60),
                        ),
                      ),
                    ),
                  ),

                  // 📄 Movie Details
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🎬 Title
                        Text(
                          movie.title,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),

                        // 🎭 Genre
                        Text(
                          movie.genre,
                          style: TextStyle(color: Colors.grey[700]),
                        ),

                        SizedBox(height: 10),

                        // ⭐ Stars
                        buildStarRow(movie.rating, index),

                        // 📊 Rating text
                        Text(
                          "Rating: ${movie.rating.toStringAsFixed(1)} / 5",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// no pubspec.yaml file is required for this exercise.
