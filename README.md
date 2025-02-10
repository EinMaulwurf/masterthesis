# Masterthesis: Der Einfluss des Glasfaserausbaus auf Miet- und Kaufpreise im deutschen Wohnimmobilienmarkt

Dieses Repository enthält den Code und die Analysen für meine Masterarbeit. Ziel der Arbeit ist es, den Einfluss eines Glasfaseranschlusses auf den Wert einer Immobilie zu untersuchen. Dafür werden Daten zum Glasfaserausbau mit Immobilienmarktdaten von ImmoScout verknüpft und mit einer modernen Difference-in-Differences Methode analysiert.

Die eigentlichen Daten und generierten Outputs (hauptsächlich Grafiken und Tabellen) werden aufgrund ihrer Größe nicht direkt über Git versioniert. Stattdessen verwende ich Symlinks zu einem OneDrive-Ordner, der diese Dateien speichert. Dadurch ist gewährleistet, dass die Daten und Ergebnisse immer verfügbar sind und automatisch gesichert werden. Die Symlinks sollten entsprechend an das eigene System angepasst werden, wenn das Projekt heruntergeladen wird.

## Ordnerstruktur:

- `Daten/`: Enthält die Rohdaten und aufbereiteten Daten. Wird nicht über git getrackt, da die Daten teilweise sehr groß und zudem vertraulich sind.
- `Literatur/`: Enthält PDFs und Zusammenfassungen der verwendeten Literatur. Wird nicht über git getrackt.
- `Output/`: Enthält alle generierten Outputs (insbesondere Grafiken). Wird nicht über git getrackt, da die Dateien teilweise groß sind.
- `Skripte/`: Enthält alle Code-Dokumente.
- `overleaf/`: Link zum overleaf-git-repo.

## Skripte:

- `scraping.qmd`: Dieses Skript verwendet das `rvest`-Package um die Daten aus dem Breitbandatlas zu extrahieren. Die Daten werden anschließend im `.parquet` Format gespeichert.
- `get_coords.cpp`: Dieses Rcpp Skript enthält eine Funktion (`split_coords`), um 250m Zellen in 100m Zellen aufzuteilen, um die Daten aus dem Breitbandatlas zu verwenden.
- `cleaning_*.qmd`: Diese Skripte sind für das Einlesen, Bereinigen und eventuelle Aggregieren der verschiedenen Rohdatensätze zuständig. Sie erstellen auch neue, spezifische Datensätze, z.B. den `Raster_1km_got_fiber_date.parquet`.
- `exploration_*.qmd`: Diese Dateien enthalten explorative Datenanalysen, Grafiken und zusammenfassende Statistiken.
- `did.qmd`: Dieses Skript enthält alle Analysen mit dem `did` Package und ist für die Durchführung der Hauptanalysen zuständig. Es werden auf die vorher bereinigten Daten zurückgegriffen.
- `honest_did_helper.R`: Dieses Skript führt eine Sensitivitätsanalyse mit den Ergebnissen des `did` Package durch. Die Analyse basiert auf der Methode von Rambachan and Roth (2021).

## Verwendete R-Packages:

- `tidyverse`
- `sf`
- `arrow`
- `duckdb`
- `did`

## Sonstige Hinweise:

Damit die Pfade korrekt funktionieren, muss das root-directory als working-directory gesetzt sein. Das passiert automatisch, wenn die `Masterthesis.Rproj` Datei geöffnet wird.
Außerdem muss in RStudio `Settings -> R Markdown -> Evaluate Chunks in Directory: Project` gesetzt sein. Nur so gilt auch das korrekte working-directory für interaktives Ausführen von Code in Chunks.
