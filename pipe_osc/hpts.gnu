set term pdf
set out 'pipe_vz.pdf'
unset key
set xlabel 'Time'
set ylabel 'Vz'
set title 'Axial velocity'
p 'hpts.out' u 1:4 every 11::1 t 'r=0.4' w l lw 2, \
  'hpts.out' u 1:4 every 11::2 t 'r=0.3' w l lw 2, \
  'hpts.out' u 1:4 every 11::3 t 'r=0.2' w l lw 2, \
  'hpts.out' u 1:4 every 11::4 t 'r=0.1' w l lw 2, \
  'hpts.out' u 1:4 every 11::5 t 'r=0.0' w l lw 2, \
  'hpts.out' u 1:4 every 11::6 t 'r=0.1' w l lw 2, \
  'hpts.out' u 1:4 every 11::7 t 'r=0.2' w l lw 2, \
  'hpts.out' u 1:4 every 11::8 t 'r=0.3' w l lw 2, \
  'hpts.out' u 1:4 every 11::9 t 'r=0.4' w l lw 2

set out 'pipe_vy.pdf'
unset key
set xlabel 'Time'
set ylabel 'Vy'
set title 'Radial velocity'
p 'hpts.out' u 1:3 every 11::1 t 'r=0.4' w l lw 2, \
  'hpts.out' u 1:3 every 11::2 t 'r=0.3' w l lw 2, \
  'hpts.out' u 1:3 every 11::3 t 'r=0.2' w l lw 2, \
  'hpts.out' u 1:3 every 11::4 t 'r=0.1' w l lw 2, \
  'hpts.out' u 1:3 every 11::5 t 'r=0.0' w l lw 2, \
  'hpts.out' u 1:3 every 11::6 t 'r=0.1' w l lw 2, \
  'hpts.out' u 1:3 every 11::7 t 'r=0.2' w l lw 2, \
  'hpts.out' u 1:3 every 11::8 t 'r=0.3' w l lw 2, \
  'hpts.out' u 1:3 every 11::9 t 'r=0.4' w l lw 2

set out 'pipe_vx.pdf'
set key
set xlabel 'Time'
set ylabel 'Vx'
set title 'Azimuthal velocity'
p 'hpts.out' u 1:2 every 11::1 t 'r=0.4' w l lw 2, \
  'hpts.out' u 1:2 every 11::2 t 'r=0.3' w l lw 2, \
  'hpts.out' u 1:2 every 11::3 t 'r=0.2' w l lw 2, \
  'hpts.out' u 1:2 every 11::4 t 'r=0.1' w l lw 2, \
  'hpts.out' u 1:2 every 11::5 t 'r=0.0' w l lw 2, \
  'hpts.out' u 1:2 every 11::6 t 'r=0.1' w l lw 2, \
  'hpts.out' u 1:2 every 11::7 t 'r=0.2' w l lw 2, \
  'hpts.out' u 1:2 every 11::8 t 'r=0.3' w l lw 2, \
  'hpts.out' u 1:2 every 11::9 t 'r=0.4' w l lw 2
