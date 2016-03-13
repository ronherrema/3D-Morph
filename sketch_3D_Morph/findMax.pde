void findMax(float arrayT[][]) {
 
  float array[][] = arrayT;
 
  // find max and min values of vertices
  float yValues[] = new float[cone.getNumberOfVertices()];
  float xValues[] = new float[cone.getNumberOfVertices()];
  float zValues[] = new float[cone.getNumberOfVertices()];
  for (int i = 0; i<cone.getNumberOfVertices (); i++) {
    yValues[i] = array[i][1];
    xValues[i] = array[i][0];
    zValues[i] = array[i][2];
  }

  println("max of y is " + max(yValues));
  println("max of y is " + min(yValues));
  println("max of x is " + max(xValues));
  println("max of x is " + min(xValues));
  println("max of z is " + max(zValues));
  println("max of z is " + min(zValues)); 
  
}
