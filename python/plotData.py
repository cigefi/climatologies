# -*- coding: utf-8 -*-
"""
Created on Wed Mar 02 16:54:41 2016

@author: Roberto Villegas-Diaz
@email: roberto.villegas@ucr.ac.cr
"""
import os
import numpy as np
from mpl_toolkits.basemap import Basemap
import matplotlib.pyplot as plt

#from pylab import *
import sys
#from functions import listFiles
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
            if d.split('.')[1] =='dat':
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
        m = Basemap(projection='robin',resolution='c',lat_0=-90,lon_0=0)
        m.drawcountries(linewidth=0.4) # draw countries
        m.drawcoastlines(linewidth=0.4) # draw coastlines 
        #np.loadtxt(open('/home/bthillo/Downloads/test/Historical/python/data.dat','rb'),delimiter=',')
        # draw line around map projection limb.
        # color background of map projection region.
        # missing values over land will show up this color.
        m.drawmapboundary(fill_color='0.3')
        parallels = np.arange(-90.,90,30.)
        # labels = [left,right,top,bottom]
        m.drawparallels(parallels)
        meridians = np.arange(0.,360.,30.)
        m.drawmeridians(meridians)
        #data2D, lon, lat = m.transform_scalar(data2D, lon, lat, 180, 90, returnxy=True)
        newMap = m.contourf(lon,lat,data2D,cmap=plt.cm.jet,latlon=True)
        #newMap = m.interp(data2D,lon,lat)
        #newMap = m.imshow(data2D, cmap=plt.cm.jet, aspect='equal', interpolation='gaussian')      
        #newMap = m.pcolormesh(lon,lat,data2D,edgecolors='none',cmap=plt.cm.jet,latlon=True)
        # add colorbar
        cb = m.colorbar(newMap,"bottom", size="5%", pad="3%")
        cb.ax.set_xlabel(label)
        DPI = 1000
        plt.savefig(path+name+'-contourf-'+str(DPI)+'.png', format='png', dpi=DPI)
        plt.close(fig)
        print 'Map saved'
    except:
        print str(sys.exc_info()[1])
        print 'Map not saved'
        
if len(sys.argv) < 1:
    # Mensaje de error si se recibe más o menos de 1 parámetro
    print 'ERROR, dirName is a required input'
else:
    if len(sys.argv) == 3:
        pType = sys.argv[2]
    else:
        pType = 'tas'
    #path = sys.argv[1]
    path = 'd:/cigefi/climatologies/test20/'
    path = path.replace('\\','/')
    
    if not path.endswith('/'):
        path += '/'

    out = np.array([])
    files = listFiles(path)
    
    for f in sorted(files):
        print 'Plotting: %s' %f
        data2D = np.genfromtxt(files[f],delimiter=',')
        if pType == 'tas':
            plotData(data2D,'Temperature (°C/day)',path,f)
        else:
            plotData(data2D,'Precipitation (mm/day)',path,f)