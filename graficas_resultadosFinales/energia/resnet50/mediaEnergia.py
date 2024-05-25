import pandas as pd
import os

# Especificacion de los tipos de datos para cada columna
dtype = {
    'Set_id': str,
    'Time': float,
    'Line 8': float,
    #'Line 9': float,
    #'Line 10': float,
    'Sum': float
}

# Ruta de la carpeta con los archivos CSV
folder_path = '/home/gonzalo/Escritorio/tfg/energia/resnet50/resnet50AGX15W/'

# Archivo de salida
salida = "/home/gonzalo/Escritorio/tfg/energia/resnet50/energiaMediaAGX15W"

# Obtener lista de archivos ordenada
files = sorted(os.listdir(folder_path))

# Abrir archivo de salida en modo append
with open(salida, 'a') as f:
    # Iterar sobre todos los archivos en la carpeta
    for filename in files:
        if filename.endswith('.csv'):
            # Ruta completa del archivo CSV
            namefile = os.path.join(folder_path, filename)

            # Leer el archivo CSV
            df = pd.read_csv(namefile, delimiter=';', dtype=dtype)

            # Media de la columna 'Line 6'
            media_line6 = df['Line 8'].mean()

            # Mostrar la suma por el terminal
            print("Procesando {} --> Media Line 6: {}".format(filename, media_line6))

            # Escribir la media en el archivo de salida
            f.write("{} --> Media Line 6: {}\n".format(filename, media_line6))

