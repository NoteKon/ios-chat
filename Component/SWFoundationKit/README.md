# SWFoundationKit

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

SWFoundationKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```
pod 'SWFoundationKit'
```
Podfile 中使用 use_frameworks!

## Author

微微科技

## License

SWFoundationKit is available under the MIT license. See the LICENSE file for more info.

## Guides
+ [SWNetWorking](Doc/SWNetWorking/SWNetWorking.md)
+ [组件化资源加载](Doc/Bundle/Bundle.md)
+ [SWCacheManager](Doc/SWCacheManager)

## Release Version
+ 1.1.3
	+ 停用2进制打包
+ 0.4.8
	+ 动态获取App schemes
+ 0.3.8
	+ 添加 SWAES128加密
+ 0.3.7
	+  SWCacheManager 缓存统一管理类
+ 0.3.6
	+ SWNetWorking 统一添加登录授权token
+ 0.3.5
	+ 扩展SWError 
+ 0.3.4
	+ 封装统一错误处理类SWError 
+ 0.3.3
	+  封装网络统一回调，业务请求Code状态码
+ 0.3.2
   + 扩展UIImageView图片加载方法
+ 0.3.1
	+ 扩展String常用方法
+ 0.3.0
	+ 添加SWAppInfo, SWDocumentPath,UIDevice+SWExtension
+ 0.2.9
	+  封装KeyChain存储框架
+ 0.2.8 
   + 添加图片统一模型SWBaseImageModel 
+ 0.2.7
	+ 添加SWBaseRequestModel、SWBaseResponseModel 统一解析模块
+ 0.2.5
	+ 更新常用常量定义 
+ 0.2.4
	+ 扩展UIView位置获取方法 
+ 0.2.3
	+ 修改 Bundle 扩展加载不到bundle使用main bundle
+ 0.2.2
	+  SWConst 公开权限访问
+ 0.2.1
	+ UIColor 添加 RGB，HEx颜色转换扩展
	+ UIFont 添加字体扩展
	+ SWConst 添加常用常量定义
+ 0.2.0
	+ Bundle添加扩展组件化加载storyboard，image，多语言方法
+ 0.1.9
 +  SWNetWorking 扩展Alamofire纯数组入参问题
+ 0.1.6
	+  SWNetWorking Get请求编码方式改成 URLEncoding.default，Content-Type 为application/json
+ 0.1.5
	+ SWNetWorking 参数默认格式改成json
+ 0.1.4
 +  SWNetWorking添加线程管理
+ 0.1.3
	+ 公开SWRequestResponse属性
+ 0.1.2
	+ 封装 Alamofire 网络请求 
+ 0.1.1
 + 修复 swlog()方法无法使用问题
+ 0.1.0
	+  日志打印swlog("test")
