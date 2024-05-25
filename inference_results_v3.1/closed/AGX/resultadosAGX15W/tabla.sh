#/bin/bash
if [ $# -eq 1 ]; then
    echo "./tabla.sh modelo modo"
    exit 1
fi

carpeta=$1
modo=$2

rm datos_$1_$2.txt
if [ "$modo" == "Offline" ]; then
    printf "%-10s%-15s%-10s%-15s%-15s%-15s%-15s%-15s\n" "Modelo" "Offline" "Batch" "QPS esperados" "Resultado QPS" "Valido" "Latency ns" "Completed" >>datos_$1_$2.txt
elif [ "$modo" == "Server" ]; then    
    printf "%-10s%-15s%-10s%-15s%-15s%-15s%-15s%-15s\n" "Modelo" "Server" "Batch" "QPS esperados" "Tiempo ns" "Valido" "Completed Samples/s" >>datos_$1_$2.txt
elif [ "$modo" == "SingleStream" ]; then
    printf "%-10s%-15s%-10s%-15s%-15s%-15s%-15s%-15s%-15s%-15s\n" "Modelo" "SingleStream" "Batch" "Exp. ns stream" "Valido" "Percentil 90"  "Target"  "qps_w " "qps_w_o">>datos_$1_$2.txt
fi
antBatch=0
for archivo in $(ls -1v "$carpeta"/*); do
	nombreArch=$(basename "$archivo")
	modelo=$(echo "$archivo" | awk -F'/' '{print $NF}' | awk -F'_' '{print $1}')
        scenario=$(echo "$archivo" | cut -d "_" -f 2)
        batch=$(echo "$archivo" | cut -d "_" -f 3)
	arg=$(echo "$archivo" | cut -d "_" -f 4 | cut -d "." -f 1)
	
	if [ "$scenario" == "Offline" ]; then
            result=$(grep -oP -a 'result_samples_per_second: \K\d+\.\d+' "$archivo" | head -n 1)
	    valid=$(grep -a 'performance: result_samples_per_second:' "$archivo" | awk '{print $NF}')
	    latency=$(grep -a '99.90 percentile latency (ns)   :' "$archivo" | awk '{print $NF}')
	    completed=$(grep -a 'Completed samples per second    : ' "$archivo" | awk '{print $NF}')
            latencyS=$(echo "$latency" | awk '{print substr($0, 1, length($0)-9)}')
            if [ "$modo" == "Offline" ] && [ "$valid" == "VALID" ] && [ "$antBatch" != "$batch" ] && [ -n "$result" ]; then 
                antBatch="$batch"
                printf "%-10s%-15s%-10s%-15s%-15s%-15s%-15s%-15s\n" "$modelo" "$scenario" "$batch" "$arg" "$result" "$valid" "$latencyS" "$completed" >>datos_$1_$2.txt
            fi
        elif [ "$scenario" == "Server" ]; then
            result=$(grep -oP -a 'result_scheduled_samples_per_sec: \K\d+\.\d+' "$archivo" | head -n 1)
	    valid=$(grep -a 'performance: result_scheduled_samples_per_sec:' "$archivo" | awk '{print $NF}')
	    completed=$(grep -a 'Completed samples per second    :' "$archivo" |awk '{print $NF}')
	    latency=$(grep -a '99.90 percentile latency (ns)   :' "$archivo" |awk '{print $NF}')
            latencyS=$(echo "$latency" | awk '{print substr($0, 1, length($0)-9)}')
            if [ "$modo" == "Server" ]; then
    #           if [ "$valid" == "VALID" ]; then
                    printf "%-10s%-15s%-10s%-15s%-15s%-15s%-15s%-15s\n" "$modelo" "$scenario" "$batch" "$arg" "$result" "$valid" "$latencyS" "$completed" >>datos_$1_$2.txt
                #fi
            fi
      
	else 
            percentil90=$(grep -oP -a 'result_90.00_percentile_latency_ns: \K\d+' "$archivo" | head -n 1)
	    valid=$(grep -a ' performance: result_90.00_percentile_latency_ns:' "$archivo" | awk '{print $NF}')
	    target=$(grep -a 'target_qps : ' "$archivo" | awk '{print $NF}')
            qps_w=$(grep -a 'QPS w/ loadgen overhead         :' "$archivo" | awk '{print $NF}')
	    qps_w_o=$(grep -a 'QPS w/o loadgen overhead        :' "$archivo" | awk '{print $NF}')
            if [ "$modo" == "SingleStream" ]; then
                printf "%-10s%-15s%-10s%-15s%-15s%-15s%-15s%-15s%-15s%-10s\n" "$modelo" "$scenario" "$batch" "$arg"  "$valid" "$percentil90"  "$target"  "$qps_w " "$qps_w_o">>datos_$1_$2.txt
            fi
  
	 fi

	
done
