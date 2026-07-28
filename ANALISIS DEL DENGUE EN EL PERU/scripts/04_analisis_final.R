# ================================================================
# PROYECTO FINAL
# CURSO: ANÁLISIS EXPLORATORIO DE DATOS CON R
#
# Archivo      : 04_analisis_final.R
# Autor        : Cielo Casimiro Payano
# Base de datos: Vigilancia Epidemiológica del Dengue - MINSA
#
# Objetivo:
# Realizar un análisis descriptivo e interpretativo de los casos
# reportados de dengue en el Perú utilizando técnicas de análisis
# exploratorio y visualización de datos.
# ================================================================

#----------------------------------------------------------
# 1. LIBRERÍAS
#----------------------------------------------------------

library(tidyverse)
library(janitor)
library(scales)
library(patchwork)

#----------------------------------------------------------
# 2. IMPORTACIÓN DE DATOS
#----------------------------------------------------------

df <- read_delim(
  "Proyecto_Final.csv",
  delim=";",
  locale = locale(encoding="Latin1")
)

#----------------------------------------------------------
# 3. EXPLORACIÓN INICIAL
#----------------------------------------------------------

glimpse(df)

names(df)

dim(df)

summary(df)

#----------------------------------------------------------
# 4. LIMPIEZA DE DATOS
#----------------------------------------------------------

df <- df %>%
  
  clean_names() %>%
  
  distinct()

# Conversión de variables

df <- df %>%
  
  mutate(
    
    edad=as.numeric(edad),
    
    ano=as.numeric(ano),
    
    semana=as.numeric(semana)
    
  )

# Eliminación de registros inconsistentes

df <- df %>%
  
  filter(
    
    !is.na(edad),
    
    edad>=0,
    
    edad<=120
    
  )

#----------------------------------------------------------
# 5. CREACIÓN DE VARIABLES
#----------------------------------------------------------

df <- df %>%
  
  mutate(
    
    grupo_edad=
      
      case_when(
        
        edad<12 ~ "Niños",
        
        edad>=12 & edad<18 ~ "Adolescentes",
        
        edad>=18 & edad<30 ~ "Jóvenes",
        
        edad>=30 & edad<60 ~ "Adultos",
        
        edad>=60 ~ "Adultos Mayores"
        
      )
    
  )

df$grupo_edad <- factor(
  
  df$grupo_edad,
  
  levels=c(
    
    "Niños",
    
    "Adolescentes",
    
    "Jóvenes",
    
    "Adultos",
    
    "Adultos Mayores"
    
  )
  
)

#----------------------------------------------------------
# 6. PREGUNTA DE INVESTIGACIÓN
#----------------------------------------------------------

cat("\n")

cat("=================================================\n")

cat("PREGUNTA DE INVESTIGACIÓN\n")

cat("=================================================\n\n")

cat("¿Cómo se distribuyen los casos de dengue registrados")

cat(" en el Perú según el sexo, la edad,")

cat(" el departamento y el año de ocurrencia?\n")

#----------------------------------------------------------
# 7. HIPÓTESIS DESCRIPTIVA
#----------------------------------------------------------

cat("\n")

cat("HIPÓTESIS\n\n")

cat("Se espera encontrar diferencias en la distribución")

cat(" de los casos de dengue según")

cat(" la edad, el sexo, el departamento")

cat(" y el periodo de estudio.\n")

#----------------------------------------------------------
# 8. ESTADÍSTICAS GENERALES
#----------------------------------------------------------

estadisticas <- df %>%
  
  summarise(
    
    Total_Registros=n(),
    
    Edad_Promedio=mean(edad),
    
    Edad_Mediana=median(edad),
    
    Edad_Min=min(edad),
    
    Edad_Max=max(edad),
    
    Desv_Estandar=sd(edad)
    
  )

estadisticas

cat("\n")

cat("Interpretación:\n")

cat("La edad promedio permite identificar el perfil etario")

cat(" predominante de la población afectada.\n")

#----------------------------------------------------------
# 9. ANÁLISIS POR SEXO
#----------------------------------------------------------

sexo_tabla <-
  
  df %>%
  
  count(sexo) %>%
  
  mutate(
    
    porcentaje=
      
      round(
        
        n/sum(n)*100,
        
        2
        
      )
    
  )

sexo_tabla

cat("\n")

cat("Interpretación:\n")

cat("El porcentaje obtenido permite evaluar")

cat(" si existe predominio")

