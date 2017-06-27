# iOSTopFaceSDKSample
TopFaceSDK iOS版本 示例工程
<br>
[官网](http://www.voome.cn)
<br>
## 开发环境说明 ##
<br>
Xcode7.0及以上版本
<br>
## 支持平台说明 ##
<br>
支持iOS7.0及以上系统
<br>
## 接入流程 ##
### 依赖库导入 ###
<br>
人脸标注模块，所依赖的库文件为: iOSTopFaceSDK.framework，需添加到iOS项目中；
在Build Phases->Copy Bundle Resource将iOSTopFaceSDK.framework中的resource.bundle文件添加至工程中。
<br>
### 授权认证 ###
<br>
调用TopFaceSDKHandle的setLicense:(NSString *)Client_id andSecret:(NSString *)Clicent_secret;
说明：申请 client_id 和 client_secret 后调用此函数获得授权。不调用认证函数无法使用人脸检测功能，正确调用认证函数即可正常使用。
<br>
<br>
[获取License](http://www.voome.cn/register/index.shtml)
<br>
### SDK初始化 ###
<br>
在检测之前调用调用TopFaceSDKHandle的Engine_InitWithFocus:(float)focus_length初始化检测上下文
<br>
## 接口定义和使用说明 ##
```Objective-C
1.	//设置用户ID和secret
- (void)setLicense:(NSString *)Client_id andSecret:(NSString *)Clicent_secret;
2.	//初始化检测器 ，参数focus_length：等效焦距，默认值设置为31，返回值：0表示初始化成功，-1表示初始化失败
- (int)Engine_InitWithFocus:(float)focus_length;
3.	//人脸检测，参数buffer：传入的图片 ，返回值：长度为151的数组，第0~135位表示68个人脸特征点二维像素坐标，原点是传入图像的左上角，特征点代表意义参考示意图；第136~138位表示人脸鼻尖处在相机坐标系下的位置数据，坐标系定义：x轴向右,y轴向下,z轴向前；第139~141位表示人脸相对相机的姿态数据，单位是弧度，依次定义为：pitc俯仰角、roll翻滚角、yaw偏航角；第142位表示置信度.
- (NSArray *)DynamicDetect:(CMSampleBufferRef)buffer;

```
<br>
## 68个人脸特征点二维像素坐标图 ##
![](https://github.com/topplus/iOSTopFaceSDKSample/raw/master/images/feature.jpg)
## 开源协议 ##
[LICENSE](https://github.com/topplus/iOSTopFaceSDKSample/raw/master/LICENSE)
## 开发者微信群 ##
![](https://github.com/topplus/iOSTopFaceSDKSample/raw/master/images/voomeGroup.png)
## 联系我们 ##
<br>
商务合作sales@topplusvision.com
<br>
媒体合作pr@topplusvision.com
<br>
技术支持support@topplusvision.com
