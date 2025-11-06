import 'package:flutter/material.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/services/tmdb_api_service.dart';
import '../../data/models/movie.dart';
import '../../core/constants/tmdb_config.dart';
import '../theme/ui_theme.dart';
import 'movie_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late final MovieRepository _repo;
  final ScrollController _scroll = ScrollController();
  List<Movie> _movies = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  DateTime? _selectedDate;
  String? _query;
  String _mode = 'popular'; // 'popular' | 'search' | 'date'

  @override
  void initState() {
    super.initState();
    _repo = MovieRepository(TmdbApiService());
    _loadInitial();
    _scroll.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _SearchBar(onSubmitted: (q){
                    final text = q.trim();
                    setState((){
                      _mode = text.isEmpty ? 'popular' : 'search';
                      _query = text.isEmpty ? null : text;
                      _selectedDate = null;
                    });
                    _resetAndLoad();
                  }),
                  const SizedBox(height: 18),
                  Text('Explore', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  const Text(
                    'Top Movies',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  _DateChips(
                    selected: _selectedDate,
                    onSelected: (date){
                      setState((){
                        _mode = 'date';
                        _selectedDate = date;
                        _query = null;
                      });
                      _resetAndLoad();
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        Expanded(child: _PosterBig(_movies.isNotEmpty ? _movies[0] : null, onTap: _openDetail)),
                        const SizedBox(width: 12),
                        Expanded(child: _PosterBig(_movies.length > 1 ? _movies[1] : null, onTap: _openDetail)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Más películas', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  // Grid de películas con máximo 10 filas y Trailers al final
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final cols = width >= 900 ? 4 : width >= 600 ? 3 : 2;
                      const int maxRows = 10;
                      final int displayCount = (_movies.length < maxRows * cols)
                          ? _movies.length
                          : maxRows * cols;
                      

                      Widget buildTile(int i) {
                        final m = _movies[i];
                        final url = m.posterPath != null
                            ? '${TmdbConfig.imageBaseUrl}${m.posterPath}'
                            : null;
                        return GestureDetector(
                          onTap: () => _openDetail(m),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: url != null
                                        ? Image.network(url, fit: BoxFit.cover, width: double.infinity)
                                        : Container(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      m.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Grid limitado antes de Trailers
                      final moviesGrid = GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          childAspectRatio: 0.66,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: displayCount,
                        itemBuilder: (context, i) => buildTile(i),
                      );

                      // Sección Trailers
                      final trailersSection = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text('Trailers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 100,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _movies.isNotEmpty ? (_movies.length.clamp(0, 10)) : 0,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, i) {
                                final m = _movies[i];
                                final url = m.posterPath != null
                                    ? '${TmdbConfig.imageBaseUrl}${m.posterPath}'
                                    : null;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 160,
                                    color: Colors.white,
                                    child: url != null
                                        ? Image.network(url, fit: BoxFit.cover)
                                        : Container(color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          moviesGrid,
                          trailersSection,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
              ),
            ),
      ),
    );
  }

  void _openDetail(Movie? movie) {
    if (movie == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailPage(movieId: movie.id)),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final void Function(String) onSubmitted;
  const _SearchBar({super.key, required this.onSubmitted});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.search, color: UiColors.textSecondary),
        ],
      ),
    );
  }
}

class _DateChips extends StatelessWidget {
  final DateTime? selected;
  final void Function(DateTime) onSelected;
  const _DateChips({super.key, this.selected, required this.onSelected});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final d = items[i];
          final sel = selected != null && _isSameDay(selected!, d);
          final dayLabel = _weekdayShort(d.weekday);
          return GestureDetector(
            onTap: () => onSelected(d),
            child: _Chip(day: dayLabel, date: d.day.toString(), selected: sel),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: items.length,
      ),
    );
  }
  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lun';
      case DateTime.tuesday:
        return 'Mar';
      case DateTime.wednesday:
        return 'Mié';
      case DateTime.thursday:
        return 'Jue';
      case DateTime.friday:
        return 'Vie';
      case DateTime.saturday:
        return 'Sáb';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '';
    }
  }
}

class _Chip extends StatelessWidget {
  final String day;
  final String date;
  final bool selected;
  const _Chip({super.key, required this.day, required this.date, this.selected = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: selected ? UiColors.accentRed : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(day, style: TextStyle(color: selected ? Colors.white70 : Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(color: selected ? Colors.white : Colors.grey.shade800, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PosterBig extends StatelessWidget {
  final Movie? movie;
  final void Function(Movie?) onTap;
  const _PosterBig(this.movie, {required this.onTap});
  @override
  Widget build(BuildContext context) {
    final url = movie?.posterPath != null
        ? '${TmdbConfig.imageBaseUrl}${movie!.posterPath}'
        : null;
    return GestureDetector(
      onTap: () => onTap(movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.white,
          child: url != null
              ? Image.network(url, fit: BoxFit.cover)
              : Container(color: Colors.white),
        ),
      ),
    );
  }
}

extension _ExploreStateHelpers on _ExplorePageState {
  Future<void> _loadInitial() async {
    _movies = [];
    _page = 1;
    _hasMore = true;
    await _fetchPage();
  }

  void _resetAndLoad() {
    _movies = [];
    _page = 1;
    _hasMore = true;
    _fetchPage();
  }

  void _onScroll() {
    if (!_hasMore || _loading) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _page++;
      _fetchPage();
    }
  }

  Future<void> _fetchPage() async {
    setState(() => _loading = true);
    try {
      List<Movie> pageItems = [];
      if (_mode == 'popular') {
        pageItems = await _repo.getPopularMovies(page: _page);
      } else if (_mode == 'search' && _query != null && _query!.isNotEmpty) {
        pageItems = await _repo.searchMovies(_query!, page: _page);
      } else if (_mode == 'date' && _selectedDate != null) {
        pageItems = await _repo.discoverMoviesByDate(_selectedDate!, page: _page);
      }
      setState(() {
        _movies.addAll(pageItems);
        _hasMore = pageItems.isNotEmpty;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar: $e')),
        );
      }
      setState(() => _hasMore = false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}