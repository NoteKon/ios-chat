#
# Be sure to run `pod lib lint HandyJSON.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SWIMKit'
  s.version          = '1.0.0'
  s.summary          = 'SWIMKit组件库'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://172.16.6.11:8050/Frameworks/FFRouter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ice' => '707689817@qq.com' }
  s.source           = { :git => 'http://172.16.6.11:8050/Frameworks/FFRouter', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.swift_version = "5.4"
  
  s.default_subspec = "File"
    
#  # 有依赖库的话统一放在Dependency，并将 Framework 的依赖打开
#  s.subspec "Dependency" do |ss|
#    # 系统库
#    ss.frameworks = 'UIKit', '...'
#    ss.libraries = 'c++', '...'
#    # 本地第三方库，建议统一放在Frameworks文件夹中
#    ss.vendored_frameworks = 'SWIMKit/Frameworks/**/*.framework'
#    ss.vendored_libraries = 'SWIMKit/Frameworks/**/*.a'
#    # 远程第三方库
#    ss.dependency 'AFNetworking', '~> 2.3'
#  end
      
#  # 资源的话统一放在Resources，并将 Resources 的依赖打开
#  s.subspec "Resources" do |ss|
#   资源文件文件（编译时会自动打包为bundle,建议将图片放在HandyJSON.xcassets中，OtherResources放xib等资源）
#    ss.resource_bundles = {
#      'SWIMKit' => [
#           'SWIMKit/Assets/SWIMKit.xcassets',
#           'SWIMKit/Assets/OtherResources/**/*.{storyboard,xib,xcassets,lproj,plist,json}'
#       ]
#    }
#  end
  
  # 源码依赖
  s.subspec "File" do |ss|
    ss.source_files = 'SWIMKit/Classes/**/*'
#    ss.dependency 'SWIMKit/Resources'
#    ss.dependency 'SWIMKit/Dependency'
  end
  
  # Framework包依赖, 使用打包脚本打包后可用
  s.subspec "Framework" do |ss|
    ss.vendored_frameworks = 'SWIMKit.xcframework'
#    ss.dependency 'SWIMKit/Dependency'
#    # 如果Resources中，使用resource_bundles的形式添加资源，需要看看打包完成后的framework是否已包含bundle文件夹再决定是否打开资源的依赖
#    ss.dependency 'SWIMKit/Resources'
  end
  
# 使用Framework（默认）方式时，如果pod install过程中提示target has transitive dependencies that include static binaries:
# 可在podfile文件里加上下面这句话再试试
# pre_install do |installer| Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
# end

end