cat(" de casos entre hombres y mujeres.\n")

#----------------------------------------------------------
# 10. ANÁLISIS POR GRUPOS ETARIOS
#----------------------------------------------------------

edad_tabla <-
  
  df %>%
  
  count(grupo_edad) %>%
  
  mutate(
    
    Porcentaje=
      
      round(
        
        n/sum(n)*100,
        
        2
        
      )
    
  )

edad_tabla

cat("\n")

cat("Interpretación:\n")

cat("La clasificación etaria permite identificar")

cat(" cuál grupo concentra")

cat(" la mayor cantidad de registros epidemiológicos.\n")

#=========================================================
# 11. CASOS POR AÑO
#=========================================================

casos_anio <- df %>%
  count(ano) %>%
  arrange(ano)

casos_anio

casos_anio %>%
  mutate(
    Porcentaje = round(n/sum(n)*100,2)
  )

cat("\n")
cat("INTERPRETACIÓN\n")
cat("La distribución anual permite identificar los años con\n")
cat("mayor incidencia de casos de dengue.\n")

#=========================================================
# 12. CASOS POR DEPARTAMENTO
#=========================================================

departamentos <- df %>%
  count(departamento, sort = TRUE)

departamentos

top10_departamentos <- departamentos %>%
  slice_head(n = 10)

top10_departamentos

top10_departamentos %>%
  mutate(
    Porcentaje = round(n/sum(n)*100,2)
  )

cat("\n")
cat("INTERPRETACIÓN\n")
cat("Los departamentos del Top 10 concentran la mayor\n")
cat("cantidad de registros de dengue.\n")

#=========================================================
# 13. CASOS POR PROVINCIA
#=========================================================

top_provincias <- df %>%
  count(provincia, sort = TRUE) %>%
  slice_head(n = 15)

top_provincias

cat("\n")
cat("INTERPRETACIÓN\n")
cat("El análisis provincial permite localizar con mayor\n")
cat("precisión las zonas más afectadas.\n")

#=========================================================
# 14. CASOS POR DIAGNÓSTICO
#=========================================================

diagnostico <- df %>%
  count(diagnostic, sort = TRUE)

diagnostico

diagnostico %>%
  mutate(
    porcentaje = round(n/sum(n)*100,2)
  )

cat("\n")
cat("INTERPRETACIÓN\n")
cat("La variable diagnóstico permite conocer la composición\n")
cat("de los registros epidemiológicos.\n")

#=========================================================
# 15. TABLA CRUZADA
# SEXO × GRUPO ETARIO
#=========================================================

tabla_sexo_edad <- df %>%
  count(grupo_edad, sexo)

tabla_sexo_edad

tabla_sexo_edad %>%
  group_by(grupo_edad) %>%
  mutate(
    porcentaje = round(n/sum(n)*100,2)
  )

cat("\n")
cat("INTERPRETACIÓN\n")
cat("Esta tabla muestra la composición por sexo dentro de\n")
cat("cada grupo de edad.\n")

#=========================================================
# 16. TABLA CRUZADA
# SEXO × AÑO
#=========================================================

tabla_anio <- df %>%
  count(ano, sexo)

tabla_anio

cat("\n")
cat("INTERPRETACIÓN\n")
cat("Permite evaluar la evolución temporal de los casos\n")
cat("según el sexo.\n")

#=========================================================
# 17. TABLA CRUZADA
# DEPARTAMENTO × AÑO
#=========================================================

tabla_departamento <- df %>%
  count(departamento, ano)

tabla_departamento

cat("\n")
cat("INTERPRETACIÓN\n")
cat("Esta tabla resume la distribución espacial y temporal\n")
cat("de los registros.\n")

#=========================================================
# 18. EDAD SEGÚN SEXO
#=========================================================

edad_sexo <- df %>%
  group_by(sexo) %>%
  summarise(
    
    Casos = n(),
    
    Edad_Promedio = round(mean(edad),2),
    
    Mediana = median(edad),
    
    Minimo = min(edad),
    
    Maximo = max(edad),
    
    Desv = round(sd(edad),2)
    
  )

edad_sexo

cat("\n")
cat("INTERPRETACIÓN\n")
cat("Se comparan los principales estadísticos descriptivos\n")
cat("de la edad entre hombres y mujeres.\n")

#=========================================================
# 19. EDAD POR DEPARTAMENTO
#=========================================================

