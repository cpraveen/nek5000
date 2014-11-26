# make dssimp
FC = gfortran
OBJ = dndrv3.o

#
#
# Modify if ARPACK library was built somewhere else.
#include ../../../ARmake.inc
ALIBS = /opt/local/lib/libarpack.a
#
# simple drivers
#
all: eig
#
splib.o: splib.f
	$(FC) -c $<

%.o: %.f
	$(FC) -Wall -c $<

eig: $(OBJ)
	$(FC) $(OBJ) -larpack -L/opt/local/lib -lblas -llapack -o eig

clean:
	rm -f $(OBJ) eig
