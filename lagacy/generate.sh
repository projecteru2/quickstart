#/bin/sh

for i in {0..99}
do
   START=`shuf -i 1-100 -n 1`
   END=`shuf -i 101-300000 -n 1`
   echo $START $END
   sed -n ''${START}','${END}'p' words > $i
done
