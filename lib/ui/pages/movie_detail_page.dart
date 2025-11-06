import 'package:flutter/material.dart';
import '../../core/constants/tmdb_config.dart';
import '../../data/models/movie_detail.dart';
import '../../data/repositories/movie_repository.dart';
import '../../data/services/tmdb_api_service.dart';
import '../theme/ui_theme.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late final MovieRepository _repo;
  late Future<MovieDetail> _future;

  @override
  void initState() {
    super.initState();
    _repo = MovieRepository(TmdbApiService());
    _future = _repo.getMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UiColors.pinkBackground,
      body: SafeArea(
        child: FutureBuilder<MovieDetail>(
          future: _future,
          builder: (context, snapshot) {
            final detail = snapshot.data;
            final backdropUrl = detail?.backdropPath != null
                ? '${TmdbConfig.imageBaseUrl}${detail!.backdropPath}'
                : null;
            return LayoutBuilder(
              builder: (context, constraints) {
                final headerHeight = (constraints.maxHeight * 0.42).clamp(260.0, 380.0);
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con imagen y tarjeta flotante
                      SizedBox(
                        height: headerHeight,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                                child: backdropUrl != null
                                    ? Image.network(backdropUrl, fit: BoxFit.cover)
                                    : Container(color: UiColors.pinkBackground),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(Icons.chevron_left, size: 28),
                                ),
                              ),
                            ),
                            // Degradado inferior para contraste con la tarjeta
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 160,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.white.withOpacity(0.95),
                                        Colors.white.withOpacity(0.6),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                      stops: const [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Tarjeta flotante inferior
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: _InfoCard(detail: detail),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Contenido que ocupa pantalla completa
                      _DetailBody(detail: detail),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final MovieDetail? detail;
  const _InfoCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final d = detail;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  d?.title ?? '',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: UiColors.imdbYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('IMDb',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: _buildStars(d?.voteAverage)),
          const SizedBox(height: 12),
          _InfoRow(detail: d),
        ],
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final MovieDetail? detail;
  const _DetailBody({required this.detail});
  @override
  Widget build(BuildContext context) {
    final d = detail;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plot Summary',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            d?.overview ?? '-',
            style: const TextStyle(color: UiColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (d?.genres ?? [])
                .map((g) => Chip(
                      label: Text(g),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Cast', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: (d?.cast.length ?? 0).clamp(0, 10),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = d!.cast[i];
                final url = c.profilePath != null
                    ? '${TmdbConfig.imageBaseUrl}${c.profilePath}'
                    : null;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: url != null ? NetworkImage(url) : null,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: Text(
                        c.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final MovieDetail? detail;
  const _InfoRow({required this.detail});
  @override
  Widget build(BuildContext context) {
    String year = '';
    if (detail?.releaseDate != null && detail!.releaseDate!.isNotEmpty) {
      year = detail!.releaseDate!.split('-').first;
    }
    final runtime = detail?.runtime != null
        ? '${detail!.runtime! ~/ 60}h ${detail!.runtime! % 60}min'
        : '-';
    final director = (detail?.director?.isNotEmpty ?? false)
        ? detail!.director!
        : '-';
    return Row(
      children: [
        Expanded(child: _MiniCard(title: 'Year', value: year.isEmpty ? '-' : year)),
        const SizedBox(width: 8),
        Expanded(child: _MiniCard(title: 'Type', value: (detail?.genres.isNotEmpty ?? false) ? detail!.genres.first : '-')),
        const SizedBox(width: 8),
        Expanded(child: _MiniCard(title: 'Hour', value: runtime)),
        const SizedBox(width: 8),
        Expanded(child: _MiniCard(title: 'Director', value: director)),
      ],
    );
  }
}

List<Widget> _buildStars(double? voteAverage) {
  final rating10 = voteAverage ?? 0.0; // TMDB es /10
  final rating5 = (rating10 / 10.0) * 5.0;
  final full = rating5.floor();
  final frac = rating5 - full;
  final half = frac >= 0.5 ? 1 : 0;
  final empty = 5 - full - half;
  final icons = <Widget>[];
  for (var i = 0; i < full; i++) {
    icons.add(const Icon(Icons.star, color: Colors.amber, size: 18));
  }
  if (half == 1) {
    icons.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
  }
  for (var i = 0; i < empty; i++) {
    icons.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
  }
  return icons;
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String value;
  const _MiniCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: UiColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: UiColors.textSecondary),
          ),
        ],
      ),
    );
  }
}