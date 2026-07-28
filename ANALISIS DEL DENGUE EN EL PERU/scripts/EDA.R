
# ============================================
# EDA - Vigilancia Epidemiologica de Dengue
# Fuente: MINSA / Plataforma Nacional de Datos Abiertos
# ============================================

library(tidyverse)
library(janitor)
library(patchwork)

setwd("~/STATA")
dir.create("data", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
dir.create("scripts", showWarnings = FALSE)

# --- 1. IMPORTACION ---
df <- read_delim("Proyecto_Final.csv", delim = ";", locale = locale(encoding = "Latin1"))
glimpse(df)

# --- 2. LIMPIEZA Y PREPARACION ---
df <- df %>%
  clean_names() %>%
  distinct() %>%
  mutate(edad = as.numeric(edad)) %>%
  filter(!is.na(edad), edad >= 0, edad <= 120)

df <- df %>%
  mutate(grupo_edad = case_when(
    edad < 18 ~ "Menor de edad",
    edad >= 18 & edad < 60 ~ "Adulto",
    edad >= 60 ~ "Adulto mayor",
    TRUE ~ "Sin dato"
  ))

# --- 3. ESTADISTICAS DESCRIPTIVAS ---
summary(df$edad)

df %>% count(departamento, sort = TRUE) %>% head(10)
df %>% count(sexo)
df %>% count(diagnostic, sort = TRUE)

# --- 4. VISUALIZACIONES ---
top_departamentos <- df %>% count(departamento, sort = TRUE) %>% slice_head(n = 10)

g1 <- ggplot(top_departamentos, aes(x = reorder(departamento, n), y = n)) +
  geom_col(fill = "#2c7fb8") +
  coord_flip() +
  labs(
    title = "Top 10 departamentos con mas casos de dengue",
    subtitle = "Numero de registros por departamento",
    x = "Departamento", y = "N° de casos"
  ) +
  theme_minimal()

g2 <- ggplot(df, aes(x = edad, fill = sexo)) +
  geom_histogram(binwidth = 5, position = "identity", alpha = 0.6) +
  labs(
    title = "Distribucion de edad de los casos segun sexo",
    subtitle = "Histograma comparativo",
    x = "Edad", y = "Frecuencia", fill = "Sexo"
  ) +
  theme_minimal()

g1
g2

# --- 5. COLLAGE Y GUARDADO ---
collage <- g1 + g2
ggsave("figures/collage_graficos.png", collage, width = 12, height = 6, dpi = 300)

print("LISTO. Revisa la carpeta figures para el collage.")

# --- 3. ESTADISTICAS DESCRIPTIVAS (version ampliada) ---
df %>%
  summarise(
    n_casos = n(),
    edad_media = mean(edad, na.rm = TRUE),
    edad_mediana = median(edad, na.rm = TRUE),
    edad_min = min(edad, na.rm = TRUE),
    edad_max = max(edad, na.rm = TRUE),
    edad_sd = sd(edad, na.rm = TRUE)
  )

# Casos por año
df %>% count(ano, sort = TRUE)

# Casos por grupo etario
df %>% count(grupo_edad, sort = TRUE)

# Proporcion por sexo
df %>% count(sexo) %>% mutate(porcentaje = round(n/sum(n)*100, 1))

g3 <- df %>%
  count(ano) %>%
  ggplot(aes(x = factor(ano), y = n)) +
  geom_col(fill = "#31a354") +
  labs(
    title = "Casos de dengue reportados por año",
    subtitle = "Evolucion temporal de los registros",
    x = "Año", y = "N° de casos"
  ) +
  theme_minimal()
g3

collage <- g1 + g2 + g3
ggsave("figures/collage_graficos.png", collage, width = 16, height = 6, dpi = 300)

g9 <- df %>%
  count(departamento, ano) %>%
  filter(departamento %in% (df %>% count(departamento, sort = TRUE) %>% slice_head(n=8) %>% pull(departamento))) %>%
  ggplot(aes(x = factor(ano), y = departamento, fill = n)) +
  geom_tile() +
  scale_fill_gradient(low = "#fee5d9", high = "#a50f15") +
  labs(
    title = "Mapa de calor: casos por departamento y año",
    subtitle = "Top 8 departamentos con mas casos",
    x = "Año", y = "Departamento", fill = "N° casos"
  ) +
  theme_minimal()
g9

g10 <- df %>%
  count(grupo_edad, sexo) %>%
  ggplot(aes(x = grupo_edad, y = n, fill = sexo)) +
  geom_col(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Composicion por sexo dentro de cada grupo etario",
    subtitle = "Proporcion relativa (100% apilado)",
    x = "Grupo etario", y = "Porcentaje", fill = "Sexo"
  ) +
  theme_minimal()
g10

g11 <- df %>%
  count(provincia, sort = TRUE) %>%
  slice_head(n = 10) %>%
  ggplot(aes(x = reorder(provincia, n), y = n)) +
  geom_col(fill = "#3182bd") +
  coord_flip() +
  labs(
    title = "Top 10 provincias con mas casos de dengue",
    subtitle = "Nivel de detalle mas fino que departamento",
    x = "Provincia", y = "N° de casos"
  ) +
  theme_minimal()
g11


g12 <- df %>%
  count(ano, sexo) %>%
  ggplot(aes(x = ano, y = n, color = sexo)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(
    title = "Evolucion de casos por año, segun sexo",
    subtitle = "Comparacion de tendencias 2000-2024",
    x = "Año", y = "N° de casos", color = "Sexo"
  ) +
  theme_minimal()
g12

g13 <- ggplot(df, aes(x = edad, fill = grupo_edad)) +
  geom_density(alpha = 0.5) +
  labs(
    title = "Densidad de la distribucion de edad",
    subtitle = "Curvas suavizadas por grupo etario",
    x = "Edad", y = "Densidad", fill = "Grupo etario"
  ) +
  theme_minimal()
g13


top6 <- df %>% count(departamento, sort = TRUE) %>% slice_head(n = 6) %>% pull(departamento)
top6 <- df %>% count(departamento, sort = TRUE) %>% slice_head(n = 6) %>% pull(departamento)

g_box1 <- df %>%
  filter(departamento %in% top6) %>%
  ggplot(aes(x = reorder(departamento, edad, median), y = edad, fill = departamento)) +
  geom_boxplot(outlier.alpha = 0.2) +
  coord_flip() +
  labs(
    title = "Distribucion de edad por departamento",
    subtitle = "Top 6 departamentos con mas casos - mediana, cuartiles y outliers",
    x = "Departamento", y = "Edad", fill = "Departamento"
  ) +
  theme_minimal()
g_box1

g_box2 <- ggplot(df, aes(x = sexo, y = edad, fill = sexo)) +
  geom_boxplot(outlier.alpha = 0.2) +
  labs(
    title = "Distribucion de edad segun sexo",
    subtitle = "Comparacion de mediana, dispersion y valores atipicos",
    x = "Sexo", y = "Edad", fill = "Sexo"
  ) +
  theme_minimal()
g_box2


g_box3 <- df %>%
  filter(ano >= 2018) %>%
  ggplot(aes(x = factor(ano), y = edad)) +
  geom_boxplot(fill = "#74c476", outlier.alpha = 0.2) +
  labs(
    title = "Distribucion de edad por año",
    subtitle = "Ultimos años - evolucion del perfil etario",
    x = "Año", y = "Edad"
  ) +
  theme_minimal()
g_box3


casos_por_anio <- df %>% count(ano, name = "n_casos")

correlacion <- cor(casos_por_anio$ano, casos_por_anio$n_casos)
print(paste("Correlacion Año vs N° de casos:", round(correlacion, 3)))

g_scatter1 <- ggplot(casos_por_anio, aes(x = ano, y = n_casos)) +
  geom_point(color = "#2b8cbe", size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "#e34a33") +
  labs(
    title = "Correlacion entre año y numero de casos",
    subtitle = paste("Coeficiente de correlacion (r) =", round(correlacion, 3)),
    x = "Año", y = "N° de casos"
  ) +
  theme_minimal()
g_scatter1


casos_por_semana <- df %>% count(semana, name = "n_casos")
correlacion2 <- cor(casos_por_semana$semana, casos_por_semana$n_casos)

g_scatter2 <- ggplot(casos_por_semana, aes(x = semana, y = n_casos)) +
  geom_point(color = "#756bb1", alpha = 0.7) +
  geom_smooth(method = "loess", se = FALSE, color = "#e34a33") +
  labs(
    title = "Relacion entre semana epidemiologica y numero de casos",
    subtitle = paste("Coeficiente de correlacion (r) =", round(correlacion2, 3)),
    x = "Semana epidemiologica", y = "N° de casos"
  ) +
  theme_minimal()
g_scatter2


top6 <- df %>% count(departamento, sort = TRUE) %>% slice_head(n = 6) %>% pull(departamento)

g_box1 <- df %>%
  filter(departamento %in% top6) %>%
  ggplot(aes(x = reorder(departamento, edad, median), y = edad, fill = departamento)) +
  geom_boxplot(outlier.alpha = 0.2) +
  coord_flip() +
  labs(
    title = "Distribucion de edad por departamento",
    subtitle = "Top 6 departamentos con mas casos",
    x = "Departamento", y = "Edad", fill = "Departamento"
  ) +
  theme_minimal()
g_box1

g_box2 <- ggplot(df, aes(x = sexo, y = edad, fill = sexo)) +
  geom_boxplot(outlier.alpha = 0.2) +
  labs(
    title = "Distribucion de edad segun sexo",
    subtitle = "Comparacion de mediana, dispersion y valores atipicos",
    x = "Sexo", y = "Edad", fill = "Sexo"
  ) +
  theme_minimal()
g_box2

collage_final <- g_box1 + g_box2 + g_scatter1 + plot_layout(ncol = 2)
ggsave("figures/collage_graficos.png", collage_final, width = 14, height = 10, dpi = 300)
collage_final

list.files("scripts")

save.image("~/STATA/mi_sesion.RData")


dir.create("~/STATA/figures", showWarnings = FALSE, recursive = TRUE)
setwd("~/STATA")

ggsave("figures/01_top_departamentos.png", g1, width = 8, height = 5, dpi = 300)
ggsave("figures/02_histograma_edad_sexo.png", g2, width = 8, height = 5, dpi = 300)
ggsave("figures/03_boxplot_edad_departamento.png", g_box1, width = 8, height = 5, dpi = 300)
ggsave("figures/04_boxplot_edad_sexo.png", g_box2, width = 8, height = 5, dpi = 300)
ggsave("figures/05_correlacion_anio_casos.png", g_scatter1, width = 8, height = 5, dpi = 300)
ggsave("figures/collage_graficos.png", collage_final, width = 14, height = 10, dpi = 300)