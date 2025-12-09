# 🌾 Irrigation Optimization Project (MINLP)

This repository contains the Python and AMPL implementations of a complex **Mixed-Integer Nonlinear Programming (MINLP)** model. The project’s core function is to find the optimal arrangement and size of center pivot irrigation systems on irregularly shaped farm parcels to **minimize total cost** (installation + coverage) while **maximizing the irrigated area**.

---

## 🏛️ Authorship and Project Origin

This work is a **translation and adaptation into Python** of a university project originally developed using the **AMPL modeling language**, but the original AMPL code is hereby provided too.

| Role | Name |
| :--- | :--- |
| **Original Authors** | Ana Clemente Pérez, Jorge Ibáñez Puertas, Nicolás Colchero Truniger |
| **Institution** | Universidad de Murcia, Faculty of Mathematics |
| **Context** | The original project aimed to determine the optimal pivot distribution for Explotación Agraria Puertas SL. |

The goal of this Python version, which utilizes the `amplpy` library, is to enhance accessibility and integration with modern data science tools.

---

## 🎯 Methodology and Model Overview

The model is formulated as an MINLP problem due to its non-linear geometric constraints and the use of discrete (integer and binary) variables.

### Objective Function
The objective is to minimize the total cost of irrigation:
$$\min \left[ \sum_{i \in \text{PIVOTS}} (\text{Initial\_Cost} + \text{Section\_Costs})_i \right] + (\text{Parcel\_Area} - \sum \text{Pivot\_Area}) \times \text{Coverage\_Cost}$$

### Key Constraints
* **Geometric Feasibility:** Ensures the pivot's circular area is entirely contained within the irregular farm boundary.
* **Non-Collision:** Guarantees that the circles of two different pivots do not overlap.
* **Structural Limits:** Limits the maximum pivot radius to 800 meters.
* **Discrete Sizing:** Defines the pivot's radius using only available standard section lengths.

### Solver
The model is executed using the **Gurobi solver** configured for non-convex problems (`NonConvex=2`).

---

## 🛠️ Data Input Guide: Mapping a Farm Parcel

The entire geometrical and economic definition of the problem is contained within the `DATA_CODE` variable (which holds the original AMPL `.dat` content). To use the model for a **new parcel**, you must update these parameters.

### 1. Mapping and Coordinate Acquisition

The model requires $2D$ coordinates representing **real physical distances** (in meters) for the farm's boundary.

* **A. Identify Vertices:** Define the corners (vertices) of your farm's boundary.
* **B. Scale Coordinates:** Use GIS tools or surveying data to ensure the coordinates are scaled so that the geometric distance between points matches the **actual measured distances** in meters (e.g., from a tool like `sigpac.jccm.es`).
* **C. Order Vertices:** Vertices must be listed in a **consistent sequential order** (e.g., clockwise).

### 2. Updating the `DATA_CODE`

Modify the following sections within the `DATA_CODE` string:

#### A. General Parameters

| Parameter | Purpose | Example |
| :--- | :--- | :--- |
| `param num_pivots:` | Max pivots to test. | `param num_pivots: 3;` |
| `param parcel_area:` | Total area of the defined polygon (in $m^2$). | `param parcel_area: 1458888.8282936495;` |
| `param SIZES cost := ...` | Update the table with current market prices for each available pivot section length. | `49 13500` |

#### B. Geometric Coordinates

You must update the coordinates in two key sections:

| Section | Purpose | Data Required |
| :--- | :--- | :--- |
| **`param: x1_lines...`** | **Center Inclusion:** Defines the lines of the convex polygons (`P1`, `P2`, etc.) that form the farm. This ensures the pivot center is inside the farm. | The sequence of $(x_1, y_1)$ to $(x_2, y_2)$ coordinates for each line boundary. |
| **`param: SEGMENTS...`** | **Full Coverage Inclusion:** Defines all the segments of the **outer perimeter**. This set ensures the entire circular area of the pivot stays within the farm's limits. | The sequence of $(x_1, y_1)$ to $(x_2, y_2)$ coordinates for the outer boundary. |

### 3. Interpreting the Output

The Python script output will provide the optimal solution found by the solver:
* **Optimal Cost:** The minimum total cost.
* **Pivot Location:** The precise center coordinates $(x, y)$ for each installed pivot.
* **Pivot Size:** The total length (`length`) and the exact breakdown of sections required for its construction.
