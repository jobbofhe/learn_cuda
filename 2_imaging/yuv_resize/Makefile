
INCLUDE  = .
INCLUDE  = include
INCLUDE += /usr/lib/include
INCLUDE += /usr/local/include/vision
INCLUDE += /usr/local/include/vision/vision_video 
INCLUDE += /usr/local/include/vision/vision_imgproc
INCLUDE += /usr/local/include/opencv2

INCLUDE += /usr/local/cuda/include

INCPATH = $(addprefix -I, $(INCLUDE))

LIB64 = \
		/usr/local/lib64/libopencv_videoio.so.3.4.3 \
		/usr/local/lib64/libopencv_imgcodecs.so.3.4.3 \
		/usr/local/lib64/libopencv_imgproc.so.3.4.3 \
		/usr/local/lib64/libopencv_core.so.3.4.3 \
		/usr/local/lib64/libopencv_highgui.so.3.4.3 \
		/usr/local/lib64/libopencv_photo.so.3.4.3 \
		/usr/local/lib64/libopencv_cudaimgproc.so.3.4.3 \
		-L/usr/local/cuda/lib64 -lcuda -lcudart -lcublas -lcurand

CC = gcc
CXX = /usr/bin/g++
NVCC = /usr/local/cuda/bin/nvcc

# Enable debug mode
DEFINES		  += -DSC_ENABLE_DEBUG

CXXFLAGS = -O3 -std=c++0x -fPIC -Wno-write-strings $(DEFINES)

CFLAGS = -O3 -fPIC -Wno-write-strings $(DEFINES)

SOURCE_CPP = $(wildcard *.h *.cpp)

SOURCE_CU = $(wildcard *.cu)

OUT = write_video

all: main 

main:	
	$(NVCC) -c $(SOURCE_CU)
	$(CXX) -c $(CXXFLAGS) $(SOURCE_CPP) $(INCPATH)
	$(CXX) *.o  -o $(OUT)  $(INCPATH) $(LIB64) 

clean:
	rm -f *.o
	rm -rf $(OUT)


# INCLUDE  = .
# INCLUDE  = include
# INCLUDE += /usr/lib/include
# INCLUDE += /usr/local/include/vision
# INCLUDE += /usr/local/include/vision/vision_video 
# INCLUDE += /usr/local/include/vision/vision_imgproc
# INCLUDE += /usr/local/include/opencv2

# INCLUDE += /usr/local/cuda/include

# INCPATH = $(addprefix -I, $(INCLUDE))

# LIB64 = \
# 		-L/usr/local/cuda/lib64 -lcuda -lcudart -lcublas -lcurand  \
# 		-L//icooper/vision_dev/shuqiang/envs/vision_run_envs/other/usrlib64_libx -lnvidia-encode

# # 		/usr/local/lib64/libopencv_videoio.so.3.4.3 \
# # 		/usr/local/lib64/libopencv_imgcodecs.so.3.4.3 \
# # 		/usr/local/lib64/libopencv_imgproc.so.3.4.3 \
# # 		/usr/local/lib64/libopencv_core.so.3.4.3 \
# # 		/usr/local/lib64/libopencv_highgui.so.3.4.3 \
# # 		/usr/local/lib64/libopencv_photo.so.3.4.3 \
# # 		/usr/local/lib64/libopencv_cudaimgproc.so.3.4.3 \

# CC = gcc
# CXX = /usr/bin/g++
# NVCC = /usr/local/cuda/bin/nvcc

# # Enable debug mode
# DEFINES		  += -DSC_ENABLE_DEBUG

# CXXFLAGS = -O3 -std=c++0x -fPIC -Wno-write-strings $(DEFINES)

# CFLAGS = -O3 -fPIC -Wno-write-strings $(DEFINES)

# SOURCE_CPP = $(wildcard *.h *.cpp)

# SOURCE_CU = $(wildcard *.cu)

# OUT = write_video

# all: main 

# main:	
# 	$(NVCC) -c $(SOURCE_CU)
# 	$(CXX) -c $(CXXFLAGS) $(SOURCE_CPP) $(INCPATH)
# 	$(CXX) *.o  -o $(OUT)  $(INCPATH) $(LIB64) 

# clean:
# 	rm -f *.o
# 	rm -rf $(OUT)
