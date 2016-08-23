# Name: Animal number mapper
# Purpose: Convert ASCII file of ALMaSS landscape to raster 
#		   and map some ALMaSS entity to it.
# Author: Lars Dalby
# Date: 31/5/2016

# Import system modules
import arcpy, traceback, sys, time, shutil, os
from arcpy import env
from arcpy.sa import *
arcpy.CheckOutExtension("Spatial")
arcpy.env.parallelProcessingFactor = "100%"  # You can always hope that one day it will actually work...

# Local variables:
PathToAscii = "c:\\MSV\\WorkDirectory"
AsciiFile = "AsciiLandscape.txt"
DstGDB = "O:\\ST_GooseProject\\ALMaSS\\GIS\\MapDump.gdb"
RasterName = "VejlElemType"
ReclRast = "BNNumbers"
MappingNumbers = "c:\\Users\\lada\\Desktop\\bnoct.txt"  # The reclassification table
colors = "C:\\Users\\lada\\Git\\almass\\StandardAlmassColors.clr"

# Process: ASCII to Raster
AsciiDst = os.path.join(PathToAscii, AsciiFile)
RasterDst = os.path.join(DstGDB, RasterName)
if arcpy.Exists(RasterDst):
        arcpy.Delete_management(RasterDst)
arcpy.ASCIIToRaster_conversion(AsciiDst, RasterDst, "INTEGER")
# Apply the standard ALMaSS colors
arcpy.AddColormap_management(RasterDst, "#", colors)

# Process: Reclass by ASCII File
# ReclDst = os.path.join(DstGDB, ReclRast)
# if arcpy.Exists(ReclDst):
#         arcpy.Delete_management(ReclDst)
# outraster = ReclassByASCIIFile(RasterDst, MappingNumbers, "NODATA")
# outraster.save(ReclDst)

