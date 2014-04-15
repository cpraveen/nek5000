unset key
set xlabel 'radius'
set ylabel 'Vz'
set yran[0:1.1]
do for [i=0:1000] {
   p 'hpts.out' u 4 every ::(i*11)::(i*11 + 10) w l
   pause 0.1
}
