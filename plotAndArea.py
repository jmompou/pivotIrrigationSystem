import matplotlib.pyplot as plt

def polygon_area(points):
    n = len(points)
    area = 0.0
    for i in range(n):
        j = (i + 1) % n
        area += points[i][0] * points[j][1]
        area -= points[j][0] * points[i][1]
    area = abs(area) / 2.0
    return area

# Definición de los puntos del polígono
points = [
    (603.87, 818.61),
    (815.278331884383, -78.1577178120667),
    (1153.93768246152, -306.233876729812),
    (1217.91340197405, -501.500713936887),
    (1345.09929959985, -514.216839334081),
    (1541.62559760689, -645.224969965924),
    (1568.74455508656, -714.989464124598),
    (1998.37685984082, -879.35516222352),
    (2192.07767156003, -954.122885469045),
    (2309.81747534986, -975.807373093402),
    (2716.23561010679, -664.015587857317),
    (1133.97751131438, 559.282948398585)
]

# Creación de la figura y los ejes
fig, ax = plt.subplots()

# Graficar cada línea usando los puntos de inicio y final
n = len(points)
for i in range(n):
    start_point = points[i]
    end_point = points[(i + 1) % n]
    x_values = [start_point[0], end_point[0]]
    y_values = [start_point[1], end_point[1]]
    ax.plot(x_values, y_values, label=f"L{i+1}")

# Calcular el área del polígono
area = polygon_area(points)
print(f"Área del polígono: {area} unidades cuadradas")

# Agregar leyenda y mostrar la gráfica
ax.legend()
plt.show()

