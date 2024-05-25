#!/bin/bash

ZERO=0
BATCH_INI=15
BATCH_FIN=19
BATCH_PER=1

#OFFLINE
#1500
QPS_OFF_INI=1450
QPS_OFF_FIN=1450
QPS_OFF_PER=500

#SERVER
QPS_SER_INI=1210  
QPS_SER_FIN=1250
QPS_SER_PER=10

#SINGLESTREAM
NS_SIN_INI=2000000 
NS_SIN_FIN=2000000
NS_SIN_PER=2000000

cd ..

for j in  Offline
do
sed -i "13s/$ZERO/$BATCH_INI/" /work/configs/bert/$j/custom.py #RANGO BATCH SIZE

if [ "$j" == "Offline" ]; then
ini=$((QPS_OFF_INI))
fin=$((QPS_OFF_FIN))
per=$((QPS_OFF_PER))
sed -i "22s/$ZERO.0/$QPS_OFF_INI.0/" /work/configs/bert/Offline/custom.py 
elif [ "$j" == "Server" ]; then
ini=$((QPS_SER_INI))
fin=$((QPS_SER_FIN))
per=$((QPS_SER_PER))
sed -i "44s/$ZERO/$QPS_SER_INI/" /work/configs/bert/Server/custom.py 
else
ini=$((NS_SIN_INI))
fin=$((NS_SIN_FIN))
per=$((NS_SIN_PER))
sed -i "40s/$ZERO/$NS_SIN_INI/" /work/configs/bert/SingleStream/custom.py 
fi


for ((batch= BATCH_INI; batch <= BATCH_FIN; batch+=BATCH_PER)) #RANGO BATCH SIZE
do

for ((qps = $ini; qps<= $fin; qps +=$per)) 
do

#EJECUCION
make run RUN_ARGS="--benchmarks=bert --scenarios=$j" > a30/bert/"bert_${j}_${batch}_${qps}.txt"

#CAMBIOS EN CUSTOM.PY
 if [ "$j" == "Offline" ]; then
sed -i "22s/$qps.0/$((qps + per)).0/" /work/configs/bert/$j/custom.py
elif [ "$j" == "Server" ]; then
sed -i "44s/$qps/$((qps + per))/" /work/configs/bert/$j/custom.py
#echo $((batch +BATCHPER))
else
sed -i "40s/$qps/$((qps + per))/" /work/configs/bert/$j/custom.py 
fi
done

#REINICIO VALORES NEXT BATCH
sed -i "13s/$batch/$((batch + BATCH_PER))/" /work/configs/bert/$j/custom.py 
if [ "$j" == "Offline" ]; then 
sed -i "22s/$qps.0/$ini.0/" /work/configs/bert/$j/custom.py 
elif [ "$j" == "Server" ]; then 
sed -i "44s/$qps/$ini/" /work/configs/bert/$j/custom.py 
else
sed -i "40s/$qps/$ini/" /work/configs/bert/$j/custom.py 
fi
done

sed -i "13s/$batch/$ZERO/" /work/configs/bert/$j/custom.py
if [ "$j" == "Offline" ]; then
sed -i "22s/$ini.0/$ZERO.0/" /work/configs/bert/$j/custom.py
elif [ "$j" == "Server" ]; then
sed -i "44s/$ini/$ZERO/" /work/configs/bert/$j/custom.py
else
sed -i "40s/$ini/$ZERO/" /work/configs/bert/$j/custom.py 
fi
done

