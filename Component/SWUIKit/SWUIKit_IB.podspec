#
# Be sure to run `pod lib lint SWUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SWUIKit_IB'
  s.version          = '1.7.2'
  s.summary          = 'SWUIKit @IBInspectables库，用于xib中使用自定义属性'

  s.description      = <<-DESC
  由于@IBInspectable打包成Framework不可用，需独立成库
                       DESC

  s.homepage         = 'http://172.16.6.11:8050/Component/SWUIKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Guo ZhongCheng' => 'guozhongcheng@vv.cn' }
  s.source           = { :git => 'http://172.16.6.11:8050/Component/SWUIKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = "5.1"
    
  s.source_files = 'IBInspectables/**/*'
  
  s.dependency 'SWUIKit'
  s.dependency 'SWFoundationKit'
end
