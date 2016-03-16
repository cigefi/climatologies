# -*- coding: utf-8 -*-
"""
Created on Wed Mar 16 09:18:54 2016

@author: Roberto Villegas-Díaz
@email: roberto.villegas@ucr.ac.cr
"""

import json
import os
import sys
from urllib2 import urlopen as url
import hashlib

def cargar(ruta):
    f = open(ruta)
    return json.load(f)

def cargarURL(ruta):
    f = url(ruta)
    return json.load(f)
    
def reordenarDict(fList):
    nDict = {}
    for f in fList.keys():
        try:
            experimentName = f.split('/')[-1].split('_day_')[-1].split('.nc')[0][0:-5]
        except:
            experimentName = ''
        tmp = fList[f]
        tmp['experiment_name'] = experimentName
        tmp['url'] = f
        nDict['/'+experimentName+'/'+fList[f]['variable']+'_day/'+fList[f]['year']+'.nc'] = tmp
        #fList[f] = tmp
    #return fList
    return nDict

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

def getIndex(index):
    try:
        i = int(index.split('.')[0])
    except:
        i = index.split('.')[0]
    return i
    
def compareFiles(path,fileList):
    files = listFiles(dirName)
    for f in sorted(files): #files.keys()
        if(os.path.isdir(files[f])):
            compareFiles(files[f],fileList)

if len(sys.argv) < 2:
    # Fix path's
    dirName = os.getcwd().replace('\\','/')
    RUTA = 'https://nex.nasa.gov/nex/static/media/dataset/nex-gddp-s3-files.json'    
elif len(sys.argv) < 3:
    # Fix path's
    dirName = sys.argv[1].replace('\\','/')
    RUTA = 'https://nex.nasa.gov/nex/static/media/dataset/nex-gddp-s3-files.json'
elif len(sys.argv) < 4:
    # Fix path's
    dirName = sys.argv[1].replace('\\','/')
    RUTA = sys.argv[2]
    
if not dirName.endswith('/'):
    dirName += '/'
    
if len(sys.argv) < 3:
    fileList = reordenarDict(cargarURL(RUTA))
else:
    fileList = reordenarDict(cargar(RUTA))

for f in fileList.keys():
    ncfile = dirName+f
    print ncfile
    if os.path.exists(ncfile):
        md5O = fileList[f]['md5']
        md5F = hashlib.md5(open(ncfile,'rb').read()).hexadigest()
        if md5O != md5F:
            fid = open(dirName+'corruptedFiles.txt', 'a+')
            fid.write(fileList[f]['url']+'\n')
            fid.close()
    
#compareFiles(dirName,fileList)