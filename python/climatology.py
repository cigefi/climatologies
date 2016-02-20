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
    params = packParams(sys.argv[1:],'');
    params[0] = sys.argv[1]
    generate(params)