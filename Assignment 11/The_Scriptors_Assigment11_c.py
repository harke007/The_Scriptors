import os
from osgeo import ogr,osr
import folium
import subprocess

# set wd for linux
#os.chdir('data')
os.getcwd()

#set wd for windows
os.chdir('.\data')

#iniatilise variables
go = True
kml=""
coords = []

# Create shapefile
fn = "points_TheScriptors.shp"
layername = "The_Scriptors"

## Choose driver
driverName = "ESRI Shapefile"
drv = ogr.GetDriverByName( driverName )
ds = drv.CreateDataSource(fn)

## Create spatial reference
spatialReference = osr.SpatialReference()
spatialReference.ImportFromProj4('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')

## Create Layer
layer=ds.CreateLayer(layername, spatialReference, ogr.wkbPoint)

## Test list or manual input
TestOrAuto = int(raw_input("0 for automatic list or 1 for manual input: "))
if TestOrAuto == 0:
    coords = [(51.987402, 5.666310), (51.981757, 5.667865)]
else:
    coords = []
    while go:
        lat = float(raw_input("Enter latitude or 0 to stop: "))
        if lat == 0:
            go = False
        else:
            lon = float(raw_input("Enter longitude: "))
        coords += [(lat, lon)]
print coords

for i in coords:
    lat, lon = i
    ## Create points
    point = ogr.Geometry(ogr.wkbPoint)

    ## Set points
    point.SetPoint(0,lon,lat)

    ## Create feature
    layerDefinition = layer.GetLayerDefn()
    feature = ogr.Feature(layerDefinition)
    feature.SetGeometry(point)
    layer.CreateFeature(feature)

    #Create kml
    kml += "<Placemark>"+point.ExportToKML()+"</Placemark>"

kml="<Document>"+kml+"</Document>"

file = open("test.kml","w")
file.write(kml)
file.close()

ds.Destroy()

## Create map
subprocess.call(["ogr2ogr", "-f", "GeoJSON", "-t_srs", "crs:84","points_TheScriptors.geojson", "points_TheScriptors.shp"])

pointsGeo=os.path.join("points_TheScriptors.geojson")
map_points = folium.Map(location=[52,5.7], zoom_start=10)
map_points.choropleth(geo_path=pointsGeo)
map_points.save('points_TheScriptors.html')

print "File succesfully saved in the data folder"

    
