#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include <stdio.h>
#include <iostream>

#include "yuv_resize.h"

// __global__ void device_yuv_resize(unsigned char *d_y, unsigned char *d_uv, int step_y, 
//     int step_uv, unsigned char *d_dst, int dst_width, int dst_height)
// {
//     const int tidx = blockIdx.x * blockDim.x + threadIdx.x;
//     const int tidy = blockIdx.y * blockDim.y + threadIdx.y;

//     if (tidx < dst_width && tidy < dst_height)
//     {
//         int index_y, index_u, index_v;
//         unsigned char Y00, Y01, Y10, Y11, U00, V01, U10, V11, Y , U, V;
//         index_y = tidy * step_y + tidx;    

//         // if (tidx % 2 == 0 && tidx < 3)
//         // {
//         //     printf("%d %d %d %d\n", tidy*step_y + tidx, tidy*step_y + tidx + 1, (tidy+1)*step_y + tidx, (tidy+1)*step_y + tidx + 1);
//         // }

//         if (tidx % 2 == 0)
//         {
//             Y00 = d_y[tidy*step_y + tidx];
//             Y01 = d_y[tidy*step_y + tidx + 1];
//             Y10 = d_y[(tidy+1)*step_y + tidx];
//             Y11 = d_y[(tidy+1)*step_y + tidx + 1];

//             Y = (Y00 + Y01 + Y10 + Y11) / 4;
//         }

//         if (tidx % 2 == 0)
//         {
//             U00 = d_uv[tidy / 2 * step_uv + tidx];
//             V01 = d_uv[tidy / 2 * step_uv + tidx + 1];

//             U10 = d_uv[(tidy / 2 + 1) * step_uv + tidx];
//             V11 = d_uv[(tidy / 2 + 1) * step_uv + tidx + 1];

//             U = (U00 + U10) / 2;
//             V = (V01 + V11) / 2;
//         }

//         int y_size = dst_width * dst_height;

//         d_dst[tidy*dst_width + tidx] = uchar(Y);
//         d_dst[y_size + tidy/2*dst_width + tidx] = uchar (U);
//         d_dst[y_size + tidy/2*dst_width + tidx] = uchar (V);
//     }
// }

// bool host_yuv_resize(unsigned char *src, int src_width, int src_height, unsigned char *dst, int dst_width, int dst_height)
// {
//     dim3 block(32,8);
//     // int gridx = (src_width + block.x )/(block.x);
//     // int gridy = (src_height + block.y )/(block.y);

//     int gridx = (dst_width + block.x )/(block.x);
//     int gridy = (dst_height + block.y )/(block.y);

//     dim3 grid(gridx, gridy);

//     unsigned char *y  = src;
//     unsigned char *uv = src+(src_width * src_height);
//     int y_size = src_width * src_height * sizeof(unsigned char);
//     int uv_size = y_size / 2;

//     unsigned char *d_y, *d_uv;
//     cudaMalloc((void**)&d_y,  y_size);
//     cudaMalloc((void**)&d_uv, uv_size);
//     cudaMemcpy(d_y, y, y_size, cudaMemcpyHostToDevice);
//     cudaMemcpy(d_uv, uv, uv_size, cudaMemcpyHostToDevice);

//     unsigned char *d_dst;
//     int yuv_size = sizeof(unsigned char ) * dst_width * dst_height * 3 / 2;
//     cudaMalloc((void**)&d_dst, yuv_size);
//     cudaMemcpy(d_dst, d_dst, yuv_size, cudaMemcpyHostToDevice);

//     device_yuv_resize<<<grid,block>>>(d_y, d_uv, src_width, src_width, src_width, src_height, d_dst, dst_width, dst_height);

//     cudaMemcpy(dst, d_dst, yuv_size, cudaMemcpyDeviceToHost);

//     for (int i = 0; i < 1000; i++)
//     {
//         printf("%d ", dst[i]);
//     }

//     cudaFree(d_dst);
//     cudaFree(d_y);
//     cudaFree(d_uv);

//     return true;
// } 

