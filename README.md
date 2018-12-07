# TileGrab

This packaged will download map tiles to an sqlite file for a region specified by kml.

```shell
hiimtmac$ .build/debug/TileGrab
```
```shell
OVERVIEW: Tile Grab

USAGE: TileGrab <command> <options>

SUBCOMMANDS:
  fill                    Continues downloading tiles that have no tile data
  info                    Gathers info for map
  kml                     Get kml attributes into database
  new                     Create new sqlite file from kml polygons & downloads
```

Given this kml with square regions & paths:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<name>linregion.kml</name>
	<Folder>
		<name>My Places</name>
		<Placemark>
			<name>Untitled Path</name>
			<styleUrl>#m_ylw-pushpin0</styleUrl>
			<LineString>
				<tessellate>1</tessellate>
				<coordinates>
					-92.18532057009899,53.88963022981158,0 -92.30914992927097,53.94421596839025,0 -92.40428665630037,53.81766406180642,0 -92.29905355151683,53.78173114341524,0
				</coordinates>
			</LineString>
		</Placemark>
		<Placemark>
			<name>Untitled Path</name>
			<styleUrl>#m_ylw-pushpin0</styleUrl>
			<LineString>
				<tessellate>1</tessellate>
				<coordinates>
					-92.18144935958509,53.86818269779932,0 -91.94170365992156,53.76223239495038,0
				</coordinates>
			</LineString>
		</Placemark>
		<Placemark>
			<name>Untitled Polygon</name>
			<Polygon>
				<tessellate>1</tessellate>
				<outerBoundaryIs>
					<LinearRing>
                        <coordinates>
							-97.11916575339225,49.75906878471699,0 -96.88574125365628,49.75689484141393,0 -96.88201385193963,49.90532949199989,0 -97.117084672437,49.90696158224812,0 -97.11916575339225,49.75906878471699,0
						</coordinates>
					</LinearRing>
				</outerBoundaryIs>
			</Polygon>
		</Placemark>
	</Folder>
</Document>
</kml>
```

This program will create regions and paths with a distance buffer, then find all the tiles necessary for a given zoom range.

> Warning: Every zoom level will increase the amount of tiles & size by 4 as each tile has 4 child tiles for the next zoom level

## New

The `new` command will start a new database, figure out which tiles are needed based on the regions provided, and begin downloading.

```shell
hiimtmac$ .build/debug/TileGrab new --help
```
```shell
OVERVIEW: Create new sqlite file from kml polygons & downloads

OPTIONS:
  --kml-file, -k   Path to kml file.
```

## Fill

Sometimes tiles downloads will fail. If this happens, running the `fill` command will find all the tile rows with `NULL` data column and fetch that tile data.

```shell
hiimtmac$ .build/debug/TileGrab fill --help
```
```shell
OVERVIEW: Continues downloading tiles that have no tile data

OPTIONS:
  --database, -d   Path to database file output
```

## Info

```shell
hiimtmac$ .build/debug/TileGrab info --help
```
```shell
OVERVIEW: Gathers info for map

OPTIONS:
  --database, -d   Path to database file output
```

The `info` command will create an entry into the database with a top left coordinate, bottom right coordinate, min zoom & max zoom of the tiles contained in the db

## KML

The `kml` command will parse `Placemark`'s from kml files.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<Placemark>
		<name>P1</name>
		<Point>
			<coordinates>-97.179903,49.902755,0</coordinates>
		</Point>
	</Placemark>
	<Placemark>
		<name>P2</name>
		<Point>
			<coordinates>-97.182481,49.891090,0</coordinates>
		</Point>
	</Placemark>
	<Placemark>
		<name>P3</name>
		<Point>
			<coordinates>-97.17879149.876214,0</coordinates>
		</Point>
	</Placemark>
</Document>
</kml>
```

```shell
hiimtmac$ .build/debug/TileGrab kml --help
```
```shell
OVERVIEW: Get kml attributes into database

OPTIONS:
  --attribute-file, -a   Path to kml file with regions
  --pretty-print, -p     Ouput pretty printed
```

## IOS Usage

This was designed with the intent to download tiles into a single database file that has all tiles and placemark/polygons/etc required to render an offline map with satellite imagery.

## Example

```shell
hiimtmac$ .build/debug/TileGrab new -k ~/Desktop/linregion.kml
3 regions found.

Min zoom for regions?
> 10
Max zoom for regions?
> 11
Skip every second zoom level?
y/n> n
3 region(s) covering ~65098.0 square km - Min/Max Zoom: 10 / 11 - TILES: 700

Path buffer distance (m)?
> 200
9 paths found.

Min zoom for paths?
> 12
Max zoom for paths?
> 13
Skip every second zoom level?
y/n> n
9 path(s) - Min/Max Zoom: 12 / 13 - TILES: 1290

Download will grab ~1990 tiles @ estimated ~28.0 MB to /Users/hiimtmac/Desktop/linregion.sqlite. Continue?
y/n> y
Inserting 1990 locations into database...
Fetching 1990 tiles...
Success 27 of 1990: 2061/2656/13
Success 104 of 1990: 2015/2688/13
...
Success 1961 of 1990: 500/677/11
Success 1964 of 1990: 503/677/11
Download Complete
Vacuuming Database...
Vacuum Complete
Done, thanks for playing!

hiimtmac$ .build/debug/TileGrab fill -d ~/Desktop/linregion.sqlite
Download will grab no tiles to /Users/hiimtmac/Desktop/linregion.sqlite. Continue?
y/n> y
Fetching 0 tiles...
Download Complete
Vacuuming Database...
Vacuum Complete
Done, thanks for playing!

hiimtmac$ .build/debug/TileGrab info -d ~/Desktop/linregion.sqlite
Info Set
Vacuuming Database...
Vacuum Complete
Done, thanks for playing!

hiimtmac$ .build/debug/TileGrab kml -a ~/Desktop/group3full.kml -p
Replacing 143 style mappings...
Pretty printed output created successfully: TRUE
Done, thanks for playing!
```
> Note: Download is async so they dont necessarily finish in order
