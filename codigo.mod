#--PARAMETERS AND SETS--------------------------

param num_pivots;								#maximum number of pivots you should try to put


set PIVOTS := {1..num_pivots};

set SIZES;
set EXTRA_SIZES within SIZES;					#possible sizes of the last section

set POLY;										#set of polygons that form the surface
set LINES_POLY{POLY};							#edges that form each plygon
set SEGMENTS;

param x1_lines{i in POLY, j in LINES_POLY[i]};  #(x1,y1),(x2,y2) are the points that form a polygon edge
param y1_lines{i in POLY, j in LINES_POLY[i]};
param x2_lines{i in POLY, j in LINES_POLY[i]};
param y2_lines{i in POLY, j in LINES_POLY[i]};

param x1{SEGMENTS};
param y1{SEGMENTS};
param x2{SEGMENTS};
param y2{SEGMENTS};

param UB := 100;								#upper bound to the number of section a pivot can have
param max_length;

param coverage_cost;
param initial_cost;
param cost{SIZES};								#cost of each section size
param parcel_area;

#--DECISION VARIABLES---------------------------
var x{PIVOTS};									#(x,y) = center pivot 
var y{PIVOTS};
var numSec{PIVOTS,SIZES} >= 0 integer;			#it counts the number of sections of each size

#--AUXILIAR VARIABLES---------------------------
var hasSize{PIVOTS,SIZES} binary;				#mark whether a certain size is used in a pivot
var extraSize{PIVOTS, EXTRA_SIZES} binary;		#marks whether a pivot has extra size
var length{PIVOTS} >= 0;						#total size of the pivot
var length2{PIVOTS} >= 0;						#square of total size of the pivot
var exist{PIVOTS} binary;						#marks whether a pivot exists

var insidePolygon{PIVOTS, POLY} binary;			#mark whether a pivot is inside the polygon
var t{PIVOTS, SEGMENTS};						#scalar t that appears in the calculation of the projection of the center (x,y), to a line given by the points (x1, y1), (x2, y2)
var distSeg{PIVOTS, SEGMENTS} >= 0;				
var scenDistSeg{PIVOTS, SEGMENTS, 1..3} binary;


#--FUNCION OBJETIVO--------------------------------

# We want to minimize the cost of installing the pivots (first line)
# and the cost of covering the area not covered by the pivots by coverage irrigation (second line)

minimize objective: ((sum{i in PIVOTS} (initial_cost*exist[i] + (sum{j in SIZES} cost[j]*numSec[i,j]) + (sum{j in EXTRA_SIZES} cost[j]*extraSize[i,j]))))*10
		+ ((parcel_area - 3.14*(sum{i in PIVOTS} length2[i]))* coverage_cost)*10;


#what we want to obtain is how many pivots,
# where to place them and with how many sections and what sizes


#--CONSTRAINTS----------------------------------------

# the pivot must be placed in one of the polygons (second constraint) 
# and must be inside it (first constraint) 

s.t. Inside_Polygon{i in PIVOTS, j in POLY, k in LINES_POLY[j]}:
	insidePolygon[i,j]*((x2_lines[j,k]-x1_lines[j,k])*(y1_lines[j,k]-y[i]) - (x1_lines[j,k]-x[i])*(y2_lines[j,k]-y1_lines[j,k])) >= 0;



s.t. Inside_Some_Polygon{i in PIVOTS}: sum{j in POLY} insidePolygon[i,j] >= 1;

	
# must not concern the edges (first constraint) and 
# cannot collide with another pivot when turning (second)

s.t. Far_Borders{i in PIVOTS, j in SEGMENTS}:
	distSeg[i,j] >= length2[i];
		
s.t. Far_Between{(i,j) in PIVOTS cross PIVOTS: i < j}:
	(x[i] - x[j])^2 + (y[i] - y[j])^2 >= (length[i] + length[j])^2;



# makes sure that the variable hasSize has the correct value (first),
# no more than 1 section length (second),at least only 1 extraSize to be used (third)

s.t. Has_Size{i in PIVOTS, j in SIZES}:
	numSec[i,j] <= hasSize[i,j]*UB;

s.t. Single_Pivot_Section_Size{i in PIVOTS}:
	sum{j in SIZES} hasSize[i,j] <= 1;

s.t. Single_Extra_Size{i in PIVOTS}: sum{j in EXTRA_SIZES} extraSize[i,j] <= sum{k in SIZES diff EXTRA_SIZES} hasSize[i,k];

s.t. Calculating_Length{i in PIVOTS}:
	length[i] = ((sum{k in EXTRA_SIZES} k*extraSize[i,k]) + (sum{j in SIZES} j*numSec[i,j]));

s.t. Calculating_Length2{i in PIVOTS}:
	length2[i] = length[i]^2;


# force a maximum length for eachpivot	

s.t. Pivot_Exists{i in PIVOTS}:
	length[i] <= max_length*exist[i];



# we calculate the projection of the center of the pivot to the edges of the polygon and obtain the scalar t that appears,
# it will help us to calculate the distance from the center to the edge

s.t. Calculating_T{i in PIVOTS,j in SEGMENTS}:
	((x[i]-x2[j])*(x1[j]-x2[j])+(y[i]-y2[j])*(y1[j]-y2[j]))/((x2[j]-x1[j])^2 + (y2[j]-y1[j])^2) = t[i,j];


# calculate the distance according to the case in which we find ourselves		
		# Objetivo T < 0 => distSeg = dist((x,y),(x2,y2))

s.t. T_Less_0{i in PIVOTS, j in SEGMENTS}:
	scenDistSeg[i,j,1]*t[i,j] <= 0;

s.t. Calculating_Distance_Seg_1{i in PIVOTS, j in SEGMENTS}:
	scenDistSeg[i,j,1]*((x[i]-x2[j])^2 + (y[i]-y2[j])^2 ) = scenDistSeg[i,j,1]*distSeg[i,j];


		# Objetivo 0 < T < 1 => distSeg = distLine

s.t. T_Greater_0{i in PIVOTS, j in SEGMENTS}:
	scenDistSeg[i,j,2]*t[i,j] >= 0;

s.t. T_Less_1{i in PIVOTS, j in SEGMENTS}:
	scenDistSeg[i,j,2]*(t[i,j]-1) <= 0;

s.t. Calculating_Distance_Seg_2{i in PIVOTS, j in SEGMENTS}:
	scenDistSeg[i,j,2]*((x2[j]-x1[j])*(y1[j]-y[i]) - (x1[j]-x[i])*(y2[j]-y1[j]))^2 /
	((x2[j]-x1[j])^2 + (y2[j]-y1[j])^2) = scenDistSeg[i,j,2]*distSeg[i,j];
	
		# Objetivo T > 1 => distSeg = dist((x,y),(x1,y1))
		
s.t. T_Grater_1{i in PIVOTS, j in SEGMENTS}:
	scenDistSeg[i,j,3]*(t[i,j]-1) >= 0;

s.t. Calculating_Distance_Seg_3{i in PIVOTS, j in SEGMENTS}:
	scenDistSeg[i,j,3]*((x[i]-x1[j])^2 + (y[i]-y1[j])^2 ) = scenDistSeg[i,j,3]*distSeg[i,j];

s.t. In_Some_Scenario{i in PIVOTS, j in SEGMENTS}:
	scenDistSeg[i,j,1]+scenDistSeg[i,j,2]+scenDistSeg[i,j,3] = 1;