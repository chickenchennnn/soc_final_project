
#define SIZE 10
#define SIZE_MAT 4
#define N 64



int A[SIZE_MAT*SIZE_MAT] = {0, 1, 2, 3,
		0, 1, 2, 3,
		0, 1, 2, 3,
		0, 1, 2, 3,
};
int B[SIZE_MAT*SIZE_MAT] = {1, 2, 3, 4,
	5, 6, 7, 8,
	9, 10, 11, 12,
	13, 14, 15, 16,
};
int result[SIZE_MAT*SIZE_MAT];



//int taps[N] = {0,-10,-9,23,56,63,56,23,-9,-10,0};
//int inputbuffer[N];
//int inputsignal[N];
//int outputsignal[N];

int inputsignal[N];
int outputsignal;
int output_mm;
int output_qs;
int Array[SIZE] = {893, 40, 3233, 4267, 2669, 2541, 9073, 6023, 5681, 4622};