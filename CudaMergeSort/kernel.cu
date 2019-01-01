
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <iostream>
using namespace std;

__global__ 
void singleMergeSort(int * array, int size)
{
	//Block size is given by size
    int thread = threadIdx.x;
	int block = blockIdx.x;

	int leftStart = thread * size;
	int rightStart = thread * size + size / 2;

	//make another block to track the numbers
	int * fullBlock;
	//malloc(&fullBlock, sizeof(int) * size);
	fullBlock = new int[size];
	int tracker = 0;
	//printf("Left Num: %d, Right Num: %d, Thread Num: %d, Size: %d\n", leftStart, rightStart, thread, size);
	while (leftStart < thread * size + size / 2 && rightStart < (thread + 1) * (size))
	{
		//Figure out an inplace method for this later?

		//If left side is less than or left side is completely full
		if (array[leftStart] > array[rightStart])
		{
			fullBlock[tracker] = array[rightStart];
			rightStart++;
		}
		else
		{
			fullBlock[tracker] = array[leftStart];
			leftStart++;
		}
		tracker++;
	}

	while (leftStart < thread * size + size / 2)
	{
		fullBlock[tracker++] = array[leftStart++];
	}
	while (rightStart < (thread + 1) * (size))
	{
		fullBlock[tracker++] = array[rightStart++];
	}
	printf("Left Num: %d, Right Num: %d, Thread Num: %d, Size: %d\n", leftStart, rightStart, thread, size);
	memcpy(&(array[thread * size]), fullBlock, sizeof(int) * size);
	free(fullBlock);

	//printf("Left Num: %d, Right Num: %d, Thread Num: %d\n", array[thread * size], array[thread * size + size / 2], thread);
	//printf("TwoVals: %d, %d\n", array[thread], array[thread + 1]);
	//printf("Thread ID: %d\n\tBlock ID: %d\n", thread, block);

}

void printArray(int * array, int size)
{
	for (int i = 0; i < size; i++)
	{
		cout << array[i] << ' ';
	}
	cout << endl << endl;
}

void sortArray(int * array, int size)
{
	//Copy the array to device code first
	int * deviceArray;
	cudaMalloc(&deviceArray, size * sizeof(int));
	cudaMemcpy(deviceArray, array, size * sizeof(int), cudaMemcpyHostToDevice);

	//Print original array first
	printArray(array, size);
	//first iteration of this code, size must be a factor of 2
	int sizeSort = 2;
	while (sizeSort <= size)
	{
		int numBlocks = size / sizeSort;
		int numThreads = numBlocks;
		cout << sizeSort << endl;

		singleMergeSort << <1, numBlocks >> > (deviceArray, sizeSort);
		cudaDeviceSynchronize();
		cudaMemcpy(array, deviceArray, size * sizeof(int), cudaMemcpyDeviceToHost);
		
		printArray(array, size);
		sizeSort *= 2;
	}

	cudaFree(deviceArray);

}

int main()
{
	//Generate array and its values for testing purposes
	int * sortThis = new int[16];
	
	sortThis[0] = 6;
	sortThis[1] = 3;
	sortThis[2] = 2;
	sortThis[3] = 14;
	sortThis[4] = 28;
	sortThis[5] = 1;
	sortThis[6] = 4;
	sortThis[7] = 9;
	sortThis[8] = 57;
	sortThis[9] = 77;
	sortThis[10] = 28;
	sortThis[11] = 22;
	sortThis[12] = 22;
	sortThis[13] = 213;
	sortThis[14] = 5;
	sortThis[15] = 0;
	sortThis[16] = 3;

	sortArray(sortThis, 16);
	//delete []sortThis;
	return 0;
}
