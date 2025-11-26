# pivotIrrigationSystem
This project optimizes pivot irrigation distribution on a 145.88ha farm (Explotación Agraria Puertas SL) to minimize total cost (pivots + sprinkler) and maximize coverage within irregular boundaries.  It used an MINLP model (AMPL/Gurobi) with geometric constraints (no overlap, 800m max radius). Result: The current 3-pivot layout is optimal.

# 🌾 Irrigation Optimization Project (MINLP)

This repository contains the Python implementation of a complex **Mixed-Integer Nonlinear Programming (MINLP)** model. The project’s core function is to find the optimal arrangement and size of center pivot irrigation systems on irregularly shaped farm parcels to **minimize total cost** (installation + coverage) while **maximizing the irrigated area**.

---

## 🏛️ Authorship and Project Origin

[cite_start]This work is a **translation and adaptation into Python** of a university project originally developed using the **AMPL modeling language**[cite: 1044].

| Role | Name |
| :--- | :--- |
| **Original Authors** | [cite_start]Ana Clemente Pérez [cite: 10][cite_start], Jorge Ibáñez Puertas [cite: 10][cite_start], Nicolás Colchero Truniger [cite: 10] |
| **Institution** | [cite_start]Universidad de Murcia, Faculty of Mathematics [cite: 1, 13] |
| **Context** | [cite_start]The original project aimed to determine the optimal pivot distribution for Explotación Agraria Puertas SL[cite: 32]. |

[cite_start]The goal of this Python version, which utilizes the `amplpy` library, is to enhance accessibility and integration with modern data science tools[cite: 43].

---

## 🎯 Methodology and Model Overview

[cite_start]The model is formulated as an MINLP problem due to its non-linear geometric constraints and the use of discrete (integer and binary) variables[cite: 1190].

### Objective Function
[cite_start]The objective is to minimize the total cost of irrigation[cite: 663]:
$$\min \left[ \sum_{i \in \text{PIVOTS}} (\text{Initial\_Cost} + \text{Section\_Costs})_i \right] + (\text{Parcel\_Area} - \sum \text{Pivot\_Area}) \times \text{Coverage\_Cost}$$

### Key Constraints
* [cite_start]**Geometric Feasibility:** Ensures the pivot's circular area is entirely contained within the irregular farm boundary[cite: 572, 672].
* [cite_start]**Non-Collision:** Guarantees that the circles of two different pivots do not overlap[cite: 577].
* [cite_start]**Structural Limits:** Limits the maximum pivot radius to 800 meters[cite: 112].
* [cite_start]**Discrete Sizing:** Defines the pivot's radius using only available standard section lengths[cite: 110, 586].

### Solver
[cite_start]The model is executed using the **Gurobi solver** configured for non-convex problems (`NonConvex=2`)[cite: 1046].

---

## 🛠️ Data Input Guide: Mapping a Farm Parcel

The entire geometrical and economic definition of the problem is contained within the `DATA_CODE` variable (which holds the original AMPL `.dat` content). To use the model for a **new parcel**, you must update these parameters.

### 1. Mapping and Coordinate Acquisition

The model requires $2D$ coordinates representing **real physical distances** (in meters) for the farm's boundary.

* **A. Identify Vertices:** Define the corners (vertices) of your farm's boundary.
* **B. [cite_start]Scale Coordinates:** Use GIS tools or surveying data to ensure the coordinates are scaled so that the geometric distance between points matches the **actual measured distances** in meters (e.g., from a tool like `sigpac.jccm.es` [cite: 86]).
* **C. [cite_start]Order Vertices:** Vertices must be listed in a **consistent sequential order** (e.g., clockwise)[cite: 555].

### 2. Updating the `DATA_CODE`

Modify the following sections within the `DATA_CODE` string:

#### A. General Parameters

| Parameter | Purpose | Example |
| :--- | :--- | :--- |
| `param num_pivots:` | Max pivots to test. | `param num_pivots: 3;` |
| `param parcel_area:` | [cite_start]Total area of the defined polygon (in $m^2$)[cite: 480]. | `param parcel_area: 1458888.8282936495;` |
| `param SIZES cost := ...` | [cite_start]Update the table with current market prices for each available pivot section length[cite: 187]. | `49 13500` |

#### B. Geometric Coordinates

You must update the coordinates in two key sections:

| Section | Purpose | Data Required |
| :--- | :--- | :--- |
| **`param: x1_lines...`** | **Center Inclusion:** Defines the lines of the convex polygons (`P1`, `P2`, etc.) that form the farm. [cite_start]This ensures the pivot center is inside the farm[cite: 676]. | The sequence of $(x_1, y_1)$ to $(x_2, y_2)$ coordinates for each line boundary. |
| **`param: SEGMENTS...`** | **Full Coverage Inclusion:** Defines all the segments of the **outer perimeter**. [cite_start]This set ensures the entire circular area of the pivot stays within the farm's limits[cite: 679, 672]. | The sequence of $(x_1, y_1)$ to $(x_2, y_2)$ coordinates for the outer boundary. |

### 3. Interpreting the Output

The Python script output will provide the optimal solution found by the solver:
* **Optimal Cost:** The minimum total cost.
* **Pivot Location:** The precise center coordinates $(x, y)$ for each installed pivot.
* [cite_start]**Pivot Size:** The total length (`length`) and the exact breakdown of sections required for its construction[cite: 1056, 1059, 1062].
