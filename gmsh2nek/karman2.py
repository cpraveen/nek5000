from mshconvert import *

convert('karman2.msh', \
        bcs={1:'v', 2:'W', 3:'O', 4:'W', 5:'W'})
