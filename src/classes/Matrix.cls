/**
  * @author Paul Battisson
  * @description This is the basic matrix class we will be using to help us define a matrix within our mathematical framework. This should be replaced
  * with a more mathematically efficient and robust implementation when possible.
  */
public with sharing class Matrix 
{
	public Integer rows{get; private set;}
	public Integer columns{get; private set;}

	private List<List<Double>> elements;

	public Matrix(String JSONData) {

		this((List<List<Double>>)JSON.deserialize(JSONData, List<List<Double>>.class));
	}

	public Matrix(Integer numRows, Integer numCols) {
		rows = numRows;
		columns = numCols;

		elements = new List<List<Double>>();

		for(Integer i = 0; i < numRows; i++) {
			elements.add(new Double[numCols]);
		}
	}

	public Matrix(List<List<Double>> elems) {
		if(elems != null) {
			elements = elems;
			rows = elements.size();
			columns = elements.get(0).size();
		}
	}

	public Matrix(List<Double> elems) {
		if(elems != null) {
			elements = new List<List<Double>>();
			elements.add(elems);
			rows = elements.size();
			columns = elements.get(0).size();
		}
	}

	public void setElement(Integer rowNum, Integer colNum, Double value) {
		if(rowNum < rows && colNum < columns && rowNum >= 0 && colNum >= 0) {
			elements.get(rowNum).set(colNum, value);
		}
	}

	public Double getElement(Integer rowNum, Integer colNum) {
		if(rowNum < rows && colNum < columns && rowNum >= 0 && colNum >= 0) {
			return elements.get(rowNum).get(colNum);
		}

		return null;
	}

	public List<Double> getRow(Integer rowNum) {
		return elements.get(rowNum);
	}

	public void setRow(List<Double> row, Integer rowNum) {
		elements[rowNum] = row;
	}

	public Matrix addRow(List<Double> row) {
		if(row.size() == columns) {
			elements.add(row);
			rows++;
		} else {
			throw new MatrixException('You have attempted to add a row with the wrong number of columns. The row should have ' + columns + ' columns but instead had ' + row.size());
		}
		return this;
	}

	public void Zeros() {
		fill(0);
	}

	public List<Double> getDataAsList() {
		
		List<Double> data = new List<Double>();

		for(List<Double> row : elements) {
			data.addAll(row);
		}

		return data;
	}

	public void fill(Double value) {
		for(Integer i = 0; i < rows; i++) {
			for(Integer j = 0; j < columns; j++) {
				elements.get(i).set(j, value);
			}
		}
	}

	public String to_json() {
		return JSON.serialize(elements);
	}
}