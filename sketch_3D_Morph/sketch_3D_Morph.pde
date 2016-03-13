// Compares two 3D (stl) files and morphs one in the direction of the other, by separating the 3D space into octants 
// and comparing each vector of that object's octant to those of the other object,
// then moving incrementally towards the closest one.
// Saves the incremented object files each time the program is run,
// thus (ideally) requiring an automated running of the program.
// Requires the Hemesh Processing library.

// Created by Ron Herrema, June 2015

import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;


HE_Mesh cone;
HE_Mesh utah;
HE_Mesh modifiedCone;
HE_Mesh modifiedUtah;
WB_Render render;

String countArray[] = loadStrings("count.txt"); // 
int picCount = int(countArray[0]) + 1; // next in sequence of images


void setup() {
  size(1200, 1200, P3D);
  smooth();
  background(255);

  HEC_FromBinarySTLFile teapot = new HEC_FromBinarySTLFile().setPath(sketchPath("data/conico_moved2.stl")).setScale(2);
  cone = new HE_Mesh(teapot);

  HEC_FromBinarySTLFile teapotUtah = new HEC_FromBinarySTLFile().setPath(sketchPath("data/utah_teapot.stl")).setScale(20);
  utah = new HE_Mesh(teapotUtah);

  //Export the faces and vertices
  float[][] vertices  = cone.getVerticesAsFloat(); // first index  =  vertex index, second index  =  0..2, x,y,z coordinate
  int [][] faces  =  cone.getFacesAsInt();// first index  =  face index, second index  =  index of vertex belonging to face

  float[][] verticesU  = utah.getVerticesAsFloat(); // first index  =  vertex index, second index  =  0..2, x,y,z coordinate
  int [][] facesU  =  utah.getFacesAsInt();// first index  =  face index, second index  =  index of vertex belonging to face

  // BEGIN MY CODE

  // put all the vertices into 3D octants
  int oct1CountU = 0;
  int oct2CountU = 0;
  int oct3CountU = 0;
  int oct4CountU = 0;
  int oct5CountU = 0;
  int oct6CountU = 0;
  int oct7CountU = 0;
  int oct8CountU = 0;

  int oct1Count = 0;
  int oct2Count = 0;
  int oct3Count = 0;
  int oct4Count = 0;
  int oct5Count = 0;
  int oct6Count = 0;
  int oct7Count = 0;
  int oct8Count = 0;

  // OCTANT 1 --------------------------------------
  // octant 1 utah
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] > 0 && verticesU[i][1] > 0 && verticesU[i][2] > 0) {
      oct1CountU++;
    }
  }

  float [][] oct1CoordsU = new float[oct1CountU][4]; // 1st is index # in verticesU
  int oct1CounterU = 0;
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] > 0 && verticesU[i][1] > 0 && verticesU[i][2] > 0) {
      oct1CoordsU[oct1CounterU][0] = i; // original index # in verticesU
      oct1CoordsU[oct1CounterU][1] = verticesU[i][0]; // x coord
      oct1CoordsU[oct1CounterU][2] = verticesU[i][1]; // y coord
      oct1CoordsU[oct1CounterU][3] = verticesU[i][2]; // z coord
      oct1CounterU++;
    }
  }

  // octant 1 cone
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] > 0 && vertices[i][1] > 0 && vertices[i][2] > 0) {
      oct1Count++;
    }
  }

  float [][] oct1Coords = new float[oct1Count][4]; // 1st is index # in verticesU
  int oct1Counter = 0;
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] > 0 && vertices[i][1] > 0 && vertices[i][2] > 0) {
      oct1Coords[oct1Counter][0] = i; // original index # in vertices
      oct1Coords[oct1Counter][1] = vertices[i][0]; // x coord
      oct1Coords[oct1Counter][2] = vertices[i][1]; // y coord
      oct1Coords[oct1Counter][3] = vertices[i][2]; // z coord
      oct1Counter++;
    }
  }

  // create arrays of directions/cross-products
  float [] modulusU = new float [oct1Coords.length];
  float [][] targetCoords = new float [oct1CoordsU.length][4]; // first number is original utah index, 2-4 is target x,y,z from cone
  for (int i=0; i<oct1CoordsU.length; i++) {
    float cPX = 0;
    float cPY = 0;
    float cPZ = 0;
    for  (int j=0; j<oct1Coords.length; j++) {
      cPX = (oct1CoordsU[i][2]*oct1Coords[j][3]) - (oct1CoordsU[i][3]*oct1Coords[j][2]);
      cPY = (oct1CoordsU[i][3]*oct1Coords[j][1]) - (oct1CoordsU[i][1]*oct1Coords[j][3]);
      cPZ = (oct1CoordsU[i][1]*oct1Coords[j][2]) - (oct1CoordsU[i][2]*oct1Coords[j][1]);     
      modulusU[j] = sqrt(sq(cPX)+sq(cPY)+sq(cPZ)); // must link this to the original index number in cone
    }
    targetCoords[i][0] = oct1CoordsU[i][0];
    targetCoords[i][1] = oct1Coords[smallestIndex(modulusU)][1];
    targetCoords[i][2] = oct1Coords[smallestIndex(modulusU)][2];
    targetCoords[i][3] = oct1Coords[smallestIndex(modulusU)][3];
  }

  // OCTANT 2 -----------------------------------------
  // octant 2 utah
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] > 0 && verticesU[i][1] > 0 && verticesU[i][2] < 0) {
      oct2CountU++;
    }
  }

  float [][] oct2CoordsU = new float[oct2CountU][4]; // 1st is index # in verticesU
  int oct2CounterU = 0;
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] > 0 && verticesU[i][1] > 0 && verticesU[i][2] < 0) {
      oct2CoordsU[oct2CounterU][0] = i; // original index # in verticesU
      oct2CoordsU[oct2CounterU][1] = verticesU[i][0]; // x coord
      oct2CoordsU[oct2CounterU][2] = verticesU[i][1]; // y coord
      oct2CoordsU[oct2CounterU][3] = verticesU[i][2]; // z coord
      oct2CounterU++;
    }
  }

  // octant 2 cone
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] > 0 && vertices[i][1] > 0 && vertices[i][2] < 0) {
      oct2Count++;
    }
  }

  float [][] oct2Coords = new float[oct2Count][4]; // 1st is index # in verticesU
  int oct2Counter = 0;
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] > 0 && vertices[i][1] > 0 && vertices[i][2] < 0) {
      oct2Coords[oct2Counter][0] = i; // original index # in vertices
      oct2Coords[oct2Counter][1] = vertices[i][0]; // x coord
      oct2Coords[oct2Counter][2] = vertices[i][1]; // y coord
      oct2Coords[oct2Counter][3] = vertices[i][2]; // z coord
      oct2Counter++;
    }
  }

  // create arrays of directions/cross-products octant 2
  float [] modulusU2 = new float [oct2Coords.length];
  float [][] targetCoords2 = new float [oct2CoordsU.length][4]; // first number is original utah index, 2-4 is target x,y,z from cone
  for (int i=0; i<oct2CoordsU.length; i++) {
    float cPX = 0;
    float cPY = 0;
    float cPZ = 0;
    for  (int j=0; j<oct2Coords.length; j++) {
      cPX = (oct2CoordsU[i][2]*oct2Coords[j][3]) - (oct2CoordsU[i][3]*oct2Coords[j][2]);
      cPY = (oct2CoordsU[i][3]*oct2Coords[j][1]) - (oct2CoordsU[i][1]*oct2Coords[j][3]);
      cPZ = (oct2CoordsU[i][1]*oct2Coords[j][2]) - (oct2CoordsU[i][2]*oct2Coords[j][1]);     
      modulusU2[j] = sqrt(sq(cPX)+sq(cPY)+sq(cPZ)); // must link this to the original index number in cone
    }
    targetCoords2[i][0] = oct2CoordsU[i][0];
    targetCoords2[i][1] = oct2Coords[smallestIndex(modulusU2)][1];
    targetCoords2[i][2] = oct2Coords[smallestIndex(modulusU2)][2];
    targetCoords2[i][3] = oct2Coords[smallestIndex(modulusU2)][3];
  }

  // OCTANT 3 -----------------------------------------
  // octant 3 utah
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] < 0 && verticesU[i][1] > 0 && verticesU[i][2] < 0) {
      oct3CountU++;
    }
  }

  float [][] oct3CoordsU = new float[oct3CountU][4]; // 1st is index # in verticesU
  int oct3CounterU = 0;
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] < 0 && verticesU[i][1] > 0 && verticesU[i][2] < 0) {
      oct3CoordsU[oct3CounterU][0] = i; // original index # in verticesU
      oct3CoordsU[oct3CounterU][1] = verticesU[i][0]; // x coord
      oct3CoordsU[oct3CounterU][2] = verticesU[i][1]; // y coord
      oct3CoordsU[oct3CounterU][3] = verticesU[i][2]; // z coord
      oct3CounterU++;
    }
  }

  // octant 3 cone
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] < 0 && vertices[i][1] > 0 && vertices[i][2] < 0) {
      oct3Count++;
    }
  }

  float [][] oct3Coords = new float[oct3Count][4]; // 1st is index # in verticesU
  int oct3Counter = 0;
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] < 0 && vertices[i][1] > 0 && vertices[i][2] < 0) {
      oct3Coords[oct3Counter][0] = i; // original index # in vertices
      oct3Coords[oct3Counter][1] = vertices[i][0]; // x coord
      oct3Coords[oct3Counter][2] = vertices[i][1]; // y coord
      oct3Coords[oct3Counter][3] = vertices[i][2]; // z coord
      oct3Counter++;
    }
  }

  // create arrays of directions/cross-products octant 3
  float [] modulusU3 = new float [oct3Coords.length];
  float [][] targetCoords3 = new float [oct3CoordsU.length][4]; // first number is original utah index, 2-4 is target x,y,z from cone
  for (int i=0; i<oct3CoordsU.length; i++) {
    float cPX = 0;
    float cPY = 0;
    float cPZ = 0;
    for  (int j=0; j<oct3Coords.length; j++) {
      cPX = (oct3CoordsU[i][2]*oct3Coords[j][3]) - (oct3CoordsU[i][3]*oct3Coords[j][2]);
      cPY = (oct3CoordsU[i][3]*oct3Coords[j][1]) - (oct3CoordsU[i][1]*oct3Coords[j][3]);
      cPZ = (oct3CoordsU[i][1]*oct3Coords[j][2]) - (oct3CoordsU[i][2]*oct3Coords[j][1]);     
      modulusU3[j] = sqrt(sq(cPX)+sq(cPY)+sq(cPZ)); // must link this to the original index number in cone
    }
    targetCoords3[i][0] = oct3CoordsU[i][0];
    targetCoords3[i][1] = oct3Coords[smallestIndex(modulusU3)][1];
    targetCoords3[i][2] = oct3Coords[smallestIndex(modulusU3)][2];
    targetCoords3[i][3] = oct3Coords[smallestIndex(modulusU3)][3];
  }

  // OCTANT 4 -----------------------------------------
  // octant 4 utah
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] < 0 && verticesU[i][1] > 0 && verticesU[i][2] > 0) {
      oct4CountU++;
    }
  }

  float [][] oct4CoordsU = new float[oct4CountU][4]; // 1st is index # in verticesU
  int oct4CounterU = 0;
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] < 0 && verticesU[i][1] > 0 && verticesU[i][2] > 0) {
      oct4CoordsU[oct4CounterU][0] = i; // original index # in verticesU
      oct4CoordsU[oct4CounterU][1] = verticesU[i][0]; // x coord
      oct4CoordsU[oct4CounterU][2] = verticesU[i][1]; // y coord
      oct4CoordsU[oct4CounterU][3] = verticesU[i][2]; // z coord
      oct4CounterU++;
    }
  }

  // octant 4 cone
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] < 0 && vertices[i][1] > 0 && vertices[i][2] > 0) {
      oct4Count++;
    }
  }

  float [][] oct4Coords = new float[oct4Count][4]; // 1st is index # in verticesU
  int oct4Counter = 0;
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] < 0 && vertices[i][1] > 0 && vertices[i][2] > 0) {
      oct4Coords[oct4Counter][0] = i; // original index # in vertices
      oct4Coords[oct4Counter][1] = vertices[i][0]; // x coord
      oct4Coords[oct4Counter][2] = vertices[i][1]; // y coord
      oct4Coords[oct4Counter][3] = vertices[i][2]; // z coord
      oct4Counter++;
    }
  }

  // create arrays of directions/cross-products octant 4
  float [] modulusU4 = new float [oct4Coords.length];
  float [][] targetCoords4 = new float [oct4CoordsU.length][4]; // first number is original utah index, 2-4 is target x,y,z from cone
  for (int i=0; i<oct4CoordsU.length; i++) {
    float cPX = 0;
    float cPY = 0;
    float cPZ = 0;
    for  (int j=0; j<oct4Coords.length; j++) {
      cPX = (oct4CoordsU[i][2]*oct4Coords[j][3]) - (oct4CoordsU[i][3]*oct4Coords[j][2]);
      cPY = (oct4CoordsU[i][3]*oct4Coords[j][1]) - (oct4CoordsU[i][1]*oct4Coords[j][3]);
      cPZ = (oct4CoordsU[i][1]*oct4Coords[j][2]) - (oct4CoordsU[i][2]*oct4Coords[j][1]);     
      modulusU4[j] = sqrt(sq(cPX)+sq(cPY)+sq(cPZ)); // must link this to the original index number in cone
    }
    targetCoords4[i][0] = oct4CoordsU[i][0];
    targetCoords4[i][1] = oct4Coords[smallestIndex(modulusU4)][1];
    targetCoords4[i][2] = oct4Coords[smallestIndex(modulusU4)][2];
    targetCoords4[i][3] = oct4Coords[smallestIndex(modulusU4)][3];
  }

  // OCTANT 5 -----------------------------------------
  // octant 5 utah
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] > 0 && verticesU[i][1] < 0 && verticesU[i][2] > 0) {
      oct5CountU++;
    }
  }

  float [][] oct5CoordsU = new float[oct5CountU][4]; // 1st is index # in verticesU
  int oct5CounterU = 0;
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] > 0 && verticesU[i][1] < 0 && verticesU[i][2] > 0) {
      oct5CoordsU[oct5CounterU][0] = i; // original index # in verticesU
      oct5CoordsU[oct5CounterU][1] = verticesU[i][0]; // x coord
      oct5CoordsU[oct5CounterU][2] = verticesU[i][1]; // y coord
      oct5CoordsU[oct5CounterU][3] = verticesU[i][2]; // z coord
      oct5CounterU++;
    }
  }

  // octant 5 cone
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] > 0 && vertices[i][1] < 0 && vertices[i][2] > 0) {
      oct5Count++;
    }
  }

  float [][] oct5Coords = new float[oct5Count][4]; // 1st is index # in verticesU
  int oct5Counter = 0;
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] > 0 && vertices[i][1] < 0 && vertices[i][2] > 0) {
      oct5Coords[oct5Counter][0] = i; // original index # in vertices
      oct5Coords[oct5Counter][1] = vertices[i][0]; // x coord
      oct5Coords[oct5Counter][2] = vertices[i][1]; // y coord
      oct5Coords[oct5Counter][3] = vertices[i][2]; // z coord
      oct5Counter++;
    }
  }

  // create arrays of directions/cross-products octant 4
  float [] modulusU5 = new float [oct5Coords.length];
  float [][] targetCoords5 = new float [oct5CoordsU.length][4]; // first number is original utah index, 2-4 is target x,y,z from cone
  for (int i=0; i<oct5CoordsU.length; i++) {
    float cPX = 0;
    float cPY = 0;
    float cPZ = 0;
    for  (int j=0; j<oct5Coords.length; j++) {
      cPX = (oct5CoordsU[i][2]*oct5Coords[j][3]) - (oct5CoordsU[i][3]*oct5Coords[j][2]);
      cPY = (oct5CoordsU[i][3]*oct5Coords[j][1]) - (oct5CoordsU[i][1]*oct5Coords[j][3]);
      cPZ = (oct5CoordsU[i][1]*oct5Coords[j][2]) - (oct5CoordsU[i][2]*oct5Coords[j][1]);     
      modulusU5[j] = sqrt(sq(cPX)+sq(cPY)+sq(cPZ)); // must link this to the original index number in cone
    }
    targetCoords5[i][0] = oct5CoordsU[i][0];
    targetCoords5[i][1] = oct5Coords[smallestIndex(modulusU5)][1];
    targetCoords5[i][2] = oct5Coords[smallestIndex(modulusU5)][2];
    targetCoords5[i][3] = oct5Coords[smallestIndex(modulusU5)][3];
  }

  // OCTANT 6 -----------------------------------------
  // octant 6 utah
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] > 0 && verticesU[i][1] < 0 && verticesU[i][2] < 0) {
      oct6CountU++;
    }
  }

  float [][] oct6CoordsU = new float[oct6CountU][4]; // 1st is index # in verticesU
  int oct6CounterU = 0;
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] > 0 && verticesU[i][1] < 0 && verticesU[i][2] < 0) {
      oct6CoordsU[oct6CounterU][0] = i; // original index # in verticesU
      oct6CoordsU[oct6CounterU][1] = verticesU[i][0]; // x coord
      oct6CoordsU[oct6CounterU][2] = verticesU[i][1]; // y coord
      oct6CoordsU[oct6CounterU][3] = verticesU[i][2]; // z coord
      oct6CounterU++;
    }
  }

  // octant 6 cone
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] > 0 && vertices[i][1] < 0 && vertices[i][2] < 0) {
      oct6Count++;
    }
  }

  float [][] oct6Coords = new float[oct6Count][4]; // 1st is index # in verticesU
  int oct6Counter = 0;
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] > 0 && vertices[i][1] < 0 && vertices[i][2] < 0) {
      oct6Coords[oct6Counter][0] = i; // original index # in vertices
      oct6Coords[oct6Counter][1] = vertices[i][0]; // x coord
      oct6Coords[oct6Counter][2] = vertices[i][1]; // y coord
      oct6Coords[oct6Counter][3] = vertices[i][2]; // z coord
      oct6Counter++;
    }
  }

  // create arrays of directions/cross-products octant 4
  float [] modulusU6 = new float [oct6Coords.length];
  float [][] targetCoords6 = new float [oct6CoordsU.length][4]; // first number is original utah index, 2-4 is target x,y,z from cone
  for (int i=0; i<oct6CoordsU.length; i++) {
    float cPX = 0;
    float cPY = 0;
    float cPZ = 0;
    for  (int j=0; j<oct6Coords.length; j++) {
      cPX = (oct6CoordsU[i][2]*oct6Coords[j][3]) - (oct6CoordsU[i][3]*oct6Coords[j][2]);
      cPY = (oct6CoordsU[i][3]*oct6Coords[j][1]) - (oct6CoordsU[i][1]*oct6Coords[j][3]);
      cPZ = (oct6CoordsU[i][1]*oct6Coords[j][2]) - (oct6CoordsU[i][2]*oct6Coords[j][1]);     
      modulusU6[j] = sqrt(sq(cPX)+sq(cPY)+sq(cPZ)); // must link this to the original index number in cone
    }
    targetCoords6[i][0] = oct6CoordsU[i][0];
    targetCoords6[i][1] = oct6Coords[smallestIndex(modulusU6)][1];
    targetCoords6[i][2] = oct6Coords[smallestIndex(modulusU6)][2];
    targetCoords6[i][3] = oct6Coords[smallestIndex(modulusU6)][3];
  }

  // OCTANT 7 -----------------------------------------
  // octant 7 utah
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] < 0 && verticesU[i][1] < 0 && verticesU[i][2] < 0) {
      oct7CountU++;
    }
  }

  float [][] oct7CoordsU = new float[oct7CountU][4]; // 1st is index # in verticesU
  int oct7CounterU = 0;
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] < 0 && verticesU[i][1] < 0 && verticesU[i][2] < 0) {
      oct7CoordsU[oct7CounterU][0] = i; // original index # in verticesU
      oct7CoordsU[oct7CounterU][1] = verticesU[i][0]; // x coord
      oct7CoordsU[oct7CounterU][2] = verticesU[i][1]; // y coord
      oct7CoordsU[oct7CounterU][3] = verticesU[i][2]; // z coord
      oct7CounterU++;
    }
  }

  // octant 7 cone
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] < 0 && vertices[i][1] < 0 && vertices[i][2] < 0) {
      oct7Count++;
    }
  }

  float [][] oct7Coords = new float[oct7Count][4]; // 1st is index # in verticesU
  int oct7Counter = 0;
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] < 0 && vertices[i][1] < 0 && vertices[i][2] < 0) {
      oct7Coords[oct7Counter][0] = i; // original index # in vertices
      oct7Coords[oct7Counter][1] = vertices[i][0]; // x coord
      oct7Coords[oct7Counter][2] = vertices[i][1]; // y coord
      oct7Coords[oct7Counter][3] = vertices[i][2]; // z coord
      oct7Counter++;
    }
  }

  // create arrays of directions/cross-products octant 7
  float [] modulusU7 = new float [oct7Coords.length];
  float [][] targetCoords7 = new float [oct7CoordsU.length][4]; // first number is original utah index, 2-4 is target x,y,z from cone
  for (int i=0; i<oct7CoordsU.length; i++) {
    float cPX = 0;
    float cPY = 0;
    float cPZ = 0;
    for  (int j=0; j<oct7Coords.length; j++) {
      cPX = (oct7CoordsU[i][2]*oct7Coords[j][3]) - (oct7CoordsU[i][3]*oct7Coords[j][2]);
      cPY = (oct7CoordsU[i][3]*oct7Coords[j][1]) - (oct7CoordsU[i][1]*oct7Coords[j][3]);
      cPZ = (oct7CoordsU[i][1]*oct7Coords[j][2]) - (oct7CoordsU[i][2]*oct7Coords[j][1]);     
      modulusU7[j] = sqrt(sq(cPX)+sq(cPY)+sq(cPZ)); // must link this to the original index number in cone
    }
    targetCoords7[i][0] = oct7CoordsU[i][0];
    targetCoords7[i][1] = oct7Coords[smallestIndex(modulusU7)][1];
    targetCoords7[i][2] = oct7Coords[smallestIndex(modulusU7)][2];
    targetCoords7[i][3] = oct7Coords[smallestIndex(modulusU7)][3];
  }

  // OCTANT 8 -----------------------------------------
  // octant 8 utah
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] < 0 && verticesU[i][1] < 0 && verticesU[i][2] > 0) {
      oct8CountU++;
    }
  }

  float [][] oct8CoordsU = new float[oct8CountU][4]; // 1st is index # in verticesU
  int oct8CounterU = 0;
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    if (verticesU[i][0] < 0 && verticesU[i][1] < 0 && verticesU[i][2] > 0) {
      oct8CoordsU[oct8CounterU][0] = i; // original index # in verticesU
      oct8CoordsU[oct8CounterU][1] = verticesU[i][0]; // x coord
      oct8CoordsU[oct8CounterU][2] = verticesU[i][1]; // y coord
      oct8CoordsU[oct8CounterU][3] = verticesU[i][2]; // z coord
      oct8CounterU++;
    }
  }

  // octant 8 cone
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] < 0 && vertices[i][1] < 0 && vertices[i][2] > 0) {
      oct8Count++;
    }
  }

  float [][] oct8Coords = new float[oct8Count][4]; // 1st is index # in verticesU
  int oct8Counter = 0;
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] < 0 && vertices[i][1] < 0 && vertices[i][2] > 0) {
      oct8Coords[oct8Counter][0] = i; // original index # in vertices
      oct8Coords[oct8Counter][1] = vertices[i][0]; // x coord
      oct8Coords[oct8Counter][2] = vertices[i][1]; // y coord
      oct8Coords[oct8Counter][3] = vertices[i][2]; // z coord
      oct8Counter++;
    }
  }

  // create arrays of directions/cross-products octant 4
  float [] modulusU8 = new float [oct8Coords.length];
  float [][] targetCoords8 = new float [oct8CoordsU.length][4]; // first number is original utah index, 2-4 is target x,y,z from cone
  for (int i=0; i<oct8CoordsU.length; i++) {
    float cPX = 0;
    float cPY = 0;
    float cPZ = 0;
    for  (int j=0; j<oct8Coords.length; j++) {
      cPX = (oct8CoordsU[i][2]*oct8Coords[j][3]) - (oct8CoordsU[i][3]*oct8Coords[j][2]);
      cPY = (oct8CoordsU[i][3]*oct8Coords[j][1]) - (oct8CoordsU[i][1]*oct8Coords[j][3]);
      cPZ = (oct8CoordsU[i][1]*oct8Coords[j][2]) - (oct8CoordsU[i][2]*oct8Coords[j][1]);     
      modulusU8[j] = sqrt(sq(cPX)+sq(cPY)+sq(cPZ)); // must link this to the original index number in cone
    }
    targetCoords8[i][0] = oct8CoordsU[i][0];
    targetCoords8[i][1] = oct8Coords[smallestIndex(modulusU8)][1];
    targetCoords8[i][2] = oct8Coords[smallestIndex(modulusU8)][2];
    targetCoords8[i][3] = oct8Coords[smallestIndex(modulusU8)][3];
  }


  // HE_MESH CODE ----------------------------------------------
  //Do something with the vertices
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    for (int j = 0; j<oct1CoordsU.length; j++) {
      if (i==targetCoords[j][0]) {
        verticesU[i][0] = verticesU[i][0] - (verticesU[i][0] - targetCoords[j][1])*1.0; 
        verticesU[i][1] = verticesU[i][1] - (verticesU[i][1] - targetCoords[j][2])*1.0;
        verticesU[i][2] = verticesU[i][2] - (verticesU[i][2] - targetCoords[j][3])*1.0;
      }
    }
  }

  // vertices octant 2
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    for (int j = 0; j<oct2CoordsU.length; j++) {
      if (i==targetCoords2[j][0]) {
        verticesU[i][0] = verticesU[i][0] - (verticesU[i][0] - targetCoords2[j][1])*1.0; 
        verticesU[i][1] = verticesU[i][1] - (verticesU[i][1] - targetCoords2[j][2])*1.0;
        verticesU[i][2] = verticesU[i][2] - (verticesU[i][2] - targetCoords2[j][3])*1.0;
      
    }
    }
  }

  // vertices octant 3
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    for (int j = 0; j<oct3CoordsU.length; j++) {
      if (i==targetCoords3[j][0]) {
        verticesU[i][0] = verticesU[i][0] - (verticesU[i][0] - targetCoords3[j][1])*1.0; 
        verticesU[i][1] = verticesU[i][1] - (verticesU[i][1] - targetCoords3[j][2])*1.0;
        verticesU[i][2] = verticesU[i][2] - (verticesU[i][2] - targetCoords3[j][3])*1.0;
      }
    }
  }

  // vertices octant 4
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    for (int j = 0; j<oct4CoordsU.length; j++) {
      if (i==targetCoords4[j][0]) {
        verticesU[i][0] = verticesU[i][0] - (verticesU[i][0] - targetCoords4[j][1])*1.0; 
        verticesU[i][1] = verticesU[i][1] - (verticesU[i][1] - targetCoords4[j][2])*1.0;
        verticesU[i][2] = verticesU[i][2] - (verticesU[i][2] - targetCoords4[j][3])*1.0;
      }
    }
  }

  // vertices octant 5
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    for (int j = 0; j<oct5CoordsU.length; j++) {
      if (i==targetCoords5[j][0]) {
         verticesU[i][0] = verticesU[i][0] - (verticesU[i][0] - targetCoords5[j][1])*1.0; 
        verticesU[i][1] = verticesU[i][1] - (verticesU[i][1] - targetCoords5[j][2])*1.0;
        verticesU[i][2] = verticesU[i][2] - (verticesU[i][2] - targetCoords5[j][3])*1.0;
      }
    }
  }

  // vertices octant 6
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    for (int j = 0; j<oct6CoordsU.length; j++) {
      if (i==targetCoords6[j][0]) {
         verticesU[i][0] = verticesU[i][0] - (verticesU[i][0] - targetCoords6[j][1])*1.0; 
        verticesU[i][1] = verticesU[i][1] - (verticesU[i][1] - targetCoords6[j][2])*1.0;
        verticesU[i][2] = verticesU[i][2] - (verticesU[i][2] - targetCoords6[j][3])*1.0;
      }
    }
  }

  // vertices octant 7
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    for (int j = 0; j<oct7CoordsU.length; j++) {
      if (i==targetCoords7[j][0]) {
        verticesU[i][0] = verticesU[i][0] - (verticesU[i][0] - targetCoords7[j][1])*1.0; 
        verticesU[i][1] = verticesU[i][1] - (verticesU[i][1] - targetCoords7[j][2])*1.0;
        verticesU[i][2] = verticesU[i][2] - (verticesU[i][2] - targetCoords7[j][3])*1.0;
      }
    }
  }

  // vertices octant 8
  for (int i = 0; i<utah.getNumberOfVertices (); i++) {
    for (int j = 0; j<oct8CoordsU.length; j++) {
      if (i==targetCoords8[j][0]) {
        verticesU[i][0] = verticesU[i][0] - (verticesU[i][0] - targetCoords8[j][1])*1.0; 
        verticesU[i][1] = verticesU[i][1] - (verticesU[i][1] - targetCoords8[j][2])*1.0;
        verticesU[i][2] = verticesU[i][2] - (verticesU[i][2] - targetCoords8[j][3])*1.0;
      }
    }
  }

  // any equal to 0?
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    if (vertices[i][0] == 0) {
      println("x coord is equal to 0");
    }
    if (vertices[i][1] == 0) {
      println("y coord is equal to 0");
    }
    if (vertices[i][2] == 0) {
      println("z coord is equal to 0");
    }
  }

  //Use the exported faces and vertices as source for a HEC_FaceList
  HEC_FromFacelist faceList = new HEC_FromFacelist().setFaces(faces).setVertices(vertices);
  modifiedCone = new HE_Mesh(faceList);

  HEC_FromFacelist faceListU = new HEC_FromFacelist().setFaces(facesU).setVertices(verticesU);
  modifiedUtah = new HE_Mesh(faceListU);

  render = new WB_Render(this);
}

void draw() {
  exit();
  background(0);
  lights();

  translate(width/2, height/2, 0);
  rotateY(radians(180));
  rotateX(radians(180));
  noStroke();
  
  render.drawFacesSmooth(modifiedUtah);
  stroke(0);
  
  
  String picCountArray[] = {
    nf(picCount, 0)
    };
    saveStrings("/Users/rherrema/Documents/Processing/MeshTransforms/automator/count.txt", picCountArray);
    
    saveFrame(nf(picCount, 2) + ".png");
    HET_Export.saveToSTL(modifiedUtah, sketchPath(""), nf(picCount, 2));
}

void keyPressed() {
  if (key == 's') {
    saveFrame("frame-#####.png");
    HET_Export.saveToSTL(modifiedUtah, sketchPath(""), nf(frameCount, 2));
  }
}

//This method returns the index of the smallest value in the array of given size
public static int smallestIndex (float[] array) {
  float currentValue = array[0]; 
  int smallestIndex = 0;
  for (int j=1; j < array.length; j++) {
    if (array[j] < currentValue)
    { 
      currentValue = array[j];
      smallestIndex = j;
    }
  }
  //  System.out.println("The smallest index is: "+ smallestIndex);
  return smallestIndex;
}

