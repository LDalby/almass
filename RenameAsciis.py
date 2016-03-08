import traceback, sys, time, shutil, os, csv

# Names of the new landscapes
NJ = ['NJ1', 'NJ2', 'NJ3', 'NJ4', 'NJ5', 'NJ6']
VJ = ['VJ1', 'VJ2', 'VJ3', 'VJ4', 'VJ5']
OJ = ['OJ1', 'OJ2', 'OJ3', 'OJ4']
FU = ['FU1', 'FU2', 'FU3', 'FU4']
NS = ['NS1', 'NS2', 'NS3', 'NS4']
SS = ['SS1', 'SS2', 'SS3', 'SS4', 'SS5', 'SS6']

landscapes = NJ + VJ + OJ + FU + NS + SS
landscapes.append("BO1")  # Different approach is need to apapend only 1 string

# Path to the destination
dst = "e:/Gis/HareValidation/"

# rename ascii (doohh...)
for index in range(len(landscapes)):
  dstpath = os.path.join(dst, landscapes[index])
  strname = landscapes[index]
  asciipath = os.path.join(dstpath, 'ascii_' + strname.lower() + ".txt")
  newasciipath = os.path.join(dstpath, "ASCII_INPUT.txt")
  os.rename(asciipath, newasciipath)    