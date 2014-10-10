public class MatrixOperations {

	public static Matrix multiply(Matrix A, Matrix B) {

		if(A.columns != B.rows) {
			return null;
		}

		Integer A_rows = A.rows, A_cols = A.columns, B_cols = B.columns;

		Matrix C = new Matrix(A_rows, B_cols);
		C.zeros();

		for(Integer i = 0; i < A_rows; i++) {
			List<Double> A_row = A.getRow(i);
			for(Integer j = 0; j < B_cols; j++) {
				for(Integer k = 0; k < A_cols; k++) {

					C.setElement(i, j, C.getElement(i, j) + A_row[k]*B.getElement(k, j));
				}
			}
		}

		return C;
	}

	public static Matrix transpose(Matrix A) {
		Integer A_rows = A.rows, A_cols = A.columns;

		Matrix B = new Matrix(A_cols, A_rows);
		for(Integer i = 0; i < A_rows; i++) {
			List<Double> A_row = A.getRow(i);
			for(Integer j = 0; j < A_cols; j++) {
				B.setElement(j, i, A_row[j]);
			}
		}

		return B;
	}

	public static Matrix add(Matrix A, Matrix B) {

		if((A.rows != B.rows) && (A.columns != B.columns)) {
			return null;
		}

		Integer A_rows = A.rows, A_cols = A.columns, B_rows = B.rows, B_cols = B.columns;

		Matrix C = new Matrix(A_rows, A_cols);

		for(Integer i = 0; i < A_rows; i++) {
			List<Double> A_row = A.getRow(i), B_row = B.getRow(i), C_row = new Double[A_cols];
			for(Integer j = 0; j < A_cols; j ++) {
				C_row[j] = A_row[j] + B_row[j];
			}

			C.setRow(C_row, i);
		}

		return C;
	}

	public static Matrix subtract(Matrix A, Matrix B) {

		if((A.rows != B.rows) && (A.columns != B.columns)) {
			return null;
		}

		Integer A_rows = A.rows, A_cols = A.columns, B_rows = B.rows, B_cols = B.columns;

		Matrix C = new Matrix(A_rows, A_cols);

		for(Integer i = 0; i < A_rows; i++) {
			List<Double> A_row = A.getRow(i), B_row = B.getRow(i), C_row = new Double[A_cols];
			for(Integer j = 0; j < A_cols; j ++) {
				C_row[j] = A_row[j] - B_row[j];
			}

			C.setRow(C_row, i);
		}

		return C;
	}

	public static Matrix pointwiseMultiply(Matrix A, Matrix B) {

		if((A.rows != B.rows) && (A.columns != B.columns)) {
			return null;
		}

		Integer A_rows = A.rows, A_cols = A.columns, B_rows = B.rows, B_cols = B.columns;

		Matrix C = new Matrix(A_rows, A_cols);

		for(Integer i = 0; i < A_rows; i++) {
			List<Double> A_row = A.getRow(i), B_row = B.getRow(i), C_row = new Double[A_cols];
			for(Integer j = 0; j < A_cols; j ++) {
				C_row[j] = A_row[j] * B_row[j];
			}

			C.setRow(C_row, i);
		}

		return C;
	}

	public static Matrix pointwiseExponent(Matrix A, Double exponent) {

		Integer A_rows = A.rows, A_cols = A.columns;

		for(Integer i = 0; i < A_rows; i++) {
			List<Double> A_row = A.getRow(i), A_row_exp = new Double[A_cols];
			for(Integer j = 0; j < A_cols; j++) {
				A_row_exp[j] = Math.pow(A_row[j], exponent);
			}
			A.setRow(A_row_exp, i);
		}

		return A;
	}
}