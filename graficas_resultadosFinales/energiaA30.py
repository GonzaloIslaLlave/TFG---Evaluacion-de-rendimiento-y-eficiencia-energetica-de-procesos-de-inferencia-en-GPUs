import glob
import pandas as pd
import matplotlib.pyplot as plt
import re

# Folder path
carpeta = 'energia/A30/resnet50/'

# Pattern to match CSV files
patron = carpeta + '*.csv'

# List to hold DataFrames and labels with their corresponding data
dataframes = []
labels_with_data = []

# Iterate over each CSV file matching the pattern
for archivo in glob.glob(patron):
    df = pd.read_csv(archivo, delimiter=';')
    df['Archivo'] = archivo.split('/')[-1]
    dataframes.append(df)

    # Extract Batch and QPS values using regular expressions
    archivo_name = archivo.split('/')[-1]
    batch_match = re.search(r'Offline(\d+)', archivo_name)
    qps_match = re.search(r'_(\d+)', archivo_name)

    if batch_match and qps_match:
         batch_value = int(batch_match.group(1))
         qps_value = qps_match.group(1)
         label = 'Batch = {:<5} QPS = {:<5}'.format(batch_value, qps_value)
    else:
         batch_value = float('inf')  # Use infinity to push unmatched to the end
         label = archivo_name  # Fallback to filename if regex fails


    labels_with_data.append((batch_value, label, df))
# Sort labels and data by Batch value
labels_with_data.sort(key=lambda x: x[0])
plt.figure(figsize=(5, 4))  # Set figure size
# Plotting each DataFrame in sorted order
for _, label, df in labels_with_data:
    print(df.columns)
    plt.plot(df['Time'], df['Line 6'], label=label)

# Sort labels for printing in terminal
labels_with_data.sort(key=lambda x: x[0])

# Print labels in the terminal
for batch_value, label, _ in labels_with_data:
    print(label)

# Plot customization
plt.xlabel('Tiempo')
plt.ylabel('Gasto de GPU (W)')
#plt.title('Resnet50 Offline NVIDIA A30')
plt.legend()
plt.grid(True)


plt.ylim(0, 200000)

plt.gca().yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: int(x / 1000))) 

plt.subplots_adjust(left=0.15)  # Adjust the right margin

# Save the plot as a PNG file
plt.savefig("graficasA30/resnet50A30.png")

# Show the plot
plt.show()



