#include "cuda.h"
#include "cuda_runtime.h"
#include "cuda_runtime_api.h"
#include <stdio.h>

#include "nv12_to_rgb.h"

__global__ void dev_nv12_to_rgb(unsigned char *pYdata, unsigned char *pUVdata, int stepY, int stepUV, unsigned char *pImgData, int width, int height, int channels)
{
    const int tidx = blockIdx.x * blockDim.x + threadIdx.x;
    const int tidy = blockIdx.y * blockDim.y + threadIdx.y;

    // printf("x-->blockIdx.x, blockDim.x threadIdx.x [%d %d %d] \n", blockIdx.x, blockDim.x, threadIdx.x);
    // printf("y-->blockIdx.y, blockDim.y threadIdx.y [%d %d %d] \n", blockIdx.y, blockDim.y, threadIdx.y);

    if (tidx < width && tidy < height)
    {
        int indexY, indexU, indexV;
        unsigned char Y, U, V;
        indexY = tidy * stepY + tidx;    
        Y = pYdata[indexY];

        if (tidx % 2 == 0)
        {
            indexU = tidy / 2 * stepUV + tidx;
            indexV = tidy / 2 * stepUV + tidx + 1;
            U = pUVdata[indexU];
            V = pUVdata[indexV];
        }
        else if (tidx % 2 == 1)
        {
            indexV = tidy / 2 * stepUV + tidx;
            indexU = tidy / 2 * stepUV + tidx - 1;
            U = pUVdata[indexU];
            V = pUVdata[indexV];
        }

        pImgData[(tidy*width + tidx) * channels + 2] = uchar (Y + 1.402 * (V - 128));
        pImgData[(tidy*width + tidx) * channels + 1] = uchar (Y - 0.34413 * (U - 128) - 0.71414*(V - 128));
        pImgData[(tidy*width + tidx) * channels + 0] = uchar (Y + 1.772*(U - 128));
    }
}

bool nv12_to_rgb(unsigned char *src, unsigned char *dst, int src_width, int src_height, int dst_pitch)
{
    dim3 block(32,8);

    printf("block.x, block.y [%d %d] \n", block.x, block.y);

    int gridx = (src_width + block.x )/(block.x);
    int gridy = (src_height + block.y )/(block.y);

    printf("gridx, gridy [%d %d]\n", gridx, gridy);

    dim3 grid(gridx, gridy);

    unsigned char *Y, *UV;
    unsigned char *y  = src;
    unsigned char *uv = src+(src_width * src_height);
    int y_size = src_width * src_height * sizeof(unsigned char);
    int uv_size = y_size / 2;

    cudaMalloc((void**)&Y,  y_size);
    cudaMalloc((void**)&UV, uv_size);
    cudaMemcpy(Y, y, y_size, cudaMemcpyHostToDevice);
    cudaMemcpy(UV, uv, uv_size, cudaMemcpyHostToDevice);

    unsigned char *d_dst;
    int src_mem_size = sizeof(unsigned char ) * src_width * src_height * 3;
    cudaMalloc((void**)&d_dst, src_mem_size);
    cudaMemcpy(d_dst, d_dst, src_mem_size, cudaMemcpyHostToDevice);

    dev_nv12_to_rgb<<<grid,block>>>(Y, UV, src_width, src_width, d_dst, src_width, src_height, 3);

    cudaMemcpy(dst, d_dst, src_mem_size, cudaMemcpyDeviceToHost);

    cudaFree(d_dst);
    cudaFree(Y);
    cudaFree(UV);

    return true;
} 