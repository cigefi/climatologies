# -*- coding: utf-8 -*-
import sys
import mpi4py.MPI as MPI
from functions import generate, packParams

if len(sys.argv) < 2:
    # Mensaje de error si se recibe más o menos de 1 parámetro
    print 'ERROR, dirName is a required input'
else:
    if not MPI.Is_initialized():
        MPI.Init()
    params = packParams(sys.argv[1:],'')
    params[0] = sys.argv[1]
    generate(params)