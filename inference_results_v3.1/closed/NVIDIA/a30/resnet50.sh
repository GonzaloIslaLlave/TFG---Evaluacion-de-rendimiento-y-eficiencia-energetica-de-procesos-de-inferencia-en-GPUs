#!/bin/bash

ZERO=0
BATCH_INI=12
BATCH_FIN=12
BATCH_PER=1000

#OFFLINE
QPS_OFF_INI=12000
QPS_OFF_FIN=12000
QPS_OFF_PER=500

#SERVER
QPS_SER_INI=100 
QPS_SER_FIN=2100
QPS_SER_PER=100

#SINGLESTREAM
NS_SIN_INI=500000
NS_SIN_FIN=500000
NS_SIN_PER=500000

#MULTISTREAM
QPS_MUL_INI=200000
QPS_MUL_FIN=1000000
QPS_MUL_PER=100000

cd ..

for j in  Offline
do
sed -i "13s/$ZERO/$BATCH_INI/" /work/configs/resnet50/$j/custom.py #RANGO BATCH SIZE

if [ "$j" == "Offline" ]; then
ini=$((QPS_OFF_INI))
fin=$((QPS_OFF_FIN))
per=$((QPS_OFF_PER))
sed -i "35s/$ZERO.0/$QPS_OFF_INI.0/" /work/configs/resnet50/$j/custom.py 
elif [ "$j" == "Server" ]; then
ini=$((QPS_SER_INI))
fin=$((QPS_SER_FIN))
per=$((QPS_SER_PER))
sed -i "42s/$ZERO/$QPS_SER_INI/" /work/configs/resnet50/$j/custom.py 
elif [ "$j" == "MultiStream" ]; then 
ini=$((QPS_MUL_INI)) 
fin=$((QPS_MUL_FIN))
per=$((QPS_MUL_PER)) 
sed -i "18s/$ZERO/$QPS_MUL_INI/" /work/configs/resnet50/$j/custom.py 
else
ini=$((NS_SIN_INI))
fin=$((NS_SIN_FIN))
per=$((NS_SIN_PER))
sed -i "38s/$ZERO/$NS_SIN_INI/" /work/configs/resnet50/$j/custom.py 
fi


for ((batch= BATCH_INI; batch <= BATCH_FIN; batch+=BATCH_PER)) #RANGO BATCH SIZE
do
echo $batch
for ((qps = $ini; qps<= $fin; qps +=$per)) 
do

#EJECUCION
make run RUN_ARGS="--benchmarks=resnet50 --scenarios=$j --fast" > a30/resnet50/"resnet50_${j}_${batch}_${qps}.txt"

#CAMBIOS EN CUSTOM.PY
 if [ "$j" == "Offline" ]; then
sed -i "35s/$qps.0/$((qps + per)).0/" /work/configs/resnet50/$j/custom.py
elif [ "$j" == "Server" ]; then
sed -i "42s/$qps/$((qps + per))/" /work/configs/resnet50/$j/custom.py
elif [ "$j" == "MultiStream" ]; then
sed -i "18s/$qps/$((qps + per))/" /work/configs/resnet50/$j/custom.py 
else
sed -i "38s/$qps/$((qps + per))/" /work/configs/resnet50/$j/custom.py 
fi
done

#REINICIO VALORES NEXT BATCH
sed -i "13s/$batch/$((batch + BATCH_PER))/" /work/configs/resnet50/$j/custom.py 
if [ "$j" == "Offline" ]; then 
sed -i "35s/$qps.0/$ini.0/" /work/configs/resnet50/$j/custom.py 
elif [ "$j" == "Server" ]; then 
sed -i "42s/$qps/$ini/" /work/configs/resnet50/$j/custom.py 
elif [ "$j" == "MultiStream" ]; then  
sed -i "18s/$qps/$ini/" /work/configs/resnet50/$j/custom.py 
else
sed -i "38s/$qps/$ini/" /work/configs/resnet50/$j/custom.py 
fi
done

sed -i "13s/$batch/$ZERO/" /work/configs/resnet50/$j/custom.py
if [ "$j" == "Offline" ]; then
sed -i "35s/$ini.0/$ZERO.0/" /work/configs/resnet50/$j/custom.py
elif [ "$j" == "Server" ]; then
sed -i "42s/$ini/$ZERO/" /work/configs/resnet50/$j/custom.py
elif [ "$j" == "MultiStream" ]; then
sed -i "18s/$ini/$ZERO/" /work/configs/resnet50/$j/custom.py 
else
sed -i "38s/$ini/$ZERO/" /work/configs/resnet50/$j/custom.py 
fi
done

