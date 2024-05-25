#!/bin/bash

ZERO=0
BATCH_INI=1
BATCH_FIN=6
BATCH_PER=1

#OFFLINE
QPS_OFF_INI=1
QPS_OFF_FIN=1
QPS_OFF_PER=1


#SINGLESTREAM
NS_INI=50000000 
NS_FIN=50000000
NS_PER=500000000

cd ..

for j in Offline
do
sed -i "13s/$ZERO/$BATCH_INI/" /work/configs/3d-unet/$j/custom.py #RANGO BATCH SIZE

if [ "$j" == "Offline" ]; then
ini=$((QPS_OFF_INI))
fin=$((QPS_OFF_FIN))
per=$((QPS_OFF_PER))
sed -i "31s/$ZERO.70/$QPS_OFF_INI.70/" /work/configs/3d-unet/Offline/custom.py 
else
ini=$((NS_INI))
fin=$((NS_FIN))
per=$((NS_PER))
sed -i "35s/$ZERO/$NS_INI/" /work/configs/3d-unet/SingleStream/custom.py 
fi


for ((batch= BATCH_INI; batch <= BATCH_FIN; batch+=BATCH_PER)) #RANGO BATCH SIZE
do

for ((valor = $ini; valor<= $fin; valor +=$per)) 
do

#EJECUCION
make run RUN_ARGS="--benchmarks=3d-unet --scenarios=$j --fast"  > a30/3d-unet/"3d-unet_${j}_${batch}_${valor}.txt"

#CAMBIOS EN CUSTOM.PY
 if [ "$j" == "Offline" ]; then
sed -i "31s/$valor.70/$((valor + per)).70/" /work/configs/3d-unet/$j/custom.py
else
sed -i "35s/$valor/$((valor + per))/" /work/configs/3d-unet/$j/custom.py 
fi
done

#REINICIO VALORES NEXT BATCH
sed -i "13s/$batch/$((batch + BATCH_PER))/" /work/configs/3d-unet/$j/custom.py 
if [ "$j" == "Offline" ]; then 
sed -i "31s/$valor.70/$ini.70/" /work/configs/3d-unet/$j/custom.py 
else
sed -i "35s/$valor/$ini/" /work/configs/3d-unet/$j/custom.py 
fi
done

sed -i "13s/$batch/$ZERO/" /work/configs/3d-unet/$j/custom.py
if [ "$j" == "Offline" ]; then
sed -i "31s/$ini.70/$ZERO.70/" /work/configs/3d-unet/$j/custom.py
else
sed -i "35s/$ini/$ZERO/" /work/configs/3d-unet/$j/custom.py 
fi
done

