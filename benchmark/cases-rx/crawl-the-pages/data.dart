// Async case: crawl an unknown number of pages until an empty one. The
// example's 3 orders/page across 3 pages scales to 50 orders/page across
// n/50 pages — page count is derived from n, so every scale crawls its
// whole dataset plus the one empty page that stops it.
import '../../harness.dart';

/// Round n down so the orders divide evenly into full pages.
final n = caseN(10000) ~/ 50 * 50;

const pageSize = 50;

final totalPages = n ~/ pageSize;
