#!/bin/bash

ZERO=0
BATCHINI=150
BATCHFIN=300
BATCHPER=50

#OFFLINE
QPSOFFINI=1600
QPSOFFFIN=1600
QPSOFFPER=500

#SERVER
QPSSERINI=1000  #MIN 20
QPSSERFIN=1100 #MENOS DE 1100 con BATCH 8, MENOS DE 1500
QPSSERPER=10

#SINGLESTREAM
QPSSININI=660000
QPSSINFIN=1600000
QPSSINPER=100000

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
sed -i "772s/$ZERO/$BATCHINI/" /work/configs/resnet50/$j/__init__.py
sed -i "764s/$ZERO/$QPSOFFINI/" /work/configs/resnet50/$j/__init__.py 
elif [ "$j" == "Server" ]; then
qpsIni=$((QPSSERINI))
qpsFin=$((QPSSERFIN))
qpsPer=$((QPSSERPER))
sed -i "42s/$ZERO/$QPSSERINI/" /work/configs/resnet50/$j/custom.py 
elif [ "$j" == "MultiStream" ]; then 
qpsIni=$((QPSMULINI)) 
qpsFin=$((QPSMULFIN))
qpsPer=$((QPSMULPER)) 
sed -i "358s/$ZERO/$QPSSERINI/" /work/configs/resnet50/$j/__init__.py 
else
qpsIni=$((QPSSININI))
qpsFin=$((QPSSINFIN))
qpsPer=$((QPSSINPER))
sed -i "350s/$ZERO/$QPSSININI/" /work/configs/resnet50/$j/__init__.py 
fi


for ((batch= BATCHINI; batch <= BATCHFIN; batch+=BATCHPER)) #RANGO BATCH SIZE
do

for ((qps = $qpsIni; qps<= $qpsFin; qps +=$qpsPer)) 
do

#EJECUCION
#make run RUN_ARGS="--benchmarks=resnet50 --scenarios=$j --fast"> resultadosAGX/resnet50/"resnet50_${j}_${batch}_${qps}.txt"
make run RUN_ARGS="--benchmarks=resnet50 --scenarios=$j --fast"> resultadosAGX15W/resnet50/"resnet50_${j}_${batch}_${qps}.txt"

#CAMBIOS EN __init__.py
 if [ "$j" == "Offline" ]; then
sed -i "764s/$qps/$((qps + qpsPer))/" /work/configs/resnet50/$j/__init__.py
elif [ "$j" == "Server" ]; then
sed -i "42s/$qps/$((qps + qpsPer))/" /work/configs/resnet50/$j/custom.py
elif [ "$j" == "MultiStream" ]; then
sed -i "358s/$qps/$((qps + qpsPer))/" /work/configs/resnet50/$j/__init__.py 
else
sed -i "350s/$qps/$((qps + qpsPer))/" /work/configs/resnet50/$j/__init__.py 
fi
done

#REINICIO VALORES NEXT BATCH
if [ "$j" == "Offline" ]; then 
sed -i "772s/$batch/$((batch + BATCHPER))/" /work/configs/resnet50/$j/__init__.py
sed -i "764s/$qps/$qpsIni/" /work/configs/resnet50/$j/__init__.py 
elif [ "$j" == "Server" ]; then 
sed -i "42s/$qps/$qpsIni/" /work/configs/resnet50/$j/custom.py 
elif [ "$j" == "MultiStream" ]; then  
sed -i "358s/$qps/$qpsIni/" /work/configs/resnet50/$j/__init__.py 
else
sed -i "350s/$qps/$qpsIni/" /work/configs/resnet50/$j/__init__.py 
fi
done

if [ "$j" == "Offline" ]; then
sed -i "772s/$batch/$ZERO/" /work/configs/resnet50/$j/__init__.py
sed -i "764s/$qpsIni/$ZERO/" /work/configs/resnet50/$j/__init__.py
elif [ "$j" == "Server" ]; then
sed -i "42s/$qpsIni/$ZERO/" /work/configs/resnet50/$j/custom.py
elif [ "$j" == "MultiStream" ]; then
sed -i "358s/$qpsIni/$ZERO/" /work/configs/resnet50/$j/__init__.py 
else
sed -i "350s/$qpsIni/$ZERO/" /work/configs/resnet50/$j/__init__.py 
fi
done

