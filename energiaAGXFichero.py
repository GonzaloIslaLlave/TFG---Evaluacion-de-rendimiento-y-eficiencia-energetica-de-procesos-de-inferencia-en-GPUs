import pandas as pd
import os
import matplotlib.pyplot as plt

dtype = {
    'Set_id': str,
    'Time': float,
    'Line 8': float,
    'Line 9': float,
    'Line 10': float,
    'Sum': float
}

folder_path = '/home/gonzalo/Escritorio/tfg/energia/AGX15W/rnnt/'
save_path = '/home/gonzalo/Escritorio/tfg/graficasAGX15W/rnnt/'

for filename in os.listdir(folder_path):
    if filename.endswith('.csv'):
        filepath = os.path.join(folder_path, filename)
        df = pd.read_csv(filepath, delimiter=';', dtype=dtype)

        fig, ax = plt.subplots()
        time = df['Time']
        line8 = df['Line 8']
        line9 = df['Line 9']
        line10 = df['Line 10']

        ax.plot(time, line10, label='Line 10', marker='o', linewidth=0.5, markersize=2)
        ax.plot(time, line9, label='Line 9', marker='o', linewidth=0.5, markersize=2)
        ax.plot(time, line8, label='Line 8', marker='o', linewidth=0.5, markersize=2)

        ax.set_xlabel('Time (s)')
        ax.set_ylabel('Gasto de GPU (W)')
        ax.legend()
        plt.title('Resnet50 Offline AGX 15w - {}'.format(filename))
        filename_without_extension = os.path.splitext(filename)[0]
        plt.savefig(os.path.join(save_path, filename_without_extension + '.png'))
        plt.close(fig)

