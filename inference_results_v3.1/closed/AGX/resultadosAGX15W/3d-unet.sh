#!/bin/bash

ZERO=0
BATCHINI=1
BATCHFIN=10
BATCHPER=1

#OFFLINE
QPSOFFINI=1
QPSOFFFIN=1
QPSOFFPER=1


#SINGLESTREAM
NSINI=525600000 
NSFIN=525600000
NSPER=1

cd ..

for j in Offline
do

if [ "$j" == "Offline" ]; then
ini=$((QPSOFFINI))
fin=$((QPSOFFFIN))
per=$((QPSOFFPER))
sed -i "928s/$ZERO/$BATCHINI/" /work/configs/3d-unet/$j/__init__.py 
sed -i "929s/$ZERO/$QPSOFFINI/" /work/configs/3d-unet/Offline/__init__.py 
else
ini=$((NSINI))
fin=$((NSFIN))
per=$((NSPER))
sed -i "475s/$ZERO/$BATCHINI/" /work/configs/3d-unet/$j/__init__.py
sed -i "476s/$ZERO/$NSINI/" /work/configs/3d-unet/SingleStream/__init__.py 
fi


for ((batch= BATCHINI; batch <= BATCHFIN; batch+=BATCHPER)) #RANGO BATCH SIZE
do

for ((valor = $ini; valor<= $fin; valor +=$per)) 
do

#EJECUCION
#make run RUN_ARGS="--benchmarks=3d-unet --scenarios=$j --fast" > resultadosAGX/3d-unet/"3d-unet_${j}_${batch}_${valor}.txt"
make run RUN_ARGS="--benchmarks=3d-unet --scenarios=$j --fast" > resultadosAGX15W/3d-unet/"3d-unet_${j}_${batch}_${valor}.txt"

#CAMBIOS EN __init__.py
 if [ "$j" == "Offline" ]; then
sed -i "929s/$valor/$((valor + per))/" /work/configs/3d-unet/$j/__init__.py
else
sed -i "476s/$valor/$((valor + per))/" /work/configs/3d-unet/$j/__init__.py 
fi
done

#REINICIO VALORES NEXT BATCH
if [ "$j" == "Offline" ]; then 
sed -i "928s/$batch/$((batch + BATCHPER))/" /work/configs/3d-unet/$j/__init__.py
sed -i "929s/$valor/$ini/" /work/configs/3d-unet/$j/__init__.py 
else
sed -i "475s/$batch/$((batch + BATCHPER))/" /work/configs/3d-unet/$j/__init__.py
sed -i "476s/$valor/$ini/" /work/configs/3d-unet/$j/__init__.py 
fi
done

if [ "$j" == "Offline" ]; then
sed -i "928s/$batch/$ZERO/" /work/configs/3d-unet/$j/__init__.py
sed -i "929s/$ini/$ZERO/" /work/configs/3d-unet/$j/__init__.py
else
sed -i "475s/$batch/$ZERO/" /work/configs/3d-unet/$j/__init__.py
sed -i "476s/$ini/$ZERO/" /work/configs/3d-unet/$j/__init__.py 
fi
done

 
