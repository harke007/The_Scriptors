# -*- coding: utf-8 -*-
"""
Created on Tue Jan 25 14:20:58 2017

@author: ubuntu
"""

# Import libraries
import os
import tarfile
import urllib
import re
import subprocess
import numpy as np
from osgeo import gdal
from osgeo.gdalconst import GA_ReadOnly, GDT_Float32


# Make and use data folder linux
path = r'./data'
if not os.path.exists(path):
    os.makedirs(path)
os.chdir('./data')

# Download data
url = 'https://www.dropbox.com/s/zb7nrla6fqi1mq4/LC81980242014260-SC20150123044700.tar.gz?dl=1'
fname = "data.tar.gz"
urllib.urlretrieve (url, fname)

# untar
tar = tarfile.open(fname, "r:gz")
tar.extractall()
tar.close()

# remove all files but tif's of band 4 and 5
for f in os.listdir("."):
    if not re.match(".*band4.tif", f) and not re.match(".*band5.tif", f):
        os.remove(f)

def CalcNDWI(FilenameBand4, FilenameBand5, filename):
    band4gdal = gdal.Open(FilenameBand4)
    band5gdal = gdal.Open(FilenameBand5)
    
    # Read raster data
    band4arr = band4gdal.ReadAsArray(0, 0, band4gdal.RasterXSize, band4gdal.RasterYSize)
    band5arr = band5gdal.ReadAsArray(0, 0, band5gdal.RasterXSize, band5gdal.RasterYSize)
    # Set data type
    band4arr=band4arr.astype(np.float32)
    band5arr=band5arr.astype(np.float32)

    # Derive the NDWI
    ## Create mask array
    mask = np.greater(band4arr+band5arr,0)
    # set np.errstate to avoid warning of invalid values (i.e. NaN values) in the divide 
    with np.errstate(invalid='ignore'):
        NDWI = np.choose(mask,(-99,(band4arr-band5arr)/(band4arr+band5arr)))
    
    # Add .tif extension to filename
    filename += ".tif"
    # Write the result to disk
    driver = gdal.GetDriverByName('GTiff')
    outDataSet = driver.Create(filename, band4gdal.RasterXSize, band4gdal.RasterYSize, 1, GDT_Float32)
    outBand = outDataSet.GetRasterBand(1)
    outBand.WriteArray(NDWI,0,0)
    outBand.SetNoDataValue(-99)
    outDataSet.SetProjection(band4gdal.GetProjection())
    outDataSet.SetGeoTransform(band4gdal.GetGeoTransform())
    outBand.FlushCache()
    outDataSet.FlushCache()

def ReprojectResult(InputFile, OutputFile, EPSGNo):
    InputFile += ".tif"
    OutputFile += ".tif"
    EPSG="EPSG:"+EPSGNo
    # Reproject result
    subprocess.call(["gdalwarp", "-t_srs", EPSG, InputFile, OutputFile])

CalcNDWI ("LC81980242014260LGN00_sr_band4.tif", "LC81980242014260LGN00_sr_band5.tif", "NDWI")
ReprojectResult("NDWI","NDWI_ll","4326")
