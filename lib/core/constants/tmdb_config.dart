class TmdbConfig {
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Claves provistas por el usuario (para demo).
  // En producción, mover a un sistema seguro (env/keystore).
  static const String apiKey = '3505356064f5cb36cc2b3005e0ef473d';
  static const String readAccessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzNTA1MzU2MDY0ZjVjYjM2Y2MyYjMwMDVlMGVmNDczZCIsIm5iZiI6MTc2MjM4MjQwNS4zNjA5OTk4LCJzdWIiOiI2OTBiZDI0NTAyYzYyMWFhM2M2MTNjYjMiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.uFZYT3hSy5VPM1SQJXiLU86uMRnjhMRcYM9XQTZ1ilM';
}