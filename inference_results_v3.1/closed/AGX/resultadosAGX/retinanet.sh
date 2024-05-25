#!/bin/bash

ZERO=0
BATCHINI=1
BATCHFIN=10
BATCHPER=1

#OFFLINE
QPSOFFINI=100
QPSOFFFIN=100
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

for j in Offline
do

if [ "$j" == "Offline" ]; then
qpsIni=$((QPSOFFINI))
qpsFin=$((QPSOFFFIN))
qpsPer=$((QPSOFFPER))
sed -i "297s/$ZERO/$BATCHINI/" /work/configs/retinanet/$j/__init__.py
sed -i "302s/$ZERO/$QPSOFFINI/" /work/configs/retinanet/Offline/__init__.py 
elif [ "$j" == "Server" ]; then
qpsIni=$((QPSSERINI))
qpsFin=$((QPSSERFIN))
qpsPer=$((QPSSERPER))
sed -i "43s/$ZERO/$QPSSERINI/" /work/configs/retinanet/Server/custom.py 
elif [ "$j" == "MultiStream" ]; then 
qpsIni=$((QPSMULINI))
qpsFin=$((QPSMULFIN))
qpsPer=$((QPSMULPER))
sed -i "148s/$ZERO/$QPSSERINI/" /work/configs/retinanet/MultiStream/__init__.py 
else
qpsIni=$((QPSSININI))
qpsFin=$((QPSSINFIN))
qpsPer=$((QPSSINPER))
sed -i "135s/$ZERO/$QPSSININI/" /work/configs/retinanet/SingleStream/__init__.py 
fi


for ((batch= BATCHINI; batch <= BATCHFIN; batch+=BATCHPER)) #RANGO BATCH SIZE
do

for ((qps = $qpsIni; qps<= $qpsFin; qps +=$qpsPer)) 
do

#EJECUCION
make run RUN_ARGS="--benchmarks=retinanet --scenarios=$j --fast" > resultadosAGX/retinanet/"retinanet_${j}_${batch}_${qps}.txt"

#CAMBIOS EN __init__.py
 if [ "$j" == "Offline" ]; then
sed -i "302s/$qps/$((qps + qpsPer))/" /work/configs/retinanet/$j/__init__.py
elif [ "$j" == "Server" ]; then
sed -i "43s/$qps/$((qps + qpsPer))/" /work/configs/retinanet/$j/custom.py
elif [ "$j" == "MultiStream" ]; then 
sed -i "148s/$qps/$((qps + qpsPer))/" /work/configs/retinanet/$j/__init__.py 
else
sed -i "135s/$qps/$((qps + qpsPer))/" /work/configs/retinanet/$j/__init__.py 
fi
done

#REINICIO VALORES NEXT BATCH
if [ "$j" == "Offline" ]; then 
sed -i "297s/$batch/$((batch + BATCHPER))/" /work/configs/retinanet/$j/__init__.py
sed -i "302s/$qps/$qpsIni/" /work/configs/retinanet/$j/__init__.py 
elif [ "$j" == "Server" ]; then 
sed -i "43s/$qps/$qpsIni/" /work/configs/retinanet/$j/custom.py 
elif [ "$j" == "MultiStream" ]; then  
sed -i "148s/$qps/$qpsIni/" /work/configs/retinanet/$j/__init__.py 
else
sed -i "135s/$qps/$qpsIni/" /work/configs/retinanet/$j/__init__.py 
fi
done

if [ "$j" == "Offline" ]; then
sed -i "297s/$batch/$ZERO/" /work/configs/retinanet/$j/__init__.py
sed -i "302s/$qpsIni/$ZERO/" /work/configs/retinanet/$j/__init__.py
elif [ "$j" == "Server" ]; then
sed -i "43s/$qpsIni/$ZERO/" /work/configs/retinanet/$j/custom.py
elif [ "$j" == "MultiStream" ]; then
sed -i "148s/$qpsIni/$ZERO/" /work/configs/retinanet/$j/__init__.py
else
sed -i "135s/$qpsIni/$ZERO/" /work/configs/retinanet/$j/__init__.py 
fi
done

