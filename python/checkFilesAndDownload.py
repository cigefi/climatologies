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
import urllib

def cargar(ruta):
    f = open(ruta)
    return json.load(f)

def cargarURL(ruta):
    f = url(ruta)
    return json.load(f)

def downloadFile(savePath,refData):
    try:
        print 'Downloading %s file' % (refData['url'])
        nFile= urllib.URLopener()
        nFile.retrieve(refData['url'],savePath)
        print 'File successfully downloaded'
    except:
        print '[ERROR] Cannot download the file'
        fid = open('log-'+experimentID+'.txt','a+')
        fid.write('[ERROR] '+ncfile+' not downloaded\n')
        fid.close()
        
def reordenarDict(fList,experimentID):
    nDict = {}
    for f in fList.keys():
        if fList[f]['experiment_id'] == experimentID:
            try:
                experimentName = f.split('/')[-1].split('_day_')[-1].split('.nc')[0][0:-5]
            except:
                experimentName = ''
            tmp = fList[f]
            tmp['experiment_name'] = experimentName
            tmp['url'] = f
            nDict[experimentName+'/'+fList[f]['variable']+'_day/'+fList[f]['year']+'.nc'] = tmp
        #fList[f] = tmp
    #return fList
    return nDict

if len(sys.argv) < 2:
    # Fix path's
    dirName = os.getcwd().replace('\\','/')
    experimentID = 'historical'
    fullDataList = 'https://nex.nasa.gov/nex/static/media/dataset/nex-gddp-s3-files.json'    
elif len(sys.argv) < 3:
    # Fix path's
    dirName = sys.argv[1].replace('\\','/')
    experimentID = 'historical'
    fullDataList = 'https://nex.nasa.gov/nex/static/media/dataset/nex-gddp-s3-files.json'
elif len(sys.argv) < 4:
    # Fix path's
    dirName = sys.argv[1].replace('\\','/')
    experimentID = sys.argv[2]
    fullDataList = 'https://nex.nasa.gov/nex/static/media/dataset/nex-gddp-s3-files.json'
elif len(sys.argv) < 5:
    # Fix path's
    dirName = sys.argv[1].replace('\\','/')
    experimentID = sys.argv[2]
    fullDataList = sys.argv[3]
    
if not dirName.endswith('/'):
    dirName += '/'
    
if len(sys.argv) < 4:
    fileList = reordenarDict(cargarURL(fullDataList),experimentID)
else:
    fileList = reordenarDict(cargar(fullDataList),experimentID)
cont = 0
for f in fileList.keys():
    ncfile = dirName+f
    if os.path.exists(ncfile):
        md5O = fileList[f]['md5']
        md5F = hashlib.md5(open(ncfile,'rb').read()).hexdigest()
        if md5O != md5F:
            fid = open('corruptedFiles-'+experimentID+'.txt', 'a+')
            fid.write(fileList[f]['url']+'\n')
            fid.close()
            print '[% s] %s' %('CORRUPTED',ncfile)
            try:
                os.remove(ncfile) # Remove the previous file
                downloadFile(f,fileList[f]) # Download the file again
                fid = open('log-'+experimentID+'.txt','a+')
                fid.write('[DOWNLOADED] '+ncfile+'\n')
                fid.close()
            except:
                print 'Previous file was not removed'
                fid = open('log-'+experimentID+'.txt','a+')
                fid.write('[ERROR] '+ncfile+' not removed\n')
                fid.close()
    if cont%100 == 0:
        print '%d checked files of %d' %(cont,len(fileList.keys()))
    cont += 1