/*
__global__ void device_yuv_resize(unsigned char *d_y, unsigned char *d_uv, int step_y, int step_uv, 
    int src_width, int src_height, unsigned char *d_dst, int dst_width, int dst_height)
{
    const int tidx = blockIdx.x * blockDim.x + threadIdx.x;
    const int tidy = blockIdx.y * blockDim.y + threadIdx.y;

    unsigned char Y00, Y01, Y10, Y11, U00, U01, U10, U11, V00, V01, V10, V11, Y , U, V;

    if (tidx < src_width && tidy < src_height)
    {
        if (tidx % 2 == 0 && tidy % 2 == 0)
        {
            Y00 = d_y[tidy*step_y + tidx];
            Y01 = d_y[tidy*step_y + tidx + 1];
            Y10 = d_y[(tidy+1)*step_y + tidx];
            Y11 = d_y[(tidy+1)*step_y + tidx + 1];

            // printf("%d %d  %d %d\n", tidy*step_y + tidx, tidy*step_y + tidx + 1, (tidy+1)*step_y + tidx, (tidy+1)*step_y + tidx + 1);

            Y = (unsigned char)(Y00 + Y01 + Y10 + Y11) / 4;

            d_dst[tidy/2*dst_width + tidx/2] = uchar(Y);

            // if ((tidy/2*dst_width + tidx/2)  > 522200)
            // {
            //     printf("%6d ", tidy/2*dst_width + tidx/2);
            // }
        }

        // if (tidy < (src_height / 2))
        // {
            if (tidx % 4 == 0 && tidy % 2 == 0)
            {
                U00 = d_uv[tidy * step_uv + tidx];
                U01 = d_uv[tidy * step_uv + tidx + 2];
                U10 = d_uv[(tidy + 1) * step_uv + tidx];
                U11 = d_uv[(tidy + 1) * step_uv + tidx + 2];

                V00 = d_uv[tidy * step_uv + tidx + 1];
                V01 = d_uv[tidy * step_uv + tidx + 3];
                V10 = d_uv[(tidy + 1) * step_uv + tidx + 1];
                V11 = d_uv[(tidy + 1) * step_uv + tidx + 3];

                U = (U00 + U01 + U10 + U11) / 4;
                V = (V00 + V01 + V10 + V11) / 4; 

                int y_size = dst_width * dst_height;
                if ((tidy/2*dst_width + tidx/4) % 2 == 0)
                {
                    d_dst[y_size + tidy/2*dst_width + tidx/4] = uchar (U);
                    d_dst[y_size + tidy/2*dst_width + tidx/4 + 1] = uchar (V);

                    if ((tidy/2*dst_width + tidx/4) > 261100)
                    {
                        printf("%6d ", tidy/2*dst_width + tidx/4);
                    }
                    
                }
            }
        // }
    }    
}
*/

/**
 * 基于GPU 做 YUV (NV12)数据压缩，压缩至原来的一般 1920x1080 --> 960x540
 * @param d_y        [Y 数据]
 * @param d_uv       [UV 数据]
 * @param step_y     [Y 数据的宽度]
 * @param step_uv    [uv 数据的宽度]
 * @param src_width  [原始数据宽]
 * @param src_height [原始数据高]
 * @param d_dst      [压缩后的yuv 输出参数]
 * @param dst_width  [压缩后的宽]
 * @param dst_height [压缩后的高]
 */
__global__ void device_yuv_resize(unsigned char *d_y, unsigned char *d_uv, int step_y, int step_uv, 
    int src_width, int src_height, unsigned char *d_dst, int dst_width, int dst_height)
{
    const int tidx = blockIdx.x * blockDim.x + threadIdx.x;
    const int tidy = blockIdx.y * blockDim.y + threadIdx.y;

    unsigned char Y00, Y01, Y10, Y11, U00, U01, U10, U11, V00, V01, V10, V11, Y , U, V;

    if (tidx < src_width && tidy < src_height)
    {
        if (tidx % 2 == 0 && tidy % 2 == 0)
        {
            Y00 = d_y[tidy*step_y + tidx];
            Y01 = d_y[tidy*step_y + tidx + 1];
            Y10 = d_y[(tidy+1)*step_y + tidx];
            Y11 = d_y[(tidy+1)*step_y + tidx + 1];

            Y = uchar((Y00 + Y01 + Y10 + Y11) / 4);

            d_dst[tidy/2*dst_width + tidx/2] = uchar(Y);
        }

        if (tidx % 4 == 0 && tidy % 4 == 0)
        {
            U00 = d_uv[tidy/2 * step_uv + tidx];
            U01 = d_uv[tidy/2 * step_uv + tidx + 2];
            U10 = d_uv[(tidy/2 + 1) * step_uv + tidx];
            U11 = d_uv[(tidy/2 + 1) * step_uv + tidx + 2];

            V00 = d_uv[tidy/2 * step_uv + tidx + 1];
            V01 = d_uv[tidy/2 * step_uv + tidx + 3];
            V10 = d_uv[(tidy/2 + 1) * step_uv + tidx + 1];
            V11 = d_uv[(tidy/2 + 1) * step_uv + tidx + 3];

            U = (U00 + U01 + U10 + U11) / 4;
            V = (V00 + V01 + V10 + V11) / 4; 

            int y_size = dst_width * dst_height;
            if ((tidy/4*dst_width + tidx/2) % 2 == 0)
            {
                d_dst[y_size + tidy/4*dst_width + tidx/2] = uchar (U);
                d_dst[y_size + tidy/4*dst_width + tidx/2 + 1] = uchar (V);
            }
        }
    }    
}

