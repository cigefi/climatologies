# -*- coding: utf-8 -*-
"""
Created on Sun Feb 14 22:28:39 2016

@author: ville
"""
from calendar import isleap as isLeap
import os
import netCDF4 as nc
import numpy as np
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt

#from pylab import *
import sys
#from scipy import ndimage

months = [31,28,31,30,31,30,31,31,30,31,30,31]# Reference to the number of days per month
monthsName = ['January','February','March','April','May','June','July','August','September','October','November','December']

def generate(params,pType = 1):
    dirName,savePath,logPath,cType,var2Read,yearZero,yearN = unpackParams(params)
        
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

    out = np.array([])
    files = listFiles(dirName)
    
    #print files
    try:
        os.remove(logPath+'log.txt')
    except:
        pass
    
    nYear = out = np.array([]);
    for f in sorted(files): #files.keys()
        #print 'Processing folder %s %s' % (files[f],getExperiment(files[f]))
        if(os.path.isdir(files[f])):
            params = [files[f]]
            generate(params)
        else:
            if(cType.lower() == 'daily'): # Daily climatology
                #print 'File %s - %s - %s' % (files[f],getVar2Read(files[f]),cType)
                if(var2Read == 'pr'):
                    print 'File %s - %s - %s' % (files[f],var2Read,cType)
                    #nYear = readFile(files[f],'pr',f,logPath)
                elif(var2Read == 'tasmin'):
                    print 'File %s - %s - %s' % (files[f],var2Read,cType)
                    #nYear = readFileTemp(files[f],'pr',f,logPath)
                else:
                    continue
                if out.size == 0:
                    out = nYear
                elif nYear.size > 0:
                    try:
                        if out.ndim < 3:
                            out = np.concatenate((out[...,np.newaxis],nYear[...,np.newaxis]),axis=2)
                        else:
                            out = np.concatenate((out[...],nYear[...,None]),axis=2)
                    except:
                        e = sys.exc_info()[1]
                        fid = open(logPath+'log.txt', 'a+')
                        fid.write('[ERROR] '+files[f]+' '+str(e)+'\n\n') #['+str('datetime.now()')+']
                        fid.close()  
                        print str(e)
                    
            elif(cType.lower() == 'monthly'): # Monthly climatology
                if(var2Read == 'pr'):
                    nYear = readFileMonthly(files[f],var2Read,f,logPath)
                elif(var2Read == 'tasmin'):
                    print 'File %s - %s - %s' % (files[f],var2Read,cType)
                    #nYear = readFileTemp(files[f],'pr',f,logPath)
                else:
                    continue
                if out.size == 0:
                    out = nYear
                elif nYear.size > 0:
                    try:
                        out = (nYear+out)/2
                    except:
                        e = sys.exc_info()[1]
                        fid = open(logPath+'log.txt', 'a+')
                        fid.write('[ERROR] '+files[f]+' '+str(e)+'\n\n') #['+str('datetime.now()')+']
                        fid.close()  
                        print str(e)
                print 'File %s - %s - %s' % (files[f],var2Read,cType)
            else: # Seasonal climatology
                print 'File %s - %s - %s' % (files[f],var2Read,cType)
    if out.size != 0:
        if(cType.lower() == 'pr'):
            out = np.mean(out,axis=2)
            np.savetxt(savePath+'data.dat',out, delimiter=',')
            plotData(out,'Precipitation (mm/day)',savePath,'test')
        elif(cType.lower() == 'monthly'):
            for i in range(12):
                month = out[:,:,i]
                newName = getExperiment(files[0])+'-'+monthsName[i]
                np.savetxt(savePath+newName+'.dat',month, delimiter=',')
                plotData(month,'Precipitation (mm/day)',savePath,newName)
    else:
        print 'No data read'

