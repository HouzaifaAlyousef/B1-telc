#!/usr/bin/env python3
"""Ein neues Projekt benutzt das Marketing-Modul.

**Dieses Skript importiert ausschliesslich ``marketing``.** Kein Code aus
einem Vorgaengerprojekt, keine Hilfsdatei von nebenan - das ist der Nachweis,
um den es hier geht (Abnahmepunkt Nr. 10).

Ausfuehren::

    python finde_gruppen.py            # Plan, Suche, Chancen, Export
    python finde_gruppen.py --plan     # nur zeigen, was ein Lauf kostet

Dasselbe geht mit der Kommandozeile - dieses Skript zeigt den Weg ueber die
Python-API, weil ein Projekt ihn braucht, sobald es die Ergebnisse
weiterverarbeitet.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import yaml

from marketing import MarketingBrief, MarketingModule

HIER = Path(__file__).resolve().parent


def lade_briefing(pfad: Path) -> MarketingBrief:
    """Das Briefing aus einer YAML-Datei.

    Als Datei und nicht im Code: Wer die Zielgruppe aendert, soll kein
    Python anfassen muessen.
    """
    return MarketingBrief.model_validate(
        yaml.safe_load(pfad.read_text(encoding="utf-8")) or {}
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--plan", action="store_true", help="Nur planen, nichts abfragen")
    parser.add_argument("--limit", type=int, default=None, help="Hoechstens so viele Anfragen")
    parser.add_argument("--top", type=int, default=20, help="So viele Chancen zeigen")
    args = parser.parse_args()

    marketing = MarketingModule.from_config(HIER / "config")
    brief = lade_briefing(HIER / "brief.yaml")

    # ---- 1. Was wuerde ein Lauf kosten? Ohne einen einzigen Zugriff. ----
    plan = marketing.plan(brief, limit=args.limit)
    print(f"Provider:            {plan.provider}")
    print(f"Anfragen geplant:    {plan.n_planned}")
    print(f"davon im Speicher:   {plan.n_cached}  (kostenlos)")
    print(f"wird abgeschickt:    {plan.n_to_send}")
    print(f"Hoechstverbrauch:    {plan.estimated_credits} Credits")
    print(f"Obergrenze:          {plan.limit_effective} ({plan.limit_source})")

    if args.plan:
        print("\nBeispielanfragen:")
        for request in plan.requests[:5]:
            print(f"  {request.text}")
        return 0

    # ---- 2. Ausfuehren ----
    print("\nSuche laeuft ...")
    bericht = marketing.discover(brief, limit=args.limit)
    print(f"  ausgefuehrt:       {bericht.queries_executed}")
    print(f"  Treffer:           {bericht.results_total}")
    print(f"  davon Quellen:     {bericht.sources_claimed}")
    print(f"  neu im Bestand:    {bericht.sources_new}")
    print(f"  Trefferquote:      {bericht.precision} %")
    print(f"  verbraucht:        {bericht.credits_used} Credits")

    for fehler in bericht.errors:
        print(f"  ! {fehler}", file=sys.stderr)

    # ---- 3. Die Chancen ansehen ----
    chancen = marketing.opportunities(brief, top=args.top)
    if not chancen:
        print("\nKeine Chancen. Fixtures oder Suchprovider pruefen.")
        return 1

    print(f"\n{len(chancen)} Chancen, beste zuerst:\n")
    for nummer, chance in enumerate(chancen, start=1):
        score = f"{chance.relevance_score:g}/{chance.score_max:g}" if chance.is_scored else "-"
        print(f"{nummer:2d}. [{chance.priority.value:>7}] {score:>10}  {chance.name or chance.url}")
        print(f"    {chance.rationale}")
        print(f"    {chance.url}\n")

    # ---- 4. Export ----
    ziel = marketing.export(chancen, HIER / "out" / "chancen.csv", "csv")
    print(f"Geschrieben: {ziel}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
