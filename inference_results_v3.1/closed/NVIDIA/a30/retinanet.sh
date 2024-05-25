#!/bin/bash

ZERO=0
BATCHINI=1
BATCHFIN=30
BATCHPER=1

#OFFLINE
QPSOFFINI=400
QPSOFFFIN=400
QPSOFFPER=500

#SERVER
QPSSERINI=1000  #MIN 20
QPSSERFIN=1100 #MENOS DE 1100 con BATCH 8, MENOS DE 1500
QPSSERPER=10

#SINGLESTREAM
QPSSININI=1000000 
QPSSINFIN=1000000
QPSSINPER=1000000

#MULTISTREAM
QPSMULINI=0
QPSMULFIN=0
QPSMULPER=0

cd ..

for j in  Offline
do
sed -i "13s/$ZERO/$BATCHINI/" /work/configs/retinanet/$j/custom.py #RANGO BATCH SIZE

if [ "$j" == "Offline" ]; then
qpsIni=$((QPSOFFINI))
qpsFin=$((QPSOFFFIN))
qpsPer=$((QPSOFFPER))
sed -i "35s/$ZERO.0/$QPSOFFINI.0/" /work/configs/retinanet/Offline/custom.py 
elif [ "$j" == "Server" ]; then
qpsIni=$((QPSSERINI))
qpsFin=$((QPSSERFIN))
qpsPer=$((QPSSERPER))
sed -i "43s/$ZERO/$QPSSERINI/" /work/configs/retinanet/Server/custom.py 
elif [ "$j" == "MultiStream" ]; then 
qpsIni=$((QPSMULINI))
qpsFin=$((QPSMULFIN))
qpsPer=$((QPSMULPER))
sed -i "43s/$ZERO/$QPSSERINI/" /work/configs/retinanet/MultiStream/custom.py 
else
qpsIni=$((QPSSININI))
qpsFin=$((QPSSINFIN))
qpsPer=$((QPSSINPER))
sed -i "39s/$ZERO/$QPSSININI/" /work/configs/retinanet/SingleStream/custom.py 
fi


for ((batch= BATCHINI; batch <= BATCHFIN; batch+=BATCHPER)) #RANGO BATCH SIZE
do

for ((qps = $qpsIni; qps<= $qpsFin; qps +=$qpsPer)) 
do

#EJECUCION
make run RUN_ARGS="--benchmarks=retinanet --scenarios=$j" > a30/retinanet/"retinanet_${j}_${batch}_${qps}.txt"

#CAMBIOS EN CUSTOM.PY
 if [ "$j" == "Offline" ]; then
sed -i "35s/$qps.0/$((qps + qpsPer)).0/" /work/configs/retinanet/$j/custom.py
elif [ "$j" == "Server" ]; then
sed -i "43s/$qps/$((qps + qpsPer))/" /work/configs/retinanet/$j/custom.py
elif [ "$j" == "MultiStream" ]; then 
sed -i "43s/$qps/$((qps + qpsPer))/" /work/configs/retinanet/$j/custom.py 
else
sed -i "39s/$qps/$((qps + qpsPer))/" /work/configs/retinanet/$j/custom.py 
fi
done

#REINICIO VALORES NEXT BATCH
sed -i "13s/$batch/$((batch + BATCHPER))/" /work/configs/retinanet/$j/custom.py 
if [ "$j" == "Offline" ]; then 
sed -i "35s/$qps.0/$qpsIni.0/" /work/configs/retinanet/$j/custom.py 
elif [ "$j" == "Server" ]; then 
sed -i "43s/$qps/$qpsIni/" /work/configs/retinanet/$j/custom.py 
elif [ "$j" == "MultiStream" ]; then  
sed -i "43s/$qps/$qpsIni/" /work/configs/retinanet/$j/custom.py 
else
sed -i "39s/$qps/$qpsIni/" /work/configs/retinanet/$j/custom.py 
fi
done

sed -i "13s/$batch/$ZERO/" /work/configs/retinanet/$j/custom.py
if [ "$j" == "Offline" ]; then
sed -i "35s/$qpsIni.0/$ZERO.0/" /work/configs/retinanet/$j/custom.py
elif [ "$j" == "Server" ]; then
sed -i "43s/$qpsIni/$ZERO/" /work/configs/retinanet/$j/custom.py
elif [ "$j" == "MultiStream" ]; then
sed -i "43s/$qpsIni/$ZERO/" /work/configs/retinanet/$j/custom.py
else
sed -i "39s/$qpsIni/$ZERO/" /work/configs/retinanet/$j/custom.py 
fi
done
#FALTA LO MISMO CON --config_ver="high_accuracy"  99.9%
#FALTA LO MISMO CON --fast

