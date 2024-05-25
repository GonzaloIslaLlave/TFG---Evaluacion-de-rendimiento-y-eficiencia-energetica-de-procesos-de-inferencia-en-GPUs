#/bin/bash

rm datosBert.txt

carpeta=bert 
for archivo in $(ls -1v "$carpeta"/*); do
	nombreArch=$(basename "$archivo")
	modelo=$(echo "$archivo" | awk -F'/' '{print $NF}' | awk -F'_' '{print $1}')
        scenario=$(echo "$archivo" | cut -d "_" -f 2)
        batch=$(echo "$archivo" | cut -d "_" -f 3)
	arg=$(echo "$archivo" | cut -d "_" -f 4 | cut -d "." -f 1)
	
	if [ "$scenario" == "Offline" ]; then
            timeNs=$(grep -oP -a 'result_samples_per_second: \K\d+\.\d+' "$archivo" | head -n 1)
	    valid=$(grep -a 'performance: result_samples_per_second:' "$archivo" | awk '{print $NF}')


        elif [ "$scenario" == "Server" ]; then
            timeNs=$(grep -oP -a 'result_scheduled_samples_per_sec: \K\d+\.\d+' "$archivo" | head -n 1)
	    valid=$(grep -a 'performance: result_scheduled_samples_per_sec:' "$archivo" | awk '{print $NF}')

      
	else 
            timeNs=$(grep -oP -a 'result_90.00_percentile_latency_ns: \K\d+' "$archivo" | head -n 1)
	    valid=$(grep -a ' performance: result_90.00_percentile_latency_ns:' "$archivo" | awk '{print $NF}')

  
	 fi

	printf "%-10s%-15s%-5s%-10s%-10s%-10s\n" "$modelo" "$scenario" "$batch" "$arg" "$timeNs" "$valid" >>datosBert.txt
	
done
