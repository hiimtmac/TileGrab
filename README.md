# TileGrab

This packaged will download map tiles to an sqlite file for a region specified by kml.

```shell
hiimtmac$ .build/debug/TileGrab
```
```shell
OVERVIEW: Tile Grab

USAGE: TileGrab <command> <options>

OPTIONS:
  --max            Max Zoom
  --min            Min Zoom
  --skipping, -s   Skips every second zoom level
  --help           Display available options

SUBCOMMANDS:
  fill             Continues downloading tiles that have no tile data
  kml              Get kml attributes into database
  new              Create new sqlite file from kml polygons & downloads
```

Given this kml with square regions:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Document>
	<Folder>
		<Placemark>
			<name>Untitled Polygon</name>
			<Polygon>
				<outerBoundaryIs>
					<LinearRing>
						<coordinates>
							-97.30820213107882,49.86876149052599,0 -97.30175254204751,49.87809028839774,0 -97.10480092301432,49.87648615587585,0 -97.10231632712512,49.98874992911571,0 -97.30523756390956,49.99041769941383,0 -97.30820213107882,49.86876149052599,0
						</coordinates>
					</LinearRing>
				</outerBoundaryIs>
			</Polygon>
		</Placemark>
		<Placemark>
			<name>Untitled Polygon</name>
			<Polygon>
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

This program will create regions and find all the tiles necessary for a given zoom range.

> Warning: Every zoom level will increase the amount of tiles & size by 4 as each tile has 4 child tiles for the next zoom level

## New

The `new` command will start a new database, figure out which tiles are needed based on the regions provided, and begin downloading.

```shell
hiimtmac$ .build/debug/TileGrab new --help
```
```shell
OVERVIEW: Create new sqlite file from kml polygons & downloads

OPTIONS:
  --database, -d   Path to database file output
  --regions, -r    Path to kml file with regions
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

TBD

Info about the map will go here. Stuff such as:
* Starting zoom level
* Starting bounding box
* ???

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
  --attributes, -a   Path to kml file with regions
  --database, -d     Path to database file output
```

### Todo

- [x] Points (sorta)
- [ ] Polylines
- [ ] Polygons

## IOS Usage

This was designed with the intent to download tiles into a single database file that has all tiles and placemark/polygons/etc required to render an offline map with satellite imagery.

## Example

```shell
hiimtmac$ .build/debug/TileGrab new
Path for regions file? (kml)
> /Users/hiimtmac/desktop/regions.kml
Path for database file? (sqlite)
> /Users/hiimtmac/desktop/test.sqlite
Min Zoom
> 12
Max Zoom
> 14
Inserting 3255 locations into database...
38 region(s) covering ~2912.0 square km - Min/Max Zoom: 12 / 14
Download will grab 3255 tiles @ estimated 47.0 MB to /Users/hiimtmac/desktop/test.sqlite. Continue?
y/n> y
Fetching 3255 tiles...
Success 2 of 3255: x=3945 y=5331 z=14
Success 3 of 3255: x=3927 y=5355 z=14
...
Success 3220 of 3255: x=3921 y=5347 z=14
Success 3246 of 3255: x=3966 y=5372 z=14
Download Complete
Vacuuming Database...
Vacuum Complete
Done, thanks for playing!

hiimtmac$ .build/debug/TileGrab kml
Path for attributes file? (kml)
> /Users/hiimtmac/Desktop/placemarks.kml
Path for database file? (sqlite)
> /Users/hiimtmac/Desktop/test.sqlite
Saving 3 points to database...
Vacuuming Database...
Vacuum Complete
Done, thanks for playing!
```
> Note: Download is async so they dont necessarily finish in order
