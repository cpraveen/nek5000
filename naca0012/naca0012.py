import sys
sys.path.append('../gmsh2nek')
from mshconvert import *

convert('naca0012.msh', \
        bcs={1:'W', 2:'v', 3:'O', 4:'O'},
        start_rea='start.rea', end_rea='end.rea')
