# Masterthesis: Der Einfluss des Glasfaserausbaus auf Miet- und Kaufpreise im deutschen Wohnimmobilienmarkt

Siehe [https://master.maulwurf.fun/](https://master.maulwurf.fun/) für eine gerenderte Version des Codes.

Dieses Repository enthält den Code und die Analysen für meine Masterarbeit. Ziel der Arbeit ist es, den Einfluss eines Glasfaseranschlusses auf den Wert einer Immobilie zu untersuchen. Dafür werden Daten zum Glasfaserausbau mit Immobilienmarktdaten von ImmoScout verknüpft und mit einer Difference-in-Differences Methode analysiert.

Die eigentlichen Daten und generierten Outputs (hauptsächlich Grafiken und Tabellen) werden aufgrund ihrer Größe nicht direkt über Git versioniert. Stattdessen verwende ich Symlinks zu einem OneDrive-Ordner, der diese Dateien speichert. Dadurch ist gewährleistet, dass die Daten und Ergebnisse immer verfügbar sind und automatisch gesichert werden. Die Symlinks sollten entsprechend an das eigene System angepasst werden, wenn das Projekt heruntergeladen wird.

Zum clonen verwende
```bash
git clone git@github.com:EinMaulwurf/masterthesis.git
```

## Ordnerstruktur:

- `data/`: *Symlink*. Enthält die Rohdaten und aufbereiteten Daten (nicht über Git versioniert).
  - `raw/`: Ursprüngliche, unbearbeitete Daten.
  - `processed/`: Aufbereitete und transformierte Daten.
- `literatur/`: *Symlink*. Enthält PDFs und Zusammenfassungen der verwendeten Literatur (nicht über Git versioniert).
- `output/`: *Symlink*. Enthält alle generierten Outputs, insbesondere Grafiken und Tabellen (nicht über Git versioniert).
- `scripts/`: Enthält alle Skripte für Datenaufbereitung, Analyse und Visualisierung.
- `src/`: Enthält zusätzliche R und C++ Quelldateien.
  - `R/`: R Hilfsfunktionen.
  - `cpp/`: C++ Funktionen (für Rcpp).
- `overleaf/`: Verweis auf separates Git-Repository für LaTeX.
- `renv/`: Enthält die `renv` Umgebung zur Projektverwaltung.

## Skripte:

- `cleaning_breitband.qmd`, `cleaning_immo.qmd`, `cleaning_sonstige.qmd`, `cleaning_zensus.qmd`:  Skripte zum Einlesen, Bereinigen und Aufbereiten der jeweiligen Rohdatensätze.
- `did.qmd`: Hauptskript für die Difference-in-Differences Analyse unter Verwendung des `did` Packages.
- `did_crosssection.qmd`: Führt eine Querschnittsanalyse mit einer Difference-in-Differences Schätzung durch.
- `exploration.qmd`: Explorative Datenanalyse und Visualisierungen.
- `scraping.qmd`: Skript zum Extrahieren von Daten aus dem Breitbandatlas und Speichern im `.parquet` Format.
- `simulations.qmd`: Erstellen und Auswerten verschiedener synthetischer Datensätze.

Da die Skripte teilweise auf dem Output anderer Skripte aufbauen, sollte die folgende Reihenfolge für einen ersten Durchlauf eingehalten werden:

1. `cleaning_zensus.qmd`
2. `scraping.qmd`
3. `cleaning_breitband.qmd`
4. `cleaning_sonstige.qmd`
5. `cleaning_immo.qmd`
6. `exploration.qmd`
7. `simulations.qmd`
8. `did.qmd`
9. `did_crosssection.qmd`

## Reproduzierbarkeit mit `renv`

Dieses Projekt verwendet `renv` zur Verwaltung der R-Dependencies, um eine gute Reproduzierbarkeit der Ergebnisse zu gewährleisten.

### Was ist `renv`?

`renv` ist ein Package für R, das eine isolierte Projektumgebung erstellt.  Es speichert die exakten Versionen der verwendeten Packages in einer `renv.lock` Datei.  Dadurch wird sichergestellt, dass alle Projektbeteiligten mit den gleichen Package-Versionen arbeiten, unabhängig von ihren globalen R-Einstellungen.

### Verwendung von `renv`:

1.  **Installation:** Stelle sicher, dass `renv` installiert ist: `install.packages("renv")`
2.  **Projekt wiederherstellen:** Nach dem Klonen des Repositorys, führe `renv::restore()` aus.  Dies installiert die in der `renv.lock` Datei spezifizierten Package-Versionen.
3.  **Umgebung aktivieren:** Führe `renv::activate()` aus, um die `renv`-Umgebung für das aktuelle Projekt zu aktivieren. Dies sollte automatisch passieren, wenn du das `Masterthesis.Rproj` öffnest.

Jegliche neu installierten Packages werden automatisch in dieser Projektumgebung gespeichert und beeinflussen nicht die globale R-Installation.

## Hauptsächlich verwendete R-Packages:

- `tidyverse`: Sammlung verschiedener Packages zum hantieren mit Daten.
- `sf`: Für raumbezogene Daten.
- `arrow`: Ermöglicht das effiziente Arbeiten mit großen Datensätzen und parquet-Dateien.
- `duckdb`: Ergänzend zu `arrow` zum Arbeiten mit großen Datensätzen.
- `did`: Implementiation der DiD-Methodik von Callaway & Sant'Anna (2021).

## Sonstige Hinweise:

Damit die Pfade korrekt funktionieren, muss das root-directory als working-directory gesetzt sein. Das passiert automatisch, wenn die `Masterthesis.Rproj` Datei geöffnet wird.
Außerdem muss in RStudio `Settings -> R Markdown -> Evaluate Chunks in Directory: Project` gesetzt sein. Nur so gilt auch das korrekte working-directory für interaktives Ausführen von Code in Chunks.