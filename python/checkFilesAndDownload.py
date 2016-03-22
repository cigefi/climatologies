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
from mailsender import email, alert
import threading, time

global ncfile, cont, ncurl, pcont # global variable to be used in dlProgress
    
def cargar(ruta):
    f = open(ruta)
    return json.load(f)

def cargarURL(ruta):
    f = url(ruta)
    return json.load(f)

def dlProgress(count, blockSize, totalSize):
    percent = int(count*blockSize*100/totalSize)
    sys.stdout.write("\r" + ncfile + " ... %d%%" % percent)
    sys.stdout.flush()
  
def downloadFile(savePath,refData):
    try:
        threadObj = threading.Thread(target=alert)
        threadObj.start()
        print 'Downloading %s file' % (refData['url'])
        nFile= urllib.URLopener()
        nFile.retrieve(refData['url'],savePath,reporthook=dlProgress)
        print '\nFile successfully downloaded'
    except:
        e = sys.exc_info()[0]
        print '[ERROR] Cannot download the file'
        fid = open('log-'+experimentID+'.txt','a+')
        fid.write('[ERROR] '+ncfile+' '+str(e)+'\n\n')
        fid.close()
        email('villegas.roberto@hotmail.com',e,'[ERROR] '+experimentID)
        email('rodrigo.castillorodriguez@ucr.ac.cr',e,'[ERROR] '+experimentID)
        
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

def tcontrol():
    TIME = 2700 # Waits in the background for 45 minutes until send a warning
    #print 'Threat start'
    t = 0
    while (pcont == cont) and t < TIME:
        #print 'cont: %d - pcont %d - time: %d s'%(cont,pcont,t)
        time.sleep(1)
        t += 1
    t += 1
    if t > TIME:
        alert(ncfile,ncurl)
    #print 'Threat finished'
        
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
try:
    os.remove('log-'+experimentID+'.txt')
    os.remove('corruptedFiles-'+experimentID+'.txt')
except:
    pass
cont = 0
dFiles = 0
pFiles = 0
eFiles = 0
eFList = '<ul>'
msg0 = '<h1>Execution begins</h1>'
msg0 += '<br />Details:<br /><ul>'
msg0 += '<li>dirName: '+dirName+'</li>'
msg0 += '<li>experimentID: '+experimentID+'</li>'
msg0 += '</ul>'
email('villegas.roberto@hotmail.com',msg0,'[UPDATE] '+experimentID)
for f in fileList.keys():
    ncfile = dirName+f
    ncurl = fileList[f]['url']
    if os.path.exists(ncfile):
        pFiles += 1
        md5O = fileList[f]['md5']
        md5F = hashlib.md5(open(ncfile,'rb').read()).hexdigest()
        pcont = cont
        to = threading.Thread(target=tcontrol,name='tcontrol',args=(), kwargs={}) 
        to.start() # Start control thread
        if md5O != md5F:
            fid = open('corruptedFiles-'+experimentID+'.txt', 'a+')
            fid.write(fileList[f]['url']+'\n')
            fid.close()
            print '[% s] %s' %('CORRUPTED',ncfile)
            try:
                os.remove(ncfile) # Remove the previous file
                downloadFile(ncfile,fileList[f]) # Download the file again
                fid = open('log-'+experimentID+'.txt','a+')
                fid.write('[DOWNLOADED] '+ncfile+'\n')
                fid.close()
                dFiles += 1
            except:
                eFiles += 1
                eFList += '<li>'+fileList[f]['url']+'</li>'
                e = sys.exc_info()[0]
                print 'Previous file was not removed'
                fid = open('log-'+experimentID+'.txt','a+')
                fid.write('[ERROR] '+ncfile+' '+str(e)+'\n\n')
                fid.close()
                email('villegas.roberto@hotmail.com',e,'[ERROR] '+experimentID)
                email('rodrigo.castillorodriguez@ucr.ac.cr',e,'[ERROR] '+experimentID)
    if cont%100 == 0:
        print '%d checked files of %d' %(cont,len(fileList.keys()))
    
    #if cont%3000 == 0:
        #print 'Start ruin the world'
        #pcont = cont
        #to = threading.Thread(target=ttest05)
        #to.start()
        #time.sleep(4)
        #print 'World ruined'
    cont += 1
eFList = '</ul>'
msg = 'The execution has been finished, stats: <br /><ul>'
msg += '<li>Total files: '+str(cont)+'</li>'
msg += '<li>Processed files: '+str(pFiles)+'</li>'
msg += '<li>Downloaded files: '+str(dFiles)+'</li>'
msg += '<li>Non-processed files: '+str(eFiles)+'<br />'+eFList+'</li>'
email('villegas.roberto@hotmail.com',msg,'[FINISHED] '+experimentID)
email('rodrigo.castillorodriguez@ucr.ac.cr',msg,'[FINISHED] '+experimentID)