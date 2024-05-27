# Evaluación de rendimiento y eficiencia energética de procesos de inferencia en GPUs

En este repositorio están añadidas las aportaciones (gráficas, scripts y ficheros de configuración) añadidas en el TFG de 'Evaluación de rendimiento y eficiencia energética de procesos de inferencia en GPUs'.


En la carpeta graficas_resultadosFinales se disponen de varias carpetas:
En la carpeta 'datos' se encuentras los resultados obtenidos en las ejecuciones divididos en las carpetas A30, AGX y AGX15W. También nos encontramos con los scripts de las gráficas de latencia y throughput con las que se obtienen las gráficas y las gráficas pertinentes.
En la carpeta 'energia ' están los archivos csv obtenidos de cada máquina.
En las carpetas 'graficasA30', 'graficas AGX' y 'graficasAGX15W' se disponen de los gráficos de energía sacados con los datos anteriores.
Además se dispone de los scripts con los que se obtienen las gráficas de energía.

En cuanto a la carpeta 'inference_results_v3.1' se encuentran aquellas modificaciones del repositorio original (https://github.com/mlcommons/inference_results_v3.1/tree/main) que se han llevado a cabo en el trabajo.
Estos cambios se basan en la modificación de la configuración (carpeta NVIDIA/configs y AGX/configs), la implementación de la medición de energía (NVIDIA/code/action_handler y AGX/code/action_handler), los ficheros para automatizar la ejecución (NVIDIA/a30, AGX/resultadosAGX y AGX/resultadosAGX15W) y los resultados obtenidos (NVIDIA/resultadosEnergiaA30, NVIDIA/a30/{modelo}, AGX/resultadosAGX15W/{modelo}, AGX/resultadosAGX60W y AGX/resultadosAGX/{modelo}). Esto está descrito en el apartado 'Diseño de los experimentos' del trabajo.
