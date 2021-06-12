/*********************************************************************************
 _____ ____  _____ 
|  _  |    \|   __|
|     |  |  |   __|
|__|__|____/|__|   
ARMA Mission Development Framework
ADF version: 2.26 / Jul 2020

Function: XXXXXXXXXXXXXXXXXXXXXXXXXXX
Author: Whiztler
Script version: XXXX

File: XXXXXXXXXXXXXXXXXXXXXXXXXXX
**********************************************************************************
ABOUT
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

INSTRUCTIONS:
Execute (call) from the server or HC

REQUIRED PARAMETERS:
0. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX

OPTIONAL PARAMETERS:
1. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX        
2. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX        
3. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX        
4. XXXXXX:      XXXXXXXXXXXXXXXXXXXXXXXXXXX        

EXAMPLES USAGE IN SCRIPT:
XXXXXXXXXXXXXXXXXXXXXXXXXXX

EXAMPLES USAGE IN EDEN:
XXXXXXXXXXXXXXXXXXXXXXXXXXX

DEFAULT/MINIMUM OPTIONS
XXXXXXXXXXXXXXXXXXXXXXXXXXX

RETURNS:
Bool (success flag)
*********************************************************************************/



/*
5. String:      Code to execute on each unit of the crew (e.g. a function).
                Default = "". Code is CALLED. Each unit of the group is passed
                (_this select 0) to the code/fnc.
6. String:      Code to execute on the crew aa a group (e.g. a function).
                Default = "". Code is CALLED. The group is passed
                (_this select 0) to the code/fnc.      
				
				
Spawn position. Marker, object, trigger or position array [x,y,z]


RETURNS:
Array:          0. new vehicle (Object).
                1. all crew (Array of Objects).
                2. vehicle's group (Group).
				
RETURNS:
Array:          0.  position X
                1.  position y
                2.  position Z
				
				
REQUIRED PARAMETERS:
0. Group:       Group (aircraft crew)
1. position:    Center patrol start position. Marker, object, trigger or position
                array [x,y,z]

OPTIONAL PARAMETERS:
2. Number:      Waypoint radius in meters. Default: 500 
3. Number:      Number of total waypoints to patrol. Default: 4
4. String:      Waypoint type. Default: "MOVE"
                Info: https:community.bistudio.com/wiki/Waypoint_types
5. String:      Waypoint behaviour. Default: "SAFE"
                Info: https:community.bistudio.com/wiki/setWaypointBehaviour                
6. String:      Waypoint combat mode. Default: "WHITE"
                Info: https:community.bistudio.com/wiki/setWaypointCombatMode
7. String:      Waypoint speed. Default: "LIMITED"
                Info: https:community.bistudio.com/wiki/waypointSpeed
8. String:      Waypoint formation. Default: "FILE"
                Info: https:community.bistudio.com/wiki/waypointFormation
9. Number:      Waypoint completion radius in meters. Default: 5
                Info: https:community.bistudio.com/wiki/setWaypointCompletionRadius
10. Bool        Search buildings: 
                - true: Search buildings within a 50 meter radius upon waypoint
                  completion.
                - false: Do not search buildings (default)