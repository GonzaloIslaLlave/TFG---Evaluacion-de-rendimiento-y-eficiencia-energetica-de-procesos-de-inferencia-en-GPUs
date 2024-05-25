import matplotlib.pyplot as plt
import os
import sys
import numpy as np

def leer_archivo(ruta, batches_seen):
    X = []
    Y = []
    with open(ruta, 'r') as file:
        next(file)
        for line in file:
            columns = line.strip().split()
            if len(columns) >= 5:  # Verificar que hay al menos 5 columnas en la 
                if columns[2].replace('.', '', 1).isdigit() and ':' not in columns[4]:
                    batch = float(columns[2])
                    if batch not in batches_seen:
                        batches_seen.add(batch)
                        try:
                            X.append(batch)
                            Y.append(float(columns[4]))
                        except ValueError:
                            # Manejar casos donde los datos no son 
                            pass
    return X, Y

archivo = "datos_{}_{}.txt".format(sys.argv[1], sys.argv[2])  # Generar el nombre del archivo
# Leer los datos de los tres archivos
a30 = os.path.join("A30", archivo)
agx = os.path.join("AGX", archivo)


batches_seenA30 = set()  # Set to keep track of batches seen
batches_seenAGX = set() 


X1, Y1 = leer_archivo(a30, batches_seenA30)
X2, Y2 = leer_archivo(agx, batches_seenAGX)

plt.figure(figsize=(7, 5))

plt.plot(X1, Y1, label="A30", markersize=3)
plt.plot(X2, Y2, label="AGX", markersize=3)

plt.ylim(0,5)
plt.xlim(1,8)
#plt.xscale('log')  # Escala  en el eje x
#plt.yscale('log')  # Escala  en el eje y

plt.xlabel('Batch')
plt.ylabel('Resultado QPS')
#plt.title('Batch vs. Resultado QPS')


plt.legend()  # Mostrar leyenda
plt.grid(True)
plt.savefig("plot_{}_{}.png".format(sys.argv[1], sys.argv[2]))
plt.show()
plt.close()

