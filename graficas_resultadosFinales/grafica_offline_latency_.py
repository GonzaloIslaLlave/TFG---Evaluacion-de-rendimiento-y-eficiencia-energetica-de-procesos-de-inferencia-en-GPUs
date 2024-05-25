import matplotlib.pyplot as plt
import os
import sys

def leer_archivo(ruta):
    X = []
    Y = []
    with open(ruta, 'r') as file:
        next(file)
        for line in file:
            columns = line.strip().split()
            if len(columns) >= 5:  # Verificar que hay al menos 5 columnas en la 
                if columns[2].replace('.', '', 1).isdigit() and ':' not in columns[4]:
                    try:
                        X.append(float(columns[2]))  
                        Y.append(float(columns[6]))
                    except ValueError:
                        # Manejar casos donde los datos no son 
                        pass
    return X, Y


archivo = "datos_{}_{}.txt".format(sys.argv[1], sys.argv[2])  # Generar el nombre del archivo
# Leer los datos de los tres archivos
a30 = os.path.join("A30", archivo)
agx = os.path.join("AGX", archivo)
agx15W = os.path.join("AGX15W", archivo)

X1, Y1 = leer_archivo(a30)
X2, Y2 = leer_archivo(agx)
X3, Y3 = leer_archivo(agx15W)

plt.figure(figsize=(6, 4))


plt.plot(X1, Y1, label=a30, marker='o', markersize=3)
plt.plot(X2, Y2, label=agx, marker='o', markersize=3)
plt.plot(X3, Y3, label=agx15W, marker='o', markersize=3)



plt.xlabel('Batch')
plt.ylabel('Latency')
plt.title('Batch vs. Latency')
plt.legend()  # Mostrar leyenda
plt.grid(True)
plt.show()

