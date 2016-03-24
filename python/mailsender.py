# -*- coding: utf-8 -*-
"""
Created on Wed Mar 16 12:12:13 2016

@author: Roberto Villegas-Díaz
@email: roberto.villegas@ucr.ac.cr
"""

import smtplib

from os.path import basename
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def email(you,message,subject='[WARNING]',attachment=None):
    me = "cigefi.ucr.dev@gmail.com"
    # Create message container - the correct MIME type is multipart/alternative.
    msg = MIMEMultipart('alternative')
    msg['Subject'] = subject
    msg['From'] = me
    msg['To'] = you
    
    
    # Create the body of the message (a plain-text and an HTML version).
    html = """\
        <html>
            <head>
                <style>
                    div#header{
                        background-color: #005da4;
                        margin: 0;
        			}
        			div#header img{	
        				padding: 10px 20px;
        			}
        			
        			#content{
                         margin: 0;
        				background-color: #EEE;
        				padding: 10px;
                         font-size: 14pt;
        				font-family: 'Times New Roman', Georgia, Serif;
        			}
                    </style>                  
            </head>
            <body>
                <div id='header'>
                    <img alt='CIGEFI' src='http://sedeguanacaste.ucr.ac.cr/images/logo-cigefi-ucr-v1-med.png' />
                </div>
                <div id='content'>
                <p>"""
    html += message
    html += """
                </p>
                </div>
            </body>
        </html>"""
    
    part1 = MIMEText(html, 'html')    
    msg.attach(part1)
    if attachment != None:
        f = open(attachment, 'rb')
        msg.attach(MIMEApplication(
            f.read(),
            Content_Disposition='attachment; filename="%s"' % basename(attachment),
            Name=basename(attachment)
        ))
    try:
        s = smtplib.SMTP('smtp.gmail.com', 587)
        s.starttls()
        s.login("cigefi.ucr.dev@gmail.com", "wonanuk.cigefi")
        s.sendmail(me, you, msg.as_string())
        s.quit()
    except:
        pass
    
def alert(fpath,furl):
    msg = 'The execution is taking too much time. Check the Terminal.'
    msg += '<br /><br />The troubleshoot file is <a href=\''+furl+'\'>'+fpath+'</a>'
    email('villegas.roberto@hotmail.com',msg)
    #email('rodrigo.castillorodriguez@ucr.ac.cr',msg)