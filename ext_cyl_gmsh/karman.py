import sys
sys.path.append('../gmsh2nek')
from mshconvert import *

radius = 0.05

cyl={'type':'C', 'radius':radius, 'depth':3, 'circle_center':(0,0)}

convert('karman.msh', \
        curves={2:cyl}, \
        bcs={1:'v', 2:'W', 3:'O', 4:'O', 5:'O'})
