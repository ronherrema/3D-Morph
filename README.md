# 3D-Morph

Uses Processing to compare two 3D (stl) files and morph one in the direction of the other, by separating the 3D space into octants and comparing each vector of that object's octant to those of the other object, then moving incrementally towards the closest one. Saves the incremented object files each time the program is run, thus (ideally) requiring an automated running of the program. 

Requires the Hemesh Processing library.
