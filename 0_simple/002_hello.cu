
#include <stdio.h>
#include <unistd.h>


// __global__ 修饰符，将告诉编译器，函数在设备(GPU)上运行而不是在主机(CPU)上运行
__global__ void kernel(void)
{
    printf("Hello world!\n");
}

int main(void)
{
    while(1)
    {
        kernel<<<1,1>>>();

        sleep(1);
    }   

    return 0;
}

// compile
// nvcc hello.cu -o hello