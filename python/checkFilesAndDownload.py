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
from mailsender import alert#, email
import time#, threading
import requests

global ncfile, cont, ncurl, pcont, RECEIPT # global variable to be used in dlProgress
RECEIPT = 'roberto.villegas@ucr.ac.cr'#;rodrigo.castillorodriguez@ucr.ac.cr'
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
        #threadObj = threading.Thread(target=alert)
        #threadObj.start()
        print 'Downloading %s file' % (refData['url'])
        #urllib.urlretrieve(refData['url'],savePath)
        nFile= urllib.URLopener()
        nFile.retrieve(refData['url'],savePath,reporthook=dlProgress)
        print '\nFile successfully downloaded'
        return 1
    except:
        e = sys.exc_info()[0]
        print '[ERROR] Cannot download the file'
        fid = open('log-'+experimentID+'.txt','a+')
        fid.write('[ERROR] '+ncfile+' '+str(e)+'\n\n')
        fid.close()
        #email(RECEIPT,str(e),'[ERROR] '+experimentID)
        return 0
        
def downloadFile2(savePath,url):
    # NOTE the stream=True parameter
    blockSize = 1024
    try:
        h = requests.head(url)
        h = h.headers
        totalSize = int(h['Content-Length'])
        count = 1
        r = requests.get(url, stream=True)
        with open(savePath, 'wb') as f:
            for chunk in r.iter_content(chunk_size=blockSize):
                if chunk: # filter out keep-alive new chunks
                    f.write(chunk)
                percent = int(count*blockSize*100/totalSize)
                sys.stdout.write("\rDownloading ... %d%%" % percent)
                sys.stdout.flush()
                count += 1
        return 1
    except:
        e = sys.exc_info()[0]
        print '[ERROR] Cannot download the file'
        fid = open('log-'+experimentID+'.txt','a+')
        fid.write('[ERROR] '+ncfile+' '+str(e)+'\n\n')
        fid.close()
        #email(RECEIPT,str(e),'[ERROR] '+experimentID)
        return 0

def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()
    
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
    return nDict

def tcontrol():
    TIME = 2700 # Waits in the background for 45 minutes until send a warning
    t = 0
    while (pcont == cont) and t < TIME:
        time.sleep(1)
        t += 1
    t += 1
    if t > TIME:
        alert(ncfile,ncurl)
        
# Fix path's
dirName = os.getcwd().replace('\\','/')
experimentID = 'historical'
fullDataList = 'https://nex.nasa.gov/nex/static/media/dataset/nex-gddp-s3-files.json'    
if len(sys.argv) < 3:
    # Fix path's
    dirName = sys.argv[1].replace('\\','/')
elif len(sys.argv) < 4:
    # Fix path's
    dirName = sys.argv[1].replace('\\','/')
    experimentID = sys.argv[2]
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
#email('roberto.villegas@ucr.ac.cr',msg0,'[UPDATE] '+experimentID)
for f in fileList.keys():
    ncfile = dirName+f
    ncurl = fileList[f]['url']
    if os.path.exists(ncfile):
        pFiles += 1
        md5O = fileList[f]['md5']
        md5F = md5(ncfile)#hashlib.md5(open(ncfile,'rb').read()).hexdigest()
        pcont = cont
        #to = threading.Thread(target=tcontrol,name='tcontrol',args=(), kwargs={}) 
        #to.start() # Start control thread
        if md5O != md5F:
            fid = open('corruptedFiles-'+experimentID+'.txt', 'a+')
            fid.write(fileList[f]['url']+'\n')
            fid.close()
            print '[% s] %s' %('CORRUPTED',ncfile)
            try:
                os.remove(ncfile) # Remove the previous file
                if downloadFile2(ncfile,fileList[f]['url']): # Download the file again
                    md5F = md5(ncfile)
                    if md5O == md5F:
                        fid = open('log-'+experimentID+'.txt','a+')
                        fid.write('[DOWNLOADED] '+ncfile+'\n')
                        fid.close()
                        dFiles += 1
                    else:
                        eFiles += 1
                        eFList += '<li><a href=\''+fileList[f]['url']+'\'>'+ncfile+'</a></li>'
                        fid = open('log-'+experimentID+'.txt','a+')
                        fid.write('[ERROR] '+ncfile+' Cannot download the file\n')
                        fid.close()
                else:
                    eFiles += 1
                    eFList += '<li><a href=\''+fileList[f]['url']+'\'>'+ncfile+'</a></li>'
            except:
                eFiles += 1
                eFList += '<li>'+fileList[f]['url']+'</li>'
                e = sys.exc_info()[0]
                print str(e)
                fid = open('log-'+experimentID+'.txt','a+')
                fid.write('[ERROR] '+ncfile+' '+str(e)+'\n\n')
                fid.close()
                #email(RECEIPT,str(e),'[ERROR] '+experimentID)
    else: # In case the file doesn't exists
        try:
            if downloadFile2(ncfile,fileList[f]['url']): # Download the file again
                md5F = md5(ncfile)
                if md5O == md5F:
                    fid = open('log-'+experimentID+'.txt','a+')
                    fid.write('[DOWNLOADED] '+ncfile+'\n')
                    fid.close()
                    dFiles += 1
                else:
                    eFiles += 1
                    eFList += '<li><a href=\''+fileList[f]['url']+'\'>'+ncfile+'</a></li>'
                    fid = open('log-'+experimentID+'.txt','a+')
                    fid.write('[ERROR] '+ncfile+' Cannot download the file\n')
                    fid.close()
            else:
                eFiles += 1
                eFList += '<li><a href=\''+fileList[f]['url']+'\'>'+ncfile+'</a></li>'
            
        except:
            eFiles += 1
            eFList += '<li>'+fileList[f]['url']+'</li>'
            e = sys.exc_info()[0]
            print str(e)
            fid = open('log-'+experimentID+'.txt','a+')
            fid.write('[ERROR] '+ncfile+' '+str(e)+'\n\n')
            fid.close()
            #email(RECEIPT,str(e),'[ERROR] '+experimentID)
    if cont%100 == 0:
        print '%d checked files of %d' %(cont,len(fileList.keys()))
    cont += 1
eFList += '</ul>'
msg = 'The execution has been finished, stats: <br /><ul>'
msg += '<li>Total files: '+str(cont)+'</li>'
msg += '<li>Processed files: '+str(pFiles)+'</li>'
msg += '<li>Downloaded files: '+str(dFiles)+'</li>'
msg += '<li>Non-processed files: '+str(eFiles)+'<br />'+eFList+'</li></ul>'
#email(RECEIPT,msg,'[FINISHED] '+experimentID,'corruptedFiles-'+experimentID+'.txt')