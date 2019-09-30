#include <stdio.h>
#include <iostream>
#include <unistd.h>

using namespace std;


__global__ void add(int a, int b, int *c)   //kernel函数，在gpu上运行。
{
    *c = a + b;
}
 
int main()
{
    while(1)
    {
        int c;
        int *dev_c;

        // 分配gpu的内存，第一个参数指向新分配内存的地址，第二个参数是分配内存的大小
        cudaMalloc((void**)&dev_c, sizeof(int));    
        cudaMemset(dev_c, 0, sizeof(int))

        // 调用kernel函数，<<<1,1>>>指gpu启动1个线程块，每个线程块中有1个线程
        add<<<1,1>>>(2, 7, dev_c);  

        // 将gpu上的数据复制到主机上，
        // 即从dev_c指向的存储区域中将sizeof(int)个字节复制到&c指向的存储区域
        cudaMemcpy(&c, dev_c, sizeof(int), cudaMemcpyDeviceToHost); 

        cout << "2 + 7 = " << c << endl;

        //释放cudaMalloc分配的内存
        cudaFree(dev_c);

        sleep(2);
        
    }
    return 0;
}