def unpackParams(params):
    if len(params) < 2:    
        dirName = params[0]
        savePath = params[0]
        logPath = params[0]
        cType = 'daily'
        var2Read = getVar2Read(params[0])
        yearZero = 0
        yearN = 0
    elif len(params) < 3:
        dirName = params[0]
        savePath = params[1]
        logPath = params[1]
        cType = 'daily'
        var2Read = getVar2Read(params[0])
        yearZero = 0
        yearN = 0     
    elif len(params) < 4:
        dirName = params[0]
        savePath = params[1]
        logPath = params[2]
        cType = 'daily'
        var2Read = getVar2Read(params[0])
        yearZero = 0
        yearN = 0 
    elif len(params) < 5:
        dirName = params[0]
        savePath = params[1]
        logPath = params[2]
        cType = params[3]
        var2Read = getVar2Read(params[0])
        yearZero = 0
        yearN = 0 
    elif len(params) < 6:
        dirName = params[0]
        savePath = params[1]
        logPath = params[2]
        cType = params[3]
        var2Read = params[4]
        yearZero = 0
        yearN = 0
    elif len(params) < 7:
        dirName = params[0]
        savePath = params[1]
        logPath = params[2]
        cType = params[3]
        var2Read = params[4]
        yearZero = params[6]
        yearN = 0 
    else:
        dirName = params[0]
        savePath = params[1]
        logPath = params[2]
        cType = params[3]
        var2Read = params[4]
        yearZero = params[5]
        yearN = params[6]        
    return [dirName,savePath,logPath,cType,var2Read,yearZero,yearN]

def getVar2Read(filePath):
    try:
        tmp = filePath.split('_')[-2]
        return tmp.split('/')[-1]
    except:
        return ''
    
def getExperiment(filePath):
    try:
        path = filePath.split('/')
        return path[-3]
    except:
        return ''

def getIndex(index):
    try:
        i = int(index.split('.')[0])
    except:
        i = index.split('.')[0]
    return i
    
def listFiles(path):
    dirs = os.listdir(path) # List all the subfolders inside the root path
    fList = {}
    for d in dirs:
        i = getIndex(d)
        try:
            if d.split('.')[1] =='nc':
                if not path.endswith('/'):
                    fList[i] = listFiles(path+"/"+d) # Creates a dictionary with the list of files
                else:
                    fList[i] = listFiles(path+d)
        except:
            if not path.endswith('/'):
                fList[i] = path+"/"+d
            else:
                fList[i] = path+d    
    return fList
    
def readFile(fileName,var2Read,yearC,logPath):
    out = np.array([])
    try:
        scale = 84600
        dataSet = nc.Dataset(fileName,'r')
        out = np.mean(dataSet.variables[var2Read][:],axis=0)*scale
        print 'Data saved: %s' % str(yearC)
        fid = open(logPath+'log.txt', 'a+')
        fid.write('[SAVED] '+fileName+'\n')
        fid.close()
        dataSet.close()
    except:
        e = sys.exc_info()[1]
        fid = open(logPath+'log.txt', 'a+')
        fid.write('[ERROR] '+fileName+' '+str(e)+'\n\n')
        fid.close()
        #dataSet.close()
    return out

def readFileMonthly(fileName,var2Read,yearC,logPath):
    out = np.array([])
    try:
        scale = 84600
        dataSet = nc.Dataset(fileName,'r')
        data = dataSet.variables[var2Read][:]*scale
        lPos = -1
        days = int(data.shape[0])
        for m in range(len(months)):
            fPos = lPos + 1
            if(isLeap(int(yearC)) and m == 1 and days==366):
                lPos = months[m] + fPos + 1# Leap year
            else:
                lPos = months[m] + fPos
            newMonth = data[fPos:lPos,:,:]
            if m == 0:
                out = np.concatenate((out[...,np.newaxis],newMonth[...,np.newaxis]),axis=2)
                #out = np.dstack((np.mean(newMonth,axis=0)))
            else:
                out = np.concatenate((out[...],newMonth[...,np.newaxis]),axis=2)
                #out = np.dstack((out,np.mean(newMonth,axis=0)))
            print 'Data saved: %s - %s' % (monthsName[m],yearC)
        fid = open(logPath+'log.txt', 'a+')
        fid.write('[SAVED] '+fileName+'\n')
        fid.close()
        dataSet.close()
    except:
        e = sys.exc_info()[1]
        fid = open(logPath+'log.txt', 'a+')
        fid.write('[ERROR] '+fileName+' '+str(e)+'\n\n')
        fid.close()
    return out
        
