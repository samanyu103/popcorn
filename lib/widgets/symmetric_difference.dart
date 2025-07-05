import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/db.dart';
import 'posts.dart';

class CompareMoviesWidget extends StatefulWidget {
  final String currentUid;
  final String otherUid;

  const CompareMoviesWidget({
    super.key,
    required this.currentUid,
    required this.otherUid,
  });

  @override
  State<CompareMoviesWidget> createState() => _CompareMoviesWidgetState();
}

class _CompareMoviesWidgetState extends State<CompareMoviesWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Movie> commonMovies = [];
  List<Movie> currentOnlyMovies = [];
  List<Movie> otherOnlyMovies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final userAMovies = await DbService.getUserMovies(widget.currentUid);
    final userBMovies = await DbService.getUserMovies(widget.otherUid);

    final userAMap = {for (var movie in userAMovies) movie.tconst: movie};
    final userBMap = {for (var movie in userBMovies) movie.tconst: movie};

    final aSeen = userAMap.keys.toSet();
    final bSeen = userBMap.keys.toSet();

    final commonKeys = aSeen.intersection(bSeen);
    final onlyACount = aSeen.difference(bSeen);
    final onlyBCount = bSeen.difference(aSeen);

    setState(() {
      commonMovies = commonKeys.map((k) => userBMap[k]!).toList();
      currentOnlyMovies = onlyACount.map((k) => userAMap[k]!).toList();
      otherOnlyMovies = onlyBCount.map((k) => userBMap[k]!).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Both'),
            Tab(text: 'Yours not Theirs'),
            Tab(text: 'Theirs not Yours'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Common movies (otherUid to show their reviews)
              MovieGrid(
                movies: commonMovies,
                uid: widget.otherUid,
                viewOnly: true,
              ),

              // Tab 2: Movies seen by current user only (show current user's view)
              MovieGrid(
                movies: currentOnlyMovies,
                uid: widget.currentUid,
                viewOnly: true,
              ),

              // Tab 3: Movies seen by other user only (show other user's view)
              MovieGrid(
                movies: otherOnlyMovies,
                uid: widget.otherUid,
                viewOnly: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