/**
 * Host 接口 压缩YUV数据
 * @param  src        [YUV 原始数据]
 * @param  src_width  [原始宽]
 * @param  src_height [原始高]
 * @param  dst        [压缩后的YUV数据， 输出参数]
 * @param  dst_width  [压缩后宽]
 * @param  dst_height [研所后高]
 * @return            [description]
 */
bool host_yuv_resize(unsigned char *src, int src_width, int src_height, unsigned char *dst, int dst_width, int dst_height)
{
    dim3 block(32,8);
    int gridx = (src_width + block.x )/(block.x);
    int gridy = (src_height + block.y )/(block.y);
    dim3 grid(gridx, gridy);

    unsigned char *y  = src;
    unsigned char *uv = src+(src_width * src_height);
    int y_size = src_width * src_height * sizeof(unsigned char);
    int uv_size = y_size / 2;

    unsigned char *d_y, *d_uv;
    cudaMalloc((void**)&d_y,  y_size);
    cudaMalloc((void**)&d_uv, uv_size);
    cudaMemcpy(d_y, y, y_size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_uv, uv, uv_size, cudaMemcpyHostToDevice);

    unsigned char *d_dst;
    int yuv_size = sizeof(unsigned char ) * dst_width * dst_height * 3 / 2;
    cudaMalloc((void**)&d_dst, yuv_size);
    cudaMemcpy(d_dst, d_dst, yuv_size, cudaMemcpyHostToDevice);

    device_yuv_resize<<<grid,block>>>(d_y, d_uv, src_width, src_width, src_width, src_height, d_dst, dst_width, dst_height);

    cudaMemcpy(dst, d_dst, yuv_size, cudaMemcpyDeviceToHost);

    cudaFree(d_dst);
    cudaFree(d_y);
    cudaFree(d_uv);

    return true;
} 

/**
 * GPU 端核函数：NV12 数据转RGB
 * @param pYdata   [Y数据]
 * @param pUVdata  [UV数据]
 * @param stepY    [Y数据的宽度]
 * @param stepUV   [UV数据的宽度]
 * @param pImgData [输出参数 RGB数据]
 * @param width    [输出宽]
 * @param height   [输出高]
 * @param channels [RGB 通道数]
 */
__global__ void dev_nv12_to_rgb(unsigned char *pYdata, unsigned char *pUVdata, int stepY, 
    int stepUV, unsigned char *pImgData, int width, int height, int channels)
{
    const int tidx = blockIdx.x * blockDim.x + threadIdx.x;
    const int tidy = blockIdx.y * blockDim.y + threadIdx.y;

    if (tidx < width && tidy < height)
    {
        int index_y, index_u, index_v;
        unsigned char Y, U, V;
        index_y = tidy * stepY + tidx;    
        Y = pYdata[index_y];

        if (tidx % 2 == 0)
        {
            index_u = tidy / 2 * stepUV + tidx;
            index_v = tidy / 2 * stepUV + tidx + 1;
            U = pUVdata[index_u];
            V = pUVdata[index_v];
        }
        else if (tidx % 2 == 1)
        {
            index_v = tidy / 2 * stepUV + tidx;
            index_u = tidy / 2 * stepUV + tidx - 1;
            U = pUVdata[index_u];
            V = pUVdata[index_v];
        }

        pImgData[(tidy*width + tidx) * channels + 2] = uchar (Y + 1.402 * (V - 128));
        pImgData[(tidy*width + tidx) * channels + 1] = uchar (Y - 0.34413 * (U - 128) - 0.71414*(V - 128));
        pImgData[(tidy*width + tidx) * channels + 0] = uchar (Y + 1.772*(U - 128));
    }
}

/**
 * Host 接口： YUV 转 RGB
 * @param  src        [原始YUV]
 * @param  dst        [转完之后的RGB数据]
 * @param  src_width  [原始宽]
 * @param  src_height [原始高]
 * @param  dst_pitch  [转换后的宽度]
 * @return            [description]
 */
bool nv12_to_rgb(unsigned char *src, unsigned char *dst, int src_width, int src_height, int dst_pitch)
{
    dim3 block(32,8);
    int gridx = (src_width + block.x )/(block.x);
    int gridy = (src_height + block.y )/(block.y);
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
