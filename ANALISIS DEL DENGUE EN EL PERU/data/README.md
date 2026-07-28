# Datos

Este proyecto **no incluye la base de datos cruda** dentro del repositorio porque:

1. El archivo original del MINSA (`Proyecto_Final.csv`) pesa ~103 MB, y GitHub no es un buen lugar para alojar archivos tan pesados.
2. El script `scripts/EDA.R` es reproducible: descarga la fuente directamente desde la Plataforma Nacional de Datos Abiertos (ver sección de "Importación de datos" en el script), por lo que cualquier persona puede volver a generar esta carpeta ejecutando el script.

**Fuente original:**
https://www.datosabiertos.gob.pe/group/ministerio-de-salud-minsa

**Dataset utilizado:** Vigilancia epidemiológica de casos de dengue, notificados al sistema de vigilancia en salud pública del Perú, gestionado por el Centro Nacional de Epidemiología, Prevención y Control de Enfermedades (MINSA).

**Variables incluidas:** departamento, provincia, distrito, localidad, enfermedad, año, semana epidemiológica, diagnóstico, diresa, ubigeo, localcod, edad, tipo_edad, sexo.