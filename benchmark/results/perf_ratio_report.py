#!/usr/bin/env python3
"""Rank DartComparison benchmark cases by native/FxDart performance gap.

Reads results.json (headline "full" scale, the largest N per case), computes
a slower/faster ratio per case using the harness's own tie call
(timeWinner: "tie"/"native"/"fxdart", already thresholded by tieMarginPct /
tieAbsMs), and writes a markdown table ordered from the biggest gap down to
near-parity ties.

Usage: python3 perf_ratio_report.py [results.json] [-o out.md]
"""

import argparse
import json
from pathlib import Path

HEADLINE_SCALE = "full"


def fmt_us(value):
    if value >= 1000:
        return f"{value:,.0f}"
    return f"{value:.2f}"


def build_rows(data):
    rows = []
    for slug, case in data["cases"].items():
        scale = case["scales"].get(HEADLINE_SCALE)
        if scale is None:
            continue
        native_us = scale["native"]["medianUs"]
        fxdart_us = scale["fxdart"]["medianUs"]
        winner = scale["timeWinner"]
        ratio = max(native_us, fxdart_us) / min(native_us, fxdart_us)
        if winner == "tie":
            ratio_label = "~tie"
        elif winner == "fxdart":
            ratio_label = f"FxDart {ratio:.2f}x faster"
        else:
            ratio_label = f"Native {ratio:.2f}x faster"
        rows.append(
            {
                "slug": slug,
                "path": f"benchmark/cases/{slug}",
                "heading": case["heading"],
                "n": scale["n"],
                "native_us": native_us,
                "fxdart_us": fxdart_us,
                "ratio": ratio,
                "ratio_label": ratio_label,
            }
        )
    rows.sort(key=lambda r: r["ratio"], reverse=True)
    return rows


def render_markdown(data, rows):
    machine = data["machine"]
    lines = [
        "# DartComparison: slowest to fastest ratio",
        "",
        f"Machine: {machine['cpu']}, {machine['ramGb']}GB RAM, Dart {machine['dart']}, "
        f"{machine['os']} ({machine['compilation']})",
        f"Date: {data['date']} · Scale: `{HEADLINE_SCALE}` (headline N per case)",
        "",
        "| Case | Path | N | Native (µs) | FxDart (µs) | Ratio |",
        "|---|---|---:|---:|---:|---|",
    ]
    for row in rows:
        lines.append(
            f"| {row['heading']} | `{row['path']}` | {row['n']:,} | {fmt_us(row['native_us'])} | "
            f"{fmt_us(row['fxdart_us'])} | {row['ratio_label']} |"
        )
    lines.append("")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "results",
        nargs="?",
        default=str(Path(__file__).with_name("results.json")),
        help="path to results.json (default: results.json next to this script)",
    )
    parser.add_argument(
        "-o",
        "--out",
        default=None,
        help="output markdown path (default: perf_ratio_report.md next to this script)",
    )
    args = parser.parse_args()

    results_path = Path(args.results)
    out_path = Path(args.out) if args.out else Path(__file__).with_name("perf_ratio_report.md")

    data = json.loads(results_path.read_text())
    rows = build_rows(data)
    markdown = render_markdown(data, rows)
    out_path.write_text(markdown)
    print(f"wrote {len(rows)} cases to {out_path}")


if __name__ == "__main__":
    main()
