#include <stdio.h>

// Luis Miguel García Marín

#define ADD_VECTORS_ITERATIONS 1000  // Define the number of times to execute addVectorsInto

__global__ void initWith(float num, float *a, int N)
{
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    for (int i = index; i < N; i += stride)
    {
        a[i] = num;
    }
}

__global__ void addVectorsInto(float *result, float *a, float *b, int N)
{
    int index = threadIdx.x + blockIdx.x * blockDim.x;
    int stride = blockDim.x * gridDim.x;

    for (int i = index; i < N; i += stride)
    {
        result[i] = a[i] + b[i];
    }
}

void checkElementsAre(float target, float *vector, int N)
{
    for (int i = 0; i < N; i++)
    {
        if (vector[i] != target)
        {
            printf("FAIL: vector[%d] - %0.0f does not equal %0.0f\n", i, vector[i], target);
            exit(1);
        }
    }
    printf("Success! All values calculated correctly.\n");
}

int main()
{
    int deviceId;
    int numberOfSMs;

    cudaSetDevice(0);

    cudaDeviceGetAttribute(&numberOfSMs, cudaDevAttrMultiProcessorCount, 0);

    const int N = 2 << 24;
    size_t size = N * sizeof(float);

    float *a;
    float *b;
    float *c;

    cudaMallocManaged(&a, size);
    cudaMallocManaged(&b, size);
    cudaMallocManaged(&c, size);

    // Initialize arrays on CPU first
    for(int i = 0; i < N; i++) {
        a[i] = 3.0f;
        b[i] = 4.0f;
        c[i] = 0.0f;
    }

    // Prefetch to GPU after CPU initialization
    // cudaMemPrefetchAsync(a, size, 0);
    // cudaMemPrefetchAsync(b, size, 0);
    // cudaMemPrefetchAsync(c, size, 0);

    size_t threadsPerBlock;
    size_t numberOfBlocks;

    threadsPerBlock = 256;
    numberOfBlocks = 32 * numberOfSMs;

    cudaError_t ignore;
    cudaError_t addVectorsErr;
    cudaError_t asyncErr;

    ignore = cudaGetLastError();

    // No need for initWith kernels since we initialized on CPU
    // initWith<<<numberOfBlocks, threadsPerBlock>>>(3, a, N);
    // initWith<<<numberOfBlocks, threadsPerBlock>>>(4, b, N);
    // initWith<<<numberOfBlocks, threadsPerBlock>>>(0, c, N);

    // Execute addVectorsInto kernel multiple times
    for (int i = 0; i < ADD_VECTORS_ITERATIONS; i++) {
        addVectorsInto<<<numberOfBlocks, threadsPerBlock>>>(c, a, b, N);
        addVectorsErr = cudaGetLastError();
        if (addVectorsErr != cudaSuccess)
            printf("Error: %s\n", cudaGetErrorString(addVectorsErr));

        asyncErr = cudaDeviceSynchronize();
        if (asyncErr != cudaSuccess)
            printf("Error: %s\n", cudaGetErrorString(asyncErr));
    }

    cudaMemPrefetchAsync(c, size, cudaCpuDeviceId);

    checkElementsAre(7, c, N);

    cudaFree(a);
    cudaFree(b);
    cudaFree(c);
}
