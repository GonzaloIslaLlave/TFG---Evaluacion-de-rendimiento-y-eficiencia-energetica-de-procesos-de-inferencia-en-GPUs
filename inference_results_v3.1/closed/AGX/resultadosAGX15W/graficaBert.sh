import matplotlib.pyplot as plt

cd ..
archivo="bert_off_128.txt"
cd resultados
x = []

aux = $(grep -oP 'result_samples_per_second: \K\d+\.\d+' $archivo |head -1)
echo $aux
x.append(${aux})
plt.xlabel('Batch')
plt.ylabel('Tiempo')
plt.title('Offline Bert')


plt.savefig('bert_Offline')
plt.show()
