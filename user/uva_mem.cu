#include <cuda_runtime.h>
#include <stdio.h>

__global__ void init_value_device(float *a, const int N){
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	if (i < N) a[i] = 0.5f;
}

int main(int argc, char **argv) {
	// Set device	
	int dev = 0;
	cudaSetDevice(dev);
	
	// Memory size
	unsigned int isize = 1<<5;
	unsigned int nbytes = isize *sizeof(float);
	
	// Get Device infromation and check CPU memory mapping 
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp, dev);
	if (!deviceProp.canMapHostMemory){
		printf("Device %d does not support CPU mapping CPU host memory\n", dev);
		cudaDeviceReset();
		exit(EXIT_SUCCESS);	
	}
	printf("Device %d: %s memory size %d nbyte %5.2fMB\n", dev, deviceProp.name, isize,nbytes/(1024.0f*1024.0f));
	
	// Allocate the host memory 
	float *h_a = (float *)malloc(nbytes);

	// Allocate the device memory
	float *d_a;
	cudaMalloc((float **) &d_a, nbytes);

	// Initialize host memory variable a
	for (unsigned int i = 0; i < isize; i++) h_a[i] = 0.5f;

	// Transfer from host to device 
	cudaMemcpy(d_a, h_a, nbytes, cudaMemcpyHostToDevice);

	//Do some computation foo<<<grid,block>>>(); 

	// Transfer from device to host
	cudaMemcpy(h_a, d_a, nbytes, cudaMemcpyDeviceToHost); 

	cudaDeviceSynchronize();
	
	// Free memory on host and device
	free(h_a);
	cudaFree(d_a);
	cudaDeviceReset();

	///////// 2nd Part ZERO-COPY MEMORY for integrated heterogeneous architecture ////////////
	
	float* h_b = NULL;	

	// Allocate data at host side with zero-copy
	cudaHostAlloc((void **)&h_b, nbytes, cudaHostAllocMapped);	

	float* d_b;

	// Pass pointer to device 
	cudaHostGetDevicePointer((void **)&d_b, (void *)h_b, 0);

	// Initialize variable b on device 
	int iLen = 512;
	dim3 block (iLen);
	dim3 grid ((isize+block.x-1)/block.x);
	init_value_device<<<grid,block>>>(d_b, nbytes);

	cudaDeviceSynchronize();

	//cudaMemcpy(h_b, d_b, nbytes, cudaMemcpyDeviceToHost); 
	
	// No need to DtoH transfer 
	//for (unsigned int i = 0; i < isize; i++) printf("%1.2f %1.2f\n", h_b[i],  d_b[i]);

	// Free memory on host and device
	cudaFreeHost(h_b);
	cudaFree(d_b);

	// Reset device
	cudaDeviceReset();	
	return EXIT_SUCCESS;

}