def readFileTemp(fileName,var2Read,yearC,logPath):
    out = np.array([])
    scale = 273.15
    try:
        fileName2 = fileName.split('/'+'tasmin')
        fileName2 = fileName2[0]+'/tasmax'+fileName2[1]
        if os.path.exists(fileName2):
            dataSet = nc.Dataset(fileName,'r')            
            dataSet2 = nc.Dataset(fileName2,'r')            
            tasmin = dataSet.variables[var2Read][:]
            tasmax = dataSet2.variables['tasmax'][:]
            data = (tasmin+tasmax)/2
            out = np.mean(data-scale,axis=0)
            print 'Data saved: %s' % yearC
            fid = open(logPath+'log.txt', 'a+')
            fid.write('[SAVED] '+fileName+'\n')
            fid.close()
        else:
            fid = open(logPath+'log.txt', 'a+')
            fid.write('[ERROR] '+fileName+' does not exist\n\n')
            fid.close()
    except:
        e = sys.exc_info()[1]
        fid = open(logPath+'log.txt', 'a+')
        fid.write('[ERROR] '+fileName+' '+str(e)+'\n\n')
        fid.close()
    return out    
    
def sortDict(dictionary):
    values = []
    for k in dictionary.keys():
        values.append(int(k))
    return values
    
def plotData(data2D,label,path,name):
    print 'Generating map'
    # Extend the map to the longitude (360) and latitude (0) field
    data2D = np.column_stack((data2D, data2D[:,0]))
    
    # New map
    lon = np.linspace(0,360,num=data2D[0,:].size)
    lat = np.linspace(-90,90,num=data2D[:,0].size)
    lon, lat = np.meshgrid(lon,lat)

    try:
        plt.ioff() # Turn interactive plotting off
        plt.switch_backend('agg') # Changing backend
        fig = plt.figure()
        ax = fig.add_axes([0.05,0.05,0.9,0.9])
        # create Basemap instance.
        m = Basemap(projection='robin',resolution='h',lat_0=-90,lon_0=0)
        m.drawcountries(linewidth=0.4) # draw countries
        m.drawcoastlines(linewidth=0.4) # draw coastlines 
        #np.loadtxt(open('/home/bthillo/Downloads/test/Historical/python/data.dat','rb'),delimiter=',')
        # draw line around map projection limb.
        # color background of map projection region.
        # missing values over land will show up this color.
        #m.drawmapboundary(fill_color='0.3')

        #data2D, lon, lat = m.transform_scalar(data2D, lon, lat, 180, 90, returnxy=True)
        #newMap = m.contourf(lon,lat,data2D,cmap=plt.cm.jet,latlon=True)
        #newMap = m.interp(data2D,lon,lat)
        #newMap = m.imshow(data2D, cmap=plt.cm.jet, aspect='equal', interpolation='gaussian')      
        newMap = m.pcolormesh(lon,lat,data2D,edgecolors='none',cmap=plt.cm.jet,latlon=True)
        # add colorbar
        cb = m.colorbar(newMap,"bottom", size="5%", pad="3%")
        cb.ax.set_xlabel(label)
        plt.savefig(path+name+'.eps', format='eps', dpi=500)
        plt.close(fig)
        print 'Map saved'
    except:
        print str(sys.exc_info()[1])
        print 'Map not saved'