edad_departamento <- df %>%
  
  group_by(departamento) %>%
  
  summarise(
    
    Casos = n(),
    
    Edad_Promedio = round(mean(edad),1)
    
  ) %>%
  
  arrange(desc(Casos))

edad_departamento

cat("\n")
cat("INTERPRETACIÓN\n")
cat("Se identifican los departamentos con mayor número de\n")
cat("casos y la edad promedio de los pacientes.\n")

#=========================================================
# 20. MATRIZ RESUMEN
#=========================================================

resumen_general <- list(
  
  Estadisticas = estadisticas,
  
  Sexo = sexo_tabla,
  
  Grupo_Edad = edad_tabla,
  
  Casos_Año = casos_anio,
  
  Departamentos = top10_departamentos,
  
  Provincias = top_provincias,
  
  Diagnostico = diagnostico
  
)

print(resumen_general)

cat("\n")
cat("=============================================\n")
cat("FIN DEL ANÁLISIS TABULAR\n")
cat("=============================================\n")
#=========================================================
# 21. VISUALIZACIONES DEL ANÁLISIS FINAL
#=========================================================

theme_set(theme_minimal(base_size = 13))

#---------------------------------------------------------
# GRÁFICO 1
# Evolución anual de casos por sexo
#---------------------------------------------------------

g1 <- ggplot(tabla_anio,
             aes(x = ano,
                 y = n,
                 color = sexo,
                 group = sexo)) +
  
  geom_line(linewidth = 1.3) +
  
  geom_point(size = 3) +
  
  labs(
    
    title = "Evolución anual de los casos de dengue",
    
    subtitle = "Comparación por sexo",
    
    x = "Año",
    
    y = "Número de casos",
    
    color = "Sexo"
    
  )

g1

ggsave(
  
  "figures/grafico01_tendencia_sexo.png",
  
  g1,
  
  width=10,
  
  height=6,
  
  dpi=300
  
)

#---------------------------------------------------------
# GRÁFICO 2
# Top 10 departamentos
#---------------------------------------------------------

g2 <- ggplot(
  
  top10_departamentos,
  
  aes(
    
    reorder(departamento,n),
    
    n,
    
    fill=n
    
  )
  
)+
  
  geom_col(show.legend=FALSE)+
  
  coord_flip()+
  
  labs(
    
    title="Top 10 departamentos con más casos",
    
    x="Departamento",
    
    y="Número de casos"
    
  )

g2

ggsave(
  
  "figures/grafico02_departamentos.png",
  
  g2,
  
  width=10,
  
  height=7,
  
  dpi=300
  
)

#---------------------------------------------------------
# GRÁFICO 3
# Grupo etario
#---------------------------------------------------------

g3 <- ggplot(
  
  edad_tabla,
  
  aes(
    
    grupo_edad,
    
    n,
    
    fill=grupo_edad
    
  )
  
)+
  
  geom_col(show.legend=FALSE)+
  
  labs(
    
    title="Distribución de casos por grupo etario",
    
    x="Grupo etario",
    
    y="Casos"
    
  )

g3

ggsave(
  
  "figures/grafico03_grupo_edad.png",
  
  g3,
  
  width=8,
  
  height=6,
  
  dpi=300
  
)

#---------------------------------------------------------
# GRÁFICO 4
# Composición por sexo
#---------------------------------------------------------

g4 <- ggplot(
  
  sexo_tabla,
  
  aes(
    
    x="",
    
    y=n,
    
    fill=sexo
    
  )
  
)+
  
  geom_col(width=1)+
  
  coord_polar("y")+
  
  labs(
    
    title="Distribución porcentual por sexo"
    
  )+
  
  theme(
    
    axis.title=element_blank(),
    
    axis.text=element_blank(),
    
    axis.ticks=element_blank()
    
  )

g4

ggsave(
  
  "figures/grafico04_sexo.png",
  
  g4,
  
  width=7,
  
  height=7,
  
  dpi=300
  
)

#---------------------------------------------------------
# GRÁFICO 5
# Heatmap departamento × año
#---------------------------------------------------------

top6 <- df %>%
  
  count(departamento,sort=TRUE)%>%
  
  slice_head(n=6)%>%
  
  pull(departamento)

heatmap <- df %>%
  
  filter(departamento %in% top6)%>%
  
  count(departamento,ano)

