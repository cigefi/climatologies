# -*- coding: utf-8 -*-
import sys
from functions import generate, packParams

if len(sys.argv) < 2:
    # Mensaje de error si se recibe más o menos de 1 parámetro
    print 'ERROR, dirName is a required input'
else:
    params = packParams(sys.argv[1:],'');
    params[0] = sys.argv[1]
    generate(params)