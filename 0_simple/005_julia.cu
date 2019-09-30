
//1）CUDA和OPENCV联系起来；（test1.cu)
// 需要gui环境

#include <iostream>
#include <unistd.h>
#include "opencv2/core/core.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <stdio.h>
#include <assert.h>
#include <cuda_runtime.h>

using namespace std;
using namespace cv;
#define N 250
//test1的kernel
__global__ void test1kernel(int *t)
{
    int x = blockIdx.x;
    int y = blockIdx.y;
    int offset = x+y*gridDim.x; 
    t[offset] =255-t[offset];
 
}
int main(void)
{    
    //step0.数据和内存初始化
    Mat src = imread("opencv-logo.png",0);
    resize(src,src,Size(N,N));
    int *dev_t;
    int t[N*N];
    Mat dst = Mat(N,N,CV_8UC3);
    for (int i=0;i<N*N;i++)
    {
        t[i]  =(int)src.at<char>(i/N,i%N);
    }
    checkCudaErrors(cudaMalloc((void **)&dev_t, sizeof(int)*N*N));
    //step1.由cpu向gpu中导入数据
    checkCudaErrors(cudaMemcpy(dev_t, t,sizeof(int)*N*N, cudaMemcpyHostToDevice));
    //step2.gpu运算
    dim3 grid(N,N);
    test1kernel<<<grid,1>>>(dev_t);
    //step3.由gpu向cpu中传输数据
    checkCudaErrors(cudaMemcpy(t, dev_t,sizeof(int)*N*N, cudaMemcpyDeviceToHost));
    //step4.显示结果
    for (int i=0;i<N;i++)
    {
        for (int j=0;j<N;j++)
        {
             int offset = i*N+j;
             for (int c=0;c<3;c++)
             {
                 dst.at<Vec3b>(i,j)[c] =t[offset];
             }
        }
    }
    //step5，释放资源
    checkCudaErrors(cudaFree(dev_t));
    // imshow("dst",dst);
    waitKey();
    return 0;
}