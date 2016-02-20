# -*- coding: utf-8 -*-
import numpy as np
#from mpl_toolkits.basemap import Basemap
#import matplotlib.pyplot as plt
#import os
import sys
from functions import *
import netCDF4 as nc

if len(sys.argv) < 2:
    # Mensaje de error si se recibe más o menos de 1 parámetro
    print 'ERROR, dirName is a required input'
else:
    if len(sys.argv) < 3:    
        dirName = sys.argv[1]
        savePath = sys.argv[1]
        logPath = sys.argv[1]
        cType = 'daily'
        var2Read = ''
        yearZero = 0
        yearN = 0
    elif len(sys.argv) < 4:
        dirName = sys.argv[1]
        savePath = sys.argv[2]
        logPath = sys.argv[2]
        cType = 'daily'
        var2Read = ''
        yearZero = 0
        yearN = 0     
    elif len(sys.argv) < 5:
        dirName = sys.argv[1]
        savePath = sys.argv[2]
        logPath = sys.argv[3]
        cType = 'daily'
        var2Read = ''
        yearZero = 0
        yearN = 0 
    elif len(sys.argv) < 6:
        dirName = sys.argv[1]
        savePath = sys.argv[2]
        logPath = sys.argv[3]
        cType = sys.argv[4]
        var2Read = ''
        yearZero = 0
        yearN = 0 
    elif len(sys.argv) < 7:
        dirName = sys.argv[1]
        savePath = sys.argv[2]
        logPath = sys.argv[3]
        cType = sys.argv[4]
        var2Read = sys.argv[5]
        yearZero = 0
        yearN = 0
    elif len(sys.argv) < 8:
        dirName = sys.argv[1]
        savePath = sys.argv[2]
        logPath = sys.argv[3]
        cType = sys.argv[4]
        var2Read = sys.argv[5]
        yearZero = sys.argv[6]
        yearN = 0 
    else:
        dirName = sys.argv[1]
        savePath = sys.argv[2]
        logPath = sys.argv[3]
        cType = sys.argv[4]
        var2Read = sys.argv[5]
        yearZero = sys.argv[6]
        yearN = sys.argv[7]
    # Fix path's
    dirName = dirName.replace('\\','/')
    savePath = savePath.replace('\\','/')
    logPath = logPath.replace('\\','/')
    
    if not dirName.endswith('/'):
        dirName += '/'
    if not savePath.endswith('/'):
        savePath += '/'
    if not logPath.endswith('/'):
        logPath += '/'
    #dirName = 'D:/cigefi/BCSD_historical_r1i1p1_ACCESS1-0/pr_day/'
    #scale = 273.15
    #dataSet = nc.Dataset(dirName,'r')
    #out = np.mean(dataSet.variables['pr'][:],axis=0)*86400#-scale
    #logPath = dirName
    #savePath = dirName
    out = np.array([])
    files = listFiles(dirName)
    #print files
    #keys = files.keys().sort()
    #keys = keys.sort()
    try:
        os.remove(logPath+'log.txt')
    except:
        pass
    
    nYear = out = np.array([]);
    for f in sorted(files):#files.keys():
        if os.path.isdir(files[f]):
            params = [files[f]]
            generate(params)