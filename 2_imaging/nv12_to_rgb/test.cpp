/*
* @Author: jobbofhe
* @Date:   2019-08-28 16:23:41
* @Last Modified by:   Administrator
* @Last Modified time: 2019-09-27 19:04:15
*/

/**
 * 读NV12文件，转换为RGB
 */
#include <iostream>
#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/video/video.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <opencv2/imgproc/imgproc.hpp>

#include <opencv2/cudaimgproc.hpp>

#include <sys/time.h>

#include <time.h>
#include "nv12_to_rgb.h"

using namespace std;
using namespace cv;

int main(void)
{
    int src_width = 1920;
    int src_height = 1088;
    struct  timeval tv0, tv1, tv2;

    char *fileName = (char*)"./nv12_0.yuv";

    unsigned char *buff = (unsigned char *)malloc(sizeof(unsigned char)*src_width*src_height*3/2);

    // read yuv file 
    FILE *yuv_file = fopen(fileName,"rb"); 
    int i = 0;
    while(!feof(yuv_file))  
    {
        unsigned char  pixel= getc(yuv_file);
        buff[i++] = pixel;
    }

    // for (int i = 0; i < 100; ++i)
    // {
    //     printf("%u ", buff[i]);
    // }

    // lib YUV  change format
    unsigned char *srcYuv = buff;    

    unsigned char *dst = (unsigned char *)malloc(sizeof(unsigned char)*1920*1088*3);
    unsigned char *dst_cpu = (unsigned char *)malloc(sizeof(unsigned char)*1920*1088*3);

    gettimeofday(&tv1, NULL);

    nv12_to_rgb(srcYuv, dst, src_width, src_height, src_width);

    gettimeofday(&tv2, NULL);
    float time = (1000000 * (tv2.tv_sec - tv1.tv_sec) + tv2.tv_usec- tv1.tv_usec)/1000.0;

    printf("耗时： %f ms\n", time);

    // for (int i = 0; i < 100; ++i)
    // {
    //     printf("%u ", dst[i]);
    // }
    cv::Mat mat;
    cv::Mat mat_rgb(src_height, src_width, CV_8UC3, dst);
    cvtColor(mat_rgb, mat, COLOR_RGB2BGR);

    char name[32];
    sprintf(name, "yuv_rgb.jpg");
    cv::imwrite(name, mat_rgb);
}