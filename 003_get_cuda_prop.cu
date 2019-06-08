/**
 * 获取GPU属性
 */
#include <iostream>

using namespace std;

int main(int argc, char const *argv[]) 
{
    cudaDeviceProp prop;

    int count;

    // 获取有所少快GPU设备
    cudaGetDeviceCount(&count);

    for(unsigned i = 0; i < count; ++i) 
    {   
        // 获取GPU属性信息
        cudaGetDeviceProperties(&prop, i);
        cout << "name:      " << prop.name << endl;
        cout << "totalGlobalMem:      " << prop.totalGlobalMem << endl;
        cout << "sharedMemPerBlock: " << prop.sharedMemPerBlock << endl;
        cout << "regsPerBlock: " << prop.regsPerBlock << endl;
        cout << "warpSize: " << prop.warpSize << endl;
        cout << "memPitch: " << prop.memPitch << endl;
        cout << "canMapHostMemory: " << prop.canMapHostMemory << endl;
        cout << "pciDeviceID: " << prop.pciDeviceID << endl;
        cout << "tccDriver: " << prop.tccDriver << endl;
        cout << "----------------------------------------------------"<< endl;
    }

    // 设置当前使用那块GPU
    cudaSetDevice(count);

    return 0;
}