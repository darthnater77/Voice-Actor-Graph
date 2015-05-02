class Table {
  int rowCount;
  String[][] data;
  
  
  Table(String filename) {
    String[] rows = loadStrings(filename);
    data = new String[rows.length][];
    
    for (int i = 0; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; 
      }
      if (rows[i].startsWith("#")) {
        continue; 
      }
      data[rowCount++] = split(rows[i], TAB);
    }
    data = (String[][]) subset(data, 0, rowCount);
  }
   
  int getRowCount() {
    return rowCount;
  }
  
  int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (data[i][0].equals(name)) {
        return i;
      }
    }
    println("No row named '" + name + "' was found");
    return -1;
  } 
  
  String getRowName(int row) {
    return getString(row, 0);
  }

  String getString(int rowIndex, int column) {
    return data[rowIndex][column];
  }
  
  String getString(String rowName, int column) {
    return getString(getRowIndex(rowName), column);
  }

}
