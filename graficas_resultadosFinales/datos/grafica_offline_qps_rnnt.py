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
agx15W = os.path.join("AGX15W", archivo)

batches_seenA30 = set()  # Set to keep track of batches seen
batches_seenAGX = set() 
batches_seenAGX15W = set() 

X1, Y1 = leer_archivo(a30, batches_seenA30)
X2, Y2 = leer_archivo(agx, batches_seenAGX)
X3, Y3 = leer_archivo(agx15W, batches_seenAGX15W)

plt.figure(figsize=(7, 5))

plt.plot(X1, Y1, label="A30", markersize=3)
plt.plot(X2, Y2, label="AGX", markersize=3)
plt.plot(X3, Y3, label="AGX15W", markersize=3)

#plt.xscale('log')  # Escala  en el eje x
#plt.yscale('log')  # Escala  en el eje y

plt.xlabel('Batch')
plt.ylabel('Resultado QPS')
#plt.title('Batch vs. Resultado QPS en Rnnt')

idx = (np.abs(np.array(X1) - 500)).argmin()
y_value = Y1[idx]
plt.plot([500, 500], [0, y_value], linestyle='--', color='r')

idx = (np.abs(np.array(X2) - 600)).argmin()
y_value = Y2[idx]
plt.plot([600, 600], [0, y_value], linestyle='--', color='r')

idx = (np.abs(np.array(X3) - 100)).argmin()
y_value = Y3[idx]
plt.plot([100, 100], [0, y_value], linestyle='--', color='r')
plt.legend()  # Mostrar leyenda
plt.grid(True)
plt.xlim(0, 1000)
plt.ylim(0, 5000)

plt.savefig("plot_{}_{}_qps.png".format(sys.argv[1], sys.argv[2]))
plt.show()
plt.close()

