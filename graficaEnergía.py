import pandas as pd
import os
import matplotlib.pyplot as plt
# Specify the data types for each column
dtype = {
    'Set_id': str,
    'Time': float,
    'Line 8': float,
    'Line 9': float,
    'Line 10': float,
    'Sum': float
}

namefile='/home/gonzalo/Escritorio/tfg/energia/AGX15W/resnet50/test_Orin_resnet50_Offline20_1800.csv'
df = pd.read_csv(namefile, delimiter=';')


fig,ax = plt.subplots()
time=df['Time']
line8=df['Line 8']
line9=df['Line 9']
line10=df['Line 10']



ax.bar(time,line10,width=0.2,align='center',label='Line 10')
ax.bar(time,line9,width=0.2,align='center',label='Line 9', bottom=line10)
ax.bar(time,line8,width=0.2,align='center',label='Line 8', bottom=line10 + line9)

ax.set_xlabel('Time')
ax.set_ylabel('Value')
ax.legend()
filename_without_extension = os.path.splitext(os.path.basename(namefile))[0]
plt.savefig(filename_without_extension + '.png')
plt.show()
