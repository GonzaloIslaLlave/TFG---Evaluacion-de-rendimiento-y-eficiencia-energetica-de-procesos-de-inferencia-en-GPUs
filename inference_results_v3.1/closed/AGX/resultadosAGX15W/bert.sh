#!/bin/bash

ZERO=0
BATCHINI=5
BATCHFIN=8
BATCHPER=1

#OFFLINE
QPSOFFINI=60
QPSOFFFIN=60
QPSOFFPER=10

#SERVER
QPSSERINI=1000 
QPSSERFIN=1100 
QPSSERPER=10

#SINGLESTREAM
QPSSININI=6200000
QPSSINFIN=6200000
QPSSINPER=1000000

cd ..

for j in Offline 
do

if [ "$j" == "Offline" ]; then
qpsIni=$((QPSOFFINI))
qpsFin=$((QPSOFFFIN))
qpsPer=$((QPSOFFPER))
sed -i "1309s/$ZERO/$BATCHINI/" /work/configs/bert/$j/__init__.py 
sed -i "1312s/$ZERO/$QPSOFFINI/" /work/configs/bert/$j/__init__.py 
elif [ "$j" == "Server" ]; then
qpsIni=$((QPSSERINI))
qpsFin=$((QPSSERFIN))
qpsPer=$((QPSSERPER))
sed -i "44s/$ZERO/$QPSSERINI/" /work/configs/bert/$j/custom.py
else
qpsIni=$((QPSSININI))
qpsFin=$((QPSSINFIN))
qpsPer=$((QPSSINPER))
sed -i "594s/$ZERO/$QPSSININI/" /work/configs/bert/$j/__init__.py 
fi


for ((batch= BATCHINI; batch <= BATCHFIN; batch+=BATCHPER)) #RANGO BATCH SIZE
do

for ((qps = $qpsIni; qps<= $qpsFin; qps +=$qpsPer)) 
do

#EJECUCION
make run RUN_ARGS="--benchmarks=bert --scenarios=$j" > resultadosAGX15W/bert/"bert_${j}_${batch}_${qps}.txt"

#CAMBIOS EN __init__.PY
 if [ "$j" == "Offline" ]; then
sed -i "1312s/$qps/$((qps + qpsPer))/" /work/configs/bert/$j/__init__.py
elif [ "$j" == "Server" ]; then
sed -i "44s/$qps/$((qps + qpsPer))/" /work/configs/bert/$j/custom.py
else
sed -i "594s/$qps/$((qps + qpsPer))/" /work/configs/bert/$j/__init__.py 
fi
done

#REINICIO VALORES NEXT BATCH
if [ "$j" == "Offline" ]; then 
sed -i "1309s/$batch/$((batch + BATCHPER))/" /work/configs/bert/$j/__init__.py
sed -i "1312s/$qps/$qpsIni/" /work/configs/bert/$j/__init__.py 
elif [ "$j" == "Server" ]; then 
sed -i "44s/$qps/$qpsIni/" /work/configs/bert/$j/custom.py
else
sed -i "594s/$qps/$qpsIni/" /work/configs/bert/$j/__init__.py 
fi
done

if [ "$j" == "Offline" ]; then
sed -i "1309s/$batch/$ZERO/" /work/configs/bert/$j/__init__.py
sed -i "1312s/$qpsIni/$ZERO/" /work/configs/bert/$j/__init__.py
elif [ "$j" == "Server" ]; then
sed -i "44s/$qpsIni/$ZERO/" /work/configs/bert/$j/custom.py
else
sed -i "594s/$qpsIni/$ZERO/" /work/configs/bert/$j/__init__.py 
fi
done

 
