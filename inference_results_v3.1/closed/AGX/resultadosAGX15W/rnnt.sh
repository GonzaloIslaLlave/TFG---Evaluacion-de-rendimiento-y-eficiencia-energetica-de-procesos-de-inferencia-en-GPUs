#!/bin/bash

ZERO=0
BATCHINI=60
BATCHFIN=70
BATCHPER=10

#OFFLINE
QPSOFFINI=150
QPSOFFFIN=150
QPSOFFPER=1

#SERVER
QPSSERINI=200
QPSSERFIN=1000
QPSSERPER=100

#SINGLESTREAM
NSSININI=950000000 
NSSINFIN=950000000
NSSINPER=10000000

cd ..

for j in Offline
do

if [ "$j" == "Offline" ]; then
ini=$((QPSOFFINI))
fin=$((QPSOFFFIN))
per=$((QPSOFFPER))
sed -i "443s/$ZERO/$BATCHINI/" /work/configs/rnnt/$j/__init__.py 
sed -i "445s/$ZERO/$QPSOFFINI/" /work/configs/rnnt/Offline/__init__.py 
elif [ "$j" == "Server" ]; then
ini=$((QPSSERINI))
fin=$((QPSSERFIN))
per=$((QPSSERPER))
sed -i "50s/$ZERO/$QPSSERINI/" /work/configs/rnnt/Server/custom.py 
else
ini=$((NSSININI))
fin=$((NSSINFIN))
per=$((NSSINPER))
sed -i "231s/$ZERO/$NSSININI/" /work/configs/rnnt/SingleStream/__init__.py 
fi


for ((batch= BATCHINI; batch <= BATCHFIN; batch+=BATCHPER)) #RANGO BATCH SIZE
do

for ((valor = $ini; valor<= $fin; valor +=$per)) 
do

#EJECUCION
#make run RUN_ARGS="--benchmarks=rnnt --scenarios=$j --fast" > resultadosAGX/rnnt/"rnnt_${j}_${batch}_${valor}.txt"
make run RUN_ARGS="--benchmarks=rnnt --scenarios=$j --fast" > resultadosAGX15W/rnnt/"rnnt_${j}_${batch}_${valor}.txt"

#CAMBIOS EN __init__.py
 if [ "$j" == "Offline" ]; then
sed -i "445s/$valor/$((valor + per))/" /work/configs/rnnt/$j/__init__.py
elif [ "$j" == "Server" ]; then
sed -i "50s/$valor/$((valor + per))/" /work/configs/rnnt/$j/custom.py
else
sed -i "231s/$valor/$((valor + per))/" /work/configs/rnnt/$j/__init__.py 
fi
done

#REINICIO VALORES NEXT BATCH
if [ "$j" == "Offline" ]; then 
sed -i "443s/$batch/$((batch + BATCHPER))/" /work/configs/rnnt/$j/__init__.py
sed -i "445s/$valor/$ini/" /work/configs/rnnt/$j/__init__.py 
elif [ "$j" == "Server" ]; then 
sed -i "50s/$valor/$ini/" /work/configs/rnnt/$j/custom.py 
else
sed -i "231s/$valor/$ini/" /work/configs/rnnt/$j/__init__.py 
fi
done

if [ "$j" == "Offline" ]; then
sed -i "443s/$batch/$ZERO/" /work/configs/rnnt/$j/__init__.py
sed -i "445s/$ini/$ZERO/" /work/configs/rnnt/$j/__init__.py
elif [ "$j" == "Server" ]; then
sed -i "50s/$ini/$ZERO/" /work/configs/rnnt/$j/custom.py
else
sed -i "231s/$ini/$ZERO/" /work/configs/rnnt/$j/__init__.py 
fi
done

cd work
