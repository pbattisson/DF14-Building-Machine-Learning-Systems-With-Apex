@isTest
private class MatrixOperationsTest {
	
	private static String JSONString = '[[1,2,3,4],[5,6,7,8],[9,10,11,12]]';

	@isTest 
	static void testMatrixMultiplication() {
		Matrix A = new Matrix(2, 2);
		Matrix B = new Matrix(2, 2);

		Double d = 2;

		A.setElement(0, 0, d);
		A.setElement(0, 1, d);
		A.setElement(1, 0, d);
		A.setElement(1, 1, d);
		B.setElement(0, 0, d);
		B.setElement(0, 1, d);
		B.setElement(1, 0, d);
		B.setElement(1, 1, d);

		Matrix C = MatrixOperations.multiply(A, B);

		System.assertEquals(2, C.rows);
		System.assertEquals(2, C.columns);
		System.assertEquals(8, C.getElement(0, 0));
		System.assertEquals(8, C.getElement(0, 1));
		System.assertEquals(8, C.getElement(1, 0));
		System.assertEquals(8, C.getElement(1, 1));

	}

	@isTest
	static void testInvalidMultiply() {
		Matrix A = new Matrix(1,1);
		Matrix B = new Matrix(2,2);

		System.assertEquals(null, MatrixOperations.multiply(A, B));
	}

	@isTest
	static void testBasicTranspose() {
		List<Double> row1 = new List<Double>{1,2};
		List<Double> row2 = new List<Double>{3,4};
		Matrix A = new Matrix(new List<List<Double>>{row1, row2});

		System.assertEquals(2, A.rows);
		System.assertEquals(2, A.columns);
		System.assertEquals(1, A.getElement(0, 0));
		System.assertEquals(2, A.getElement(0, 1));
		System.assertEquals(3, A.getElement(1, 0));
		System.assertEquals(4, A.getElement(1, 1));

		Matrix A_tran = MatrixOperations.transpose(A);
		
		System.assertEquals(2, A_tran.rows);
		System.assertEquals(2, A_tran.columns);
		System.assertEquals(1, A_tran.getElement(0, 0));
		System.assertEquals(3, A_tran.getElement(0, 1));
		System.assertEquals(2, A_tran.getElement(1, 0));
		System.assertEquals(4, A_tran.getElement(1, 1));

	}

	@isTest
	static void testAddition() {
		Matrix A = new Matrix(JSONString);
		Matrix B = new Matrix(JSONString);

		Matrix C = MatrixOperations.add(A, B);

		System.assertEquals(A.rows, C.rows);
		System.assertEquals(A.columns, C.columns);

		for(Integer i = 0; i < 2; i++) {
			for(Integer j = 0; j<2; j++) {
				System.assertEquals(2*A.getElement(i, j), C.getElement(i, j));
			}
		}
	}

	@isTest
	static void testInvalidAddition() {
		Matrix A = new Matrix(1,1);
		Matrix B = new Matrix(2,2);

		System.assertEquals(null, MatrixOperations.add(A, B));
	}

	@isTest
	static void testSubtraction() {
		Matrix A = new Matrix(JSONString);
		Matrix B = new Matrix(JSONString);

		Matrix C = MatrixOperations.subtract(A, B);

		System.assertEquals(A.rows, C.rows);
		System.assertEquals(A.columns, C.columns);

		for(Integer i = 0; i < 2; i++) {
			for(Integer j = 0; j<2; j++) {
				System.assertEquals(0, C.getElement(i, j));
			}
		}
	}

	@isTest
	static void testInvalidSubtraction() {
		Matrix A = new Matrix(1,1);
		Matrix B = new Matrix(2,2);

		System.assertEquals(null, MatrixOperations.subtract(A, B));
	}

	@isTest
	static void testPointwiseMultiply() {
		Matrix A = new Matrix(JSONString);
		Matrix B = new Matrix(JSONString);

		Matrix C = MatrixOperations.pointwiseMultiply(A, B);

		System.assertEquals(A.rows, C.rows);
		System.assertEquals(A.columns, C.columns);

		for(Integer i = 0; i < 2; i++) {
			for(Integer j = 0; j<2; j++) {
				System.assertEquals(Math.pow(A.getElement(i, j), 2), C.getElement(i, j));
			}
		}
	}

	@isTest
	static void testInvalidPointwiseMultiply() {
		Matrix A = new Matrix(1,1);
		Matrix B = new Matrix(2,2);

		System.assertEquals(null, MatrixOperations.pointwiseMultiply(A, B));
	}

	@isTest
	static void testPointwiseExponent() {
		List<Double> vect = new List<Double>{1.0, 2.0};
		List<Double> vect2 = new List<Double>{3.0, 4.0};
		
		Matrix A = new Matrix(new List<List<Double>>{vect, vect2});
		Matrix B = MatrixOperations.pointwiseExponent(A, 2);

		System.assertEquals(1.0, B.getElement(0, 0));
		System.assertEquals(4.0, B.getElement(0, 1));
		System.assertEquals(9.0, B.getElement(1, 0));
		System.assertEquals(16.0, B.getElement(1, 1));
	}
	
}