g5 <- ggplot(
  
  heatmap,
  
  aes(
    
    factor(ano),
    
    departamento,
    
    fill=n
    
  )
  
)+
  
  geom_tile(color="white")+
  
  labs(
    
    title="Mapa de calor",
    
    subtitle="Casos por departamento y año",
    
    x="Año",
    
    y="Departamento",
    
    fill="Casos"
    
  )

g5

ggsave(
  
  "figures/grafico05_heatmap.png",
  
  g5,
  
  width=11,
  
  height=6,
  
  dpi=300
  
)

#---------------------------------------------------------
# GRÁFICO 6
# Boxplot edad según sexo
#---------------------------------------------------------

g6 <- ggplot(
  
  df,
  
  aes(
    
    sexo,
    
    edad,
    
    fill=sexo
    
  )
  
)+
  
  geom_boxplot(alpha=.8)+
  
  labs(
    
    title="Distribución de edad según sexo",
    
    x="Sexo",
    
    y="Edad"
    
  )

g6

ggsave(
  
  "figures/grafico06_boxplot.png",
  
  g6,
  
  width=8,
  
  height=6,
  
  dpi=300
  
)

#---------------------------------------------------------
# GRÁFICO 7
# Histograma de edades
#---------------------------------------------------------

g7 <- ggplot(
  
  df,
  
  aes(
    
    edad,
    
    fill=sexo
    
  )
  
)+
  
  geom_histogram(
    
    binwidth=5,
    
    alpha=.6,
    
    position="identity"
    
  )+
  
  labs(
    
    title="Distribución de edades",
    
    x="Edad",
    
    y="Frecuencia"
    
  )

g7

ggsave(
  
  "figures/grafico07_histograma.png",
  
  g7,
  
  width=10,
  
  height=6,
  
  dpi=300
  
)

#---------------------------------------------------------
# GRÁFICO 8
# Gráfico para LinkedIn
#---------------------------------------------------------

g8 <- ggplot(
  
  casos_anio,
  
  aes(
    
    ano,
    
    n
    
  )
  
)+
  
  geom_line(
    
    linewidth=1.5,
    
    color="#1565C0"
    
  )+
  
  geom_point(
    
    size=3,
    
    color="#D32F2F"
    
  )+
  
  geom_smooth(
    
    method="lm",
    
    se=FALSE,
    
    linetype=2,
    
    color="black"
    
  )+
  
  labs(
    
    title="Evolución temporal de los casos de dengue",
    
    subtitle="Proyecto Final - Análisis Exploratorio de Datos",
    
    x="Año",
    
    y="Número de casos"
    
  )

g8

ggsave(
  
  "figures/grafico_linkedin.png",
  
  g8,
  
  width=10,
  
  height=6,
  
  dpi=300
  
)

#=========================================================
# COLLAGE FINAL
#=========================================================

collage_final <-
  
  (g1 | g2) /
  
  (g3 | g5) /
  
  (g6 | g8)

collage_final

ggsave(
  
  "figures/collage_analisis_final.png",
  
  collage_final,
  
  width=18,
  
  height=16,
  
  dpi=300
  
)

cat("\n")
cat("=======================================\n")
cat("GRÁFICOS GENERADOS CORRECTAMENTE\n")
cat("=======================================\n")

list.files("figures")
#=========================================================
# 22. ANÁLISIS DE CORRELACIÓN
#=========================================================

cat("\n")
cat("=========================================\n")
cat("ANÁLISIS DE CORRELACIÓN\n")
cat("=========================================\n")

casos_anio <- df %>%
  count(ano, name = "casos")

correlacion <- cor(
  casos_anio$ano,
  casos_anio$casos,
  use = "complete.obs"
)

cat("Coeficiente de correlación =", round(correlacion,3),"\n")

#---------------------------------------------------------
# Interpretación automática
#---------------------------------------------------------

if(correlacion > 0.70){
  
  cat("Existe una correlación positiva fuerte entre el año y el número de casos.\n")
  
}else if(correlacion > 0.30){
  
  cat("Existe una correlación positiva moderada.\n")
  
}else if(correlacion > -0.30){
  
  cat("La relación lineal es débil o prácticamente inexistente.\n")
  
}else{
  
  cat("Existe una correlación negativa.\n")
  
}

#=========================================================
# 23. INDICADORES GENERALES
#=========================================================

