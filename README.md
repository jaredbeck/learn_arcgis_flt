# The National Map (TNM)

> [The National Map](https://nationalmap.gov/) is a collaborative effort among
> the USGS and other Federal, State, and local partners to improve and deliver
> topographic information for the Nation.

## Install

Prerequisites: ruby, bundler

```
git clone git@github.com:jaredbeck/learn_arcgis_flt.git
bundle
bin/test
```

## Data

- NED - National Elevation Dataset
- NHD - [National Hydrography Dataset](https://nhd.usgs.gov/data.html)

## png.rb

Read NED .flt and NHD .shp, write PNG

```
bin/png.rb \
  data/ned/ned_1_n43w077/usgs_ned_1_n43w077_gridfloat.flt  \
  data/nhd/ny/WBDHU8.shp \
  out.png
open out.png
```

## References

- [The National Map (TNM)
  Download](https://viewer.nationalmap.gov/basic)
- [ArcGIS Float-to-Raster
  function](http://desktop.arcgis.com/en/arcmap/10.3/tools/conversion-toolbox/float-to-raster.htm)

### File Formats

- [ArcGIS Supported Raster File
  Formats](http://pro.arcgis.com/en/pro-app/help/data/imagery/supported-raster-dataset-file-formats.htm)
- [Library of Congress: ESRI GridFloat Output
  File](https://www.loc.gov/preservation/digital/formats/fdd/fdd000422.shtml)
- Shapefile
  - [Shapefile](https://en.wikipedia.org/wiki/Shapefile)
  - [ruby-shapefile](https://github.com/toastbrot/ruby-shapefile)
