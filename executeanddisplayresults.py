def execute_and_display_results():
    # Inicializar la instancia de AMPL
    ampl = AMPL()

    # Cargar el modelo y los datos
    ampl.eval(MODEL_CODE)
    ampl.eval(DATA_CODE)

    # Configurar el solver Gurobi y la opción de no convexidad (MINLP)
    ampl.option['solver'] = 'gurobi'
    ampl.option['gurobi_options'] = 'NonConvex=2'
    
    print("Iniciando la resolución del problema de optimización...")
    ampl.solve()

    # --- Mostrar Resultados (replicando la lógica de codigo.run) ---
    
    # Obtener el valor objetivo
    try:
        objective_value = ampl.getObjective('objective').value()
        print(f"\n✅ Solución Encontrada. Costo Total Mínimo: {objective_value:,.2f} €")
    except Exception as e:
        print(f"\n❌ Error al obtener el valor objetivo: {e}")
        return

    # Obtener conjuntos y variables
    pivots = ampl.getSet('PIVOTS').getValues()
    sizes = ampl.getSet('SIZES').getValues()
    extra_sizes = ampl.getSet('EXTRA_SIZES').getValues()
    
    # Obtener variables clave
    x = ampl.getVariable('x')
    y = ampl.getVariable('y')
    length = ampl.getVariable('length')
    exist = ampl.getVariable('exist')
    numSec = ampl.getVariable('numSec')
    extraSize = ampl.getVariable('extraSize')

    print("\n--- Detalles de la Distribución de Pivotes ---")
    pivots_found = 0
    
    for i in pivots:
        try:
            # Comprobar si el pivote existe (variable binaria 'exist' = 1)
            if exist[i].value() == 1:
                pivots_found += 1
                x_val = x[i].value()
                y_val = y[i].value()
                length_val = length[i].value()
                
                print(f"\n▶️ Pivote {pivots_found} (Índice {i}):")
                print(f"  Posición central (x, y): ({x_val:.4f}, {y_val:.4f})")
                print(f"  Longitud total del radio: {length_val:.2f} metros")
                
                # Mostrar secciones principales
                for j in sizes:
                    num_sec_val = numSec[i, j].value()
                    if num_sec_val > 0:
                        print(f"  - Secciones principales de {j}m: {num_sec_val:.0f}")
                        
                # Mostrar sección extra (si existe)
                for k in extra_sizes:
                    if extraSize[i, k].value() == 1:
                        print(f"  - Sección extra: 1 de {k}m")
        except Exception:
            # Manejar caso donde el solver no haya retornado valores para un pivote
            continue

    print("\n--- Tiempos de Ejecución ---")
    print(f"Tiempo de AMPL (ampl_time): {ampl.getValue('ampl_time'):.4f} segundos")
    print(f"Tiempo de solución (total_solve_time): {ampl.getValue('total_solve_time'):.4f} segundos")

# Ejecutar el proyecto completo
# execute_and_display_results()
