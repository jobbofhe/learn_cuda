/*
* @Author: jobbofhe
* @Date:   2019-08-28 16:23:41
* @Last Modified by:   Administrator
* @Last Modified time: 2019-09-30 13:48:13
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
#include "yuv_resize.h"

using namespace std;
using namespace cv;

void sc_write_yuv(int height, int width, unsigned char *data, char *filePath)
{
    if(height == 0 || width == 0 || NULL == filePath)
    {
        return;
    }
    unsigned char* buf = (unsigned char*)malloc(sizeof(unsigned char) *height * width * 3/2);
    memset(buf, 0, height * width * 3/2);

    char fileName[255];
    sprintf(fileName, "%s", filePath);
    FILE *yuv_file = fopen(fileName,"wb+");
    if (NULL == yuv_file)
    {
        return;
    }

    memcpy(buf, data, width * height * 3/2);
    fwrite(buf, 1, height * width * 3/2, yuv_file);
    free(buf);
    buf = NULL;

    fclose(yuv_file);
}

void sc_write_y_data(int width, int height, unsigned char *data, char *filePath)
{
    if(height == 0 || width == 0 || NULL == filePath)
    {
        return;
    }
    unsigned char* buf = (unsigned char*)malloc(sizeof(unsigned char) *height * width);
    memset(buf, 0, height * width);

    char fileName[255];
    sprintf(fileName, "%s", filePath);
    FILE *yuv_file = fopen(fileName,"wb+");
    if (NULL == yuv_file)
    {
        return;
    }

    memcpy(buf, data, width * height);
    fwrite(buf, 1, height * width, yuv_file);
    free(buf);
    buf = NULL;

    fclose(yuv_file);
}


int main(int argc, char const *argv[])
{
    if (argc < 2)
    {
        printf("==== Run commond: ./write_video yuv_file\n");
        return 0;
    }
    int src_width = 1920;
    int src_height = 1088;
    int scale_width = src_width / 2;
    int scale_height = src_height / 2;
    struct  timeval tv0, tv1, tv2;

    const char *fileName = argv[1]; //(char*)"./nv12_0.yuv";
    unsigned char *buff = (unsigned char *)malloc(sizeof(unsigned char)*src_width*src_height*3/2);

    // read yuv file 
    FILE *yuv_file = fopen(fileName,"rb"); 
    int i = 0;
    while(!feof(yuv_file))  
    {
        unsigned char  pixel= getc(yuv_file);
        buff[i++] = pixel;
    }

    // lib YUV  change format
    unsigned char *srcYuv = buff;    

    unsigned char *dst_rgb = (unsigned char *)malloc(sizeof(unsigned char)*scale_width*scale_height*3);
    unsigned char *dst_resize = (unsigned char *)malloc(sizeof(unsigned char)*scale_width*scale_height*3/2);

    gettimeofday(&tv1, NULL);
    host_yuv_resize(srcYuv, src_width, src_height, dst_resize, scale_width, scale_height);
    gettimeofday(&tv2, NULL);
    float time = (1000000 * (tv2.tv_sec - tv1.tv_sec) + tv2.tv_usec- tv1.tv_usec)/1000.0;
    printf("压缩耗时： %f ms\n", time);

    char *filePath = "./y_data.yuv";
    sc_write_y_data(scale_width, scale_height, dst_resize, filePath);
    filePath = "./yuv_data.yuv";
    sc_write_yuv(scale_width, scale_height, dst_resize, filePath);

    gettimeofday(&tv1, NULL);
    nv12_to_rgb(dst_resize, dst_rgb, scale_width, scale_height, scale_width);
    gettimeofday(&tv2, NULL);
    time = (1000000 * (tv2.tv_sec - tv1.tv_sec) + tv2.tv_usec- tv1.tv_usec)/1000.0;

    printf("转RGB耗时： %f ms\n", time);

    // for (int i = 0; i < 100; ++i)
    // {
    //     printf("%u ", dst_resize[i]);
    // }
    cv::Mat mat;
    cv::Mat mat_rgb(scale_height, scale_width, CV_8UC3, dst_rgb);
    cvtColor(mat_rgb, mat, COLOR_RGB2BGR);

    char name[32];
    sprintf(name, "resize_yuv.jpg");
    cv::imwrite(name, mat_rgb);

    if (dst_rgb)
    {
        free(dst_rgb);
    }
    if (dst_resize)
    {
        free(dst_resize);
    }
}