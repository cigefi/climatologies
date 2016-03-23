# -*- coding: utf-8 -*-
"""
Created on Wed Mar 16 12:12:13 2016

@author: Roberto Villegas-Díaz
@email: roberto.villegas@ucr.ac.cr
"""

import smtplib

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

def email(you,message,subject='[WARNING]'):
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
                    body {
                        background-color: #CCC;
                        padding: 10px;
                        font-family: 'Times New Roman', Georgia, Serif;
                    }
                    
                    h1 {
                        color: maroon;
                        margin-left: 40px;
                    } 
                    </style>              
            </head>
            <body>
                <div style='background: #005da4'>
                    <img src='images/logo-cigefi-ucr-v1-med.png' />
                </div>
                <p>"""
    html += message
    html += """
                </p>
            </body>
        </html>"""
    
    part1 = MIMEText(html, 'html')
    msg.attach(part1)
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