indicadores <- tibble(
  
  Indicador=c(
    
    "Total de registros",
    
    "Edad promedio",
    
    "Edad mediana",
    
    "Edad mínima",
    
    "Edad máxima",
    
    "Número de departamentos",
    
    "Número de provincias",
    
    "Número de años analizados"
    
  ),
  
  Valor=c(
    
    nrow(df),
    
    round(mean(df$edad),2),
    
    median(df$edad),
    
    min(df$edad),
    
    max(df$edad),
    
    n_distinct(df$departamento),
    
    n_distinct(df$provincia),
    
    n_distinct(df$ano)
    
  )
  
)

indicadores

#=========================================================
# 24. RESPUESTA A LA PREGUNTA DE INVESTIGACIÓN
#=========================================================

cat("\n")
cat("=========================================\n")
cat("RESPUESTA A LA PREGUNTA DE INVESTIGACIÓN\n")
cat("=========================================\n\n")

cat("El análisis descriptivo evidencia que los casos de dengue\n")
cat("no se distribuyen de manera uniforme entre los años,\n")
cat("los departamentos y los grupos etarios.\n\n")

cat("Los departamentos con mayor concentración de casos\n")
cat("representan una proporción importante del total de registros,\n")
cat("lo que sugiere diferencias geográficas importantes.\n\n")

cat("Asimismo, la población adulta concentra la mayor cantidad\n")
cat("de casos reportados, mientras que hombres y mujeres\n")
cat("presentan comportamientos relativamente similares.\n\n")

cat("La evolución temporal permite identificar años donde\n")
cat("la incidencia aumenta considerablemente, reflejando\n")
cat("la naturaleza cambiante de los brotes epidemiológicos.\n")

#=========================================================
# 25. HALLAZGOS PRINCIPALES
#=========================================================

hallazgos <- c(
  
  "Los casos presentan una distribución desigual entre departamentos.",
  
  "Existen años con incrementos importantes de registros.",
  
  "La población adulta concentra la mayor cantidad de casos.",
  
  "No se observan diferencias extremas entre hombres y mujeres.",
  
  "La edad constituye una variable importante para caracterizar a los pacientes.",
  
  "El análisis gráfico facilita la identificación de patrones espaciales y temporales."
  
)

hallazgos

#=========================================================
# 26. EXPORTAR TABLAS
#=========================================================

write.csv(
  
  sexo_tabla,
  
  "figures/tabla_sexo.csv",
  
  row.names=FALSE
  
)

write.csv(
  
  edad_tabla,
  
  "figures/tabla_grupo_edad.csv",
  
  row.names=FALSE
  
)

write.csv(
  
  casos_anio,
  
  "figures/tabla_casos_anio.csv",
  
  row.names=FALSE
  
)

write.csv(
  
  top10_departamentos,
  
  "figures/tabla_departamentos.csv",
  
  row.names=FALSE
  
)

write.csv(
  
  indicadores,
  
  "figures/indicadores_generales.csv",
  
  row.names=FALSE
  
)

#=========================================================
# 27. CONCLUSIONES FINALES
#=========================================================

cat("\n")
cat("=========================================\n")
cat("CONCLUSIONES\n")
cat("=========================================\n\n")

cat("1. El análisis exploratorio permitió identificar una distribución heterogénea de los casos de dengue entre los departamentos del Perú.\n\n")

cat("2. La evolución temporal evidencia que existen periodos con incrementos importantes de registros, indicando variaciones en la incidencia de la enfermedad.\n\n")

cat("3. La población adulta concentra la mayor proporción de casos registrados, constituyendo el grupo etario predominante.\n\n")

cat("4. La distribución por sexo muestra diferencias poco marcadas, lo que sugiere una afectación relativamente similar entre hombres y mujeres.\n\n")

cat("5. Las visualizaciones desarrolladas permitieron identificar patrones espaciales y temporales útiles para comprender el comportamiento epidemiológico del dengue.\n\n")

cat("6. Los resultados obtenidos demuestran la utilidad del análisis exploratorio de datos como herramienta para apoyar la toma de decisiones en salud pública.\n")

#=========================================================
# 28. MENSAJE FINAL
#=========================================================

cat("\n")
cat("=========================================\n")
cat("PROYECTO FINAL EJECUTADO CORRECTAMENTE\n")
cat("=========================================\n")

cat("Se generaron correctamente:\n\n")

cat("- Gráficos profesionales.\n")
cat("- Tablas resumen.\n")
cat("- Indicadores descriptivos.\n")
cat("- Conclusiones del análisis.\n")
cat("- Archivos CSV para documentación.\n")

cat("\n")

print("FIN DEL PROYECTO")