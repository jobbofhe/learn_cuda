#include <stdio.h>
#include <iostream>
#include <unistd.h>

using namespace std;

/**
 * 矩阵相乘,假设是方阵
 * @param Md    [矩阵]
 * @param Nd    [矩阵]
 * @param Pd    [结果矩阵]
 * @param width [矩阵宽度]
 */
__global__ void matrix_mulit_kernel(float *Md, float *Nd, float *Pd, int width)
{
    // 二维的线程块索引
    // main 调用的时候，block的大小是16x16
    // 即 threadIdx([0,15], [0,15]), 运行之后，将会有16个线程块同时执行这段代码
    // 第一个线程 threadIsx.x = 0, threadIsx.y = 0
    // 也即 for循环的运算的是 矩阵 Md 的第0行和 矩阵 N 的第0列相乘的结果。
    // 
    int tx = threadIdx.x;
    int ty = threadIdx.y;

    float pValue = 0;

    for (int i = 0; i < width; i++)
    {   
        // ty 在第 0 个线程中所以取的是矩阵第一行的值
        float m = Md[ty*width + i];

        // tx 在第 0 个线程中
        // i= 0 时，取第一列第一个元素
        // i= 1 时，取第二列第一个元素
        // ……
        float n = Nd[i*width + tx]; 

        // M 的行乘以 N 的列 并且相加
        pValue += m*n; 
    }

    Pd[ty*width+tx] = pValue;
}

int main(int argc, char const *argv[]) 
{
    int width = 16;

    dim3 dimBlock(width, width);
    dim3 dimGrid(1, 1);

    matrix_mulit_kernel<<<dimGrid, dimBlock>>>();

    return 0;
}

