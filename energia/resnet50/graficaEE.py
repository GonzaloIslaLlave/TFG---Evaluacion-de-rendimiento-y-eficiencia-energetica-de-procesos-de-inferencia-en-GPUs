import matplotlib.pyplot as plt


def read_data(file_path):
    data = []
    with open(file_path, 'r') as file:
        for line in file:
            parts = line.strip().split()
            if len(parts) >= 6:
                batch_size = int(parts[2].split('=')[1])
                throughput = float(parts[-1])
                data.append((batch_size, throughput))
    return data


# Archivos de entrada
file_paths = ['/home/gonzalo/Escritorio/tfg/energia/resnet50/energiaMediaA30','/home/gonzalo/Escritorio/tfg/energia/resnet50/energiaMediaAGX','/home/gonzalo/Escritorio/tfg/energia/resnet50/energiaMediaAGX15W']

line_names = ['A30', 'AGX', 'AGX15W']
# Leer los datos de cada archivo
all_data = []
for file_path in file_paths:
    data = read_data(file_path)
    all_data.append(data)

# Graficar los datos
j=0
for i, data in enumerate(all_data, start=1):
    batch_sizes = [d[0] for d in data]
    throughputs = [d[1] for d in data]
    plt.plot(batch_sizes, throughputs, label=line_names[j])
    j=j+1



plt.xlabel('Batch')
plt.ylabel('QPS / W')

# Mostrar leyenda
plt.legend()


plt.grid(True)
plt.savefig("eeResnet50")
plt.show()


