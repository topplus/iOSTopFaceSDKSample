//
//  ViewController.m
//  iOSTopFaceSDKSample
//
//  Created by Jeavil on 17/1/20.
//  Copyright © 2017年 L. All rights reserved.
//

#import "ViewController.h"
#import <iOSTopFaceSDK/TopFaceSDKHandle.h>
#import <AVFoundation/AVFoundation.h>
#import "opencv2/highgui/ios.h"
#import "opencv2/opencv.hpp"
#import "opencv2/highgui/cap_ios.h"

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
    
    AVCaptureSession *session;
    AVCaptureDeviceInput *DeviceInput;
    TopFaceSDKHandle *handle;

}
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initDetector];
    [self initCapture];
    [session startRunning];
}

- (void)initDetector{
    handle = [[TopFaceSDKHandle alloc]init];
    //[handle setLicense:@"您的client_id" andSecret:@"您的client_secret"];
    NSLog(@"status = %d",[handle Engine_InitWithFocus:31]);
}

- (void)initCapture{
    
    session = [[AVCaptureSession alloc]init];
    session.sessionPreset = AVCaptureSessionPreset640x480;
    //找到合适的device
    AVCaptureDevice *device = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
    //用device创建一个input
    NSError *error = nil;
    DeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!DeviceInput) {
        NSLog(@"inputcuowu");
    }
    [session addInput:DeviceInput];
    //创建一个output对象
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc]init];
    //配置output对象
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [session addOutput:output];
    
}

#pragma mark -- captureOutputDelegate
/**获得视频帧*/
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

   [self updateImageFromImagebuffer:sampleBuffer];
}
/**获取设备*/
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

//对视频帧进行实时处理
- (void)updateImageFromImagebuffer:(CMSampleBufferRef)buffer{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(buffer);
    // Lock the base address of the pixel buffer
    
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    //
    //        // Get the pixel buffer width and heigh
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    //  NSLog(@"width=%zu,height=%zu",width,height);
    
    cv::Mat mat((int)height, (int)width, CV_8UC4, baseAddress, 0);
    cv::Mat transfMat;
    cv::transpose(mat, transfMat);
    cv::Mat RGBimage,grayImage;
    cv::cvtColor(transfMat, RGBimage, CV_BGR2RGB);
    //cv::cvtColor(RGBimage, grayImage, CV_RGB2GRAY);
    
    double vpose[6];
    
    std::vector<cv::Point2f> tempPoints;
    NSArray *data = [handle DynamicDetect:buffer];
    //
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    if (data.count > 144) {
        for (int i = 0; i < 68; i++)
        {//miao dian
            cv::Point2f tempPoint;
            tempPoint.x = [data[i * 2] doubleValue];
            
            tempPoint.y = [data[(i * 2) + 1] doubleValue];
            
            cv::circle(RGBimage, tempPoint, 4, cv::Scalar(0,255,0),-1);

        }
        cv::Point2f tempPoint1,tempPoint2,tempPoint3,tempPoint4;
        tempPoint1.x = [data[143] doubleValue];
        tempPoint1.y = [data[144] doubleValue];
        tempPoint2.x = [data[145] doubleValue];
        tempPoint2.y = [data[146] doubleValue];
        tempPoint3.x = [data[147] doubleValue];
        tempPoint3.y = [data[148] doubleValue];
        tempPoint4.x = [data[149] doubleValue];
        tempPoint4.y = [data[150] doubleValue];
        
 
        cv::line(RGBimage, tempPoint1, tempPoint1, cv::Scalar(0, 0, 255), 2);
        cv::line(RGBimage, tempPoint1, tempPoint2, cv::Scalar(0, 255, 0), 2);
        cv::line(RGBimage, tempPoint1, tempPoint3, cv::Scalar(0, 0, 255), 2);
        cv::line(RGBimage, tempPoint1, tempPoint4, cv::Scalar(255, 0, 0), 2);
      
    }
    
    NSLog(@"%d",RGBimage.rows);
    UIImage *tempImage = [self UIImageFromCVMat:RGBimage];
    dispatch_async(dispatch_get_main_queue(), ^{
        _showImageView.image = tempImage;
    });
//
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
