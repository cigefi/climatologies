# -*- coding: utf-8 -*-
import numpy as np
#from mpl_toolkits.basemap import Basemap
#import matplotlib.pyplot as plt
#import os
import sys
from functions import *
import netCDF4 as nc
months = [31,28,31,30,31,30,31,31,30,31,30,31]# Reference to the number of days per month
monthsName = ['January','February','March','April','May','June','July','August','September','October','November','December']

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
        
    for y in files.keys():
        #nYear = fu.readFileMonthly(files[y],'pr',y,logPath,months,monthsName)
        nYear = readFile(files[y],'pr',y,logPath)
        if out.size == 0:
            out = nYear
        elif nYear.size > 0:
            #np.savetxt(savePath+str(y)+'.csv',np.squeeze(out), delimiter=',')
            try:
                if out.ndim < 3:
                    out = np.concatenate((out[...,np.newaxis],nYear[...,np.newaxis]),axis=2)
                else:
                    out = np.concatenate((out[...],nYear[...,None]),axis=2)
            except:
                e = sys.exc_info()[1]
                fid = open(logPath+'log.txt', 'a+')
                fid.write('[ERROR] '+files[y]+' '+str(e)+'\n\n') #['+str('datetime.now()')+']
                fid.close()  
                print str(e)
    if out.size != 0:
        out = np.mean(out,axis=2)
        np.savetxt(savePath+'data.dat',out, delimiter=',')
        plotData(out,'Precipitation (mm/day)',savePath,'test')
    else:
        print 'No data read'