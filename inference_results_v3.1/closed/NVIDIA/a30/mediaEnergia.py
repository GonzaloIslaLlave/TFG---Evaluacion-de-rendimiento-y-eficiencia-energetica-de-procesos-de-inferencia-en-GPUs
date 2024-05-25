import csv
import numpy as np
import os

# Carpeta que contiene los archivos de entrada y nombre del archivo de salida
carpeta_entrada = "/home/gonisla/inference_results_v3.1/closed/NVIDIA/resultadosEnergiaA30"
archivo_salida = "bert_Offline.csv"
os.remove(archivo_salida)
# Iterar sobre todos los archivos en la carpeta de entrada
for nombre_archivo in os.listdir(carpeta_entrada):
    ruta_absoluta_entrada = os.path.join(carpeta_entrada, nombre_archivo)
    
    # Verificar si el archivo es un archivo CSV
    if nombre_archivo.endswith(".csv") and not nombre_archivo.startswith("."):  # Check added
        # Extraer el número Offline del nombre del archivo
        try:
            num_offline = int(nombre_archivo.split('_Offline')[1].split('_')[0])
            #print(num_offline)

        except IndexError:
            print(f"Error: No se pudo extraer el número Offline del archivo {nombre_archivo}")
            continue  # Saltar este archivo y pasar al siguiente en la iteración

        # Leer el archivo de entrada y extraer los datos
        datos = []
        with open(ruta_absoluta_entrada, 'r') as file:
            reader = csv.reader(file, delimiter=';')  # Especificar el delimitador como ';'
            next(reader)  # Saltar la primera fila (cabecera)
            for row in reader:
                if len(row) >= 3:  # Verificar que la fila tenga al menos 3 elementos
                    datos.append(row)

        # Calcular la media de los valores en la tercera columna
        valores_columna_3 = [float(row[2]) for row in datos if len(row) >= 3]
        media_columna_3 = np.mean(valores_columna_3)

        # Escribir los datos en el archivo de salida
        with open(archivo_salida, 'a') as file:
            writer = csv.writer(file)
            writer.writerow([f"{num_offline} Offline", media_columna_3])
