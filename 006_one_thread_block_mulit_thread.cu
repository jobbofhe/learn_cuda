/**
 * 并行计算
 */

#include <stdio.h>
#include <iostream>
#include<sys/time.h>

using namespace std;

#define N (200000)

void add_cpu(int *a, int *b, int *c)
{
    int tid = 0;

    while(tid < N) 
    {
        c[tid] = a[tid] + b[tid];
        tid += 1;
        /* code */
    }
}

__global__ void add(int *a, int *b, int *c)
{
    int tid = blockIdx.x;

    while(tid < N) 
    {
        c[tid] = a[tid] + b[tid];
        tid += 1;
        /* code */
    }
}

// CPU 求和
int main_cpu() 
{
    int a[N], b[N], c[N];

    struct timeval tv1, tv2;

    
    for (int i = 0; i < N; i++)
    {
        a[i] = -i;
        b[i] = i*i;
    }

    gettimeofday(&tv1, NULL);
    add_cpu(a, b, c);
    gettimeofday(&tv2, NULL);
    float time = (1000000 * (tv2.tv_sec - tv1.tv_sec) + tv2.tv_usec- tv1.tv_usec)/1000.0;
    cout << "time cpu： " << time << "ms, num : " << c[N-1] << endl;
    
    return 0;
}

// GPU 求和
int main(int argc, char const *argv[]) 
{   
    int a[N], b[N], c[N];

    int *dev_a, *dev_b, *dev_c;

    struct timeval tv1, tv2;

    cudaMalloc((void**)&dev_a, N * sizeof(int));
    cudaMalloc((void**)&dev_b, N * sizeof(int));
    cudaMalloc((void**)&dev_c, N * sizeof(int));

    // 在CPU上为数组 a/b赋值
    // 这里在CPU就给输出数据赋初值，并没有特殊原因。事实上，如果在GPU上对数组赋值，这个步骤执行的会更快。
    // 但是这段代码的目的是说明如何在显卡上实现两个矢量的加法运算，因此我们仅仅将计算部分放在显卡上实现，
    // 输入则在CPU上进行。
    for(unsigned i = 0; i < N; ++i) 
    {
        a[i] = -i;
        b[i] = i*i;
    }

    cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(dev_c, c, N * sizeof(int), cudaMemcpyHostToDevice);

    gettimeofday(&tv1, NULL);

    // 调用kernel函数，<<<1,1>>>指gpu启动1个线程块，每个线程块中有1个线程
    // <<<256,1>>>指gpu启动256个线程块，每个线程块中有1个线程, 如果是这样，就会有一个问题：
    // 既然GPU将运行核函数的N个副本，那如何在代码中知道当前正在运行的是哪一个线程块？
    // 这个问题可以在代码中找出答案：
    // int tid = blockIdx.x
    // 乍一看，将一个没有定义的变量赋值给了变量tid,但是 blockIdx 是一个内置变量，在cuda运行是中已经定义了。
    // 这个变量把包含的值就是当前执行设备代码的的线程块索引。
    // 
    // 问题又来了，为什么不是写 int  tid = blockIdx呢？ 事实上，这是因为cuda支持二维的线程块数组，对于二维空间的计算问题，
    // 例如矩阵数学运算或者图像处理，使用二维索引往往回答来很大的便利，因为他可以避免将线性索引转换为矩形索引。
    add<<<1, 65535>>>(dev_a, dev_b, dev_c);

    gettimeofday(&tv2, NULL);
    float time = (1000000 * (tv2.tv_sec - tv1.tv_sec) + tv2.tv_usec- tv1.tv_usec)/1000.0;
    cout << "time gpu： " << time << "ms";


    cudaMemcpy(c, dev_c,  N * sizeof(int), cudaMemcpyDeviceToHost);
    cout << ", num : " << c[N-1] << endl;

    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);

    main_cpu();

    /* code */
    return 0;
}

// time gpu： 0.048ms
// time cpu： 1.248