#!/bin/bash

ZERO=0
BATCH_INI=10
BATCH_FIN=10
BATCH_PER=10

#OFFLINE
QPS_OFF_INI=710
QPS_OFF_FIN=710
QPS_OFF_PER=50

#SERVER
QPS_SER_INI=200
QPS_SER_FIN=1000
QPS_SER_PER=100

#SINGLESTREAM
NS_SIN_INI=100000
NS_SIN_FIN=100000
NS_SIN_PER=5000

cd ..

for j in Offline
do
sed -i "14s/$ZERO/$BATCH_INI/" /work/configs/rnnt/$j/custom.py #RANGO BATCH SIZE

if [ "$j" == "Offline" ]; then
ini=$((QPS_OFF_INI))
fin=$((QPS_OFF_FIN))
per=$((QPS_OFF_PER))
sed -i "43s/$ZERO.0/$QPS_OFF_INI.0/" /work/configs/rnnt/Offline/custom.py 
elif [ "$j" == "Server" ]; then
ini=$((QPS_SER_INI))
fin=$((QPS_SER_FIN))
per=$((QPS_SER_PER))
sed -i "50s/$ZERO/$QPS_SER_INI/" /work/configs/rnnt/Server/custom.py 
else
ini=$((NS_SIN_INI))
fin=$((NS_SIN_FIN))
per=$((NS_SIN_PER))
sed -i "46s/$ZERO/$NS_SIN_INI/" /work/configs/rnnt/SingleStream/custom.py 
fi


for ((batch= BATCH_INI; batch <= BATCH_FIN; batch+=BATCH_PER)) #RANGO BATCH SIZE
do

for ((valor = $ini; valor<= $fin; valor +=$per)) 
do

#EJECUCION
make run RUN_ARGS="--benchmarks=rnnt --scenarios=$j " > a30/rnnt/"rnnt_${j}_${batch}_${valor}.txt"

#CAMBIOS EN CUSTOM.PY
 if [ "$j" == "Offline" ]; then
sed -i "43s/$valor.0/$((valor + per)).0/" /work/configs/rnnt/$j/custom.py
elif [ "$j" == "Server" ]; then
sed -i "50s/$valor/$((valor + per))/" /work/configs/rnnt/$j/custom.py
else
sed -i "46s/$valor/$((valor + per))/" /work/configs/rnnt/$j/custom.py 
fi
done

#REINICIO VALORES NEXT BATCH
sed -i "14s/$batch/$((batch + BATCH_PER))/" /work/configs/rnnt/$j/custom.py 
if [ "$j" == "Offline" ]; then 
sed -i "43s/$valor.0/$ini.0/" /work/configs/rnnt/$j/custom.py 
elif [ "$j" == "Server" ]; then 
sed -i "50s/$valor/$ini/" /work/configs/rnnt/$j/custom.py 
else
sed -i "46s/$valor/$ini/" /work/configs/rnnt/$j/custom.py 
fi
done

sed -i "14s/$batch/$ZERO/" /work/configs/rnnt/$j/custom.py
if [ "$j" == "Offline" ]; then
sed -i "43s/$ini.0/$ZERO.0/" /work/configs/rnnt/$j/custom.py
elif [ "$j" == "Server" ]; then
sed -i "50s/$ini/$ZERO/" /work/configs/rnnt/$j/custom.py
else
sed -i "46s/$ini/$ZERO/" /work/configs/rnnt/$j/custom.py 
fi
done

