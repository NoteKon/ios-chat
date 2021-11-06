#
# Be sure to run `pod lib lint SWFoundationKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SWFoundationKit'
  s.version          = '1.1.3'
  s.summary          = 'Swift基础功能库.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://172.16.6.11:8050/Component/SWFoundationKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '戴亮金' => 'dailiangjin@vv.cn' }
  s.source           = { :git => 'http://172.16.6.11:8050/Component/SWFoundationKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = "5.4.2"
  
  s.default_subspec = "File" 
    
  # 有依赖库的话统一放在Dependency，并将 Framework 的依赖打开
  s.subspec "Dependency" do |ss|
#    # 系统库
    ss.frameworks = 'CoreGraphics'
#    ss.libraries = 'c++', '...'
#    # 本地第三方库，建议统一放在Frameworks文件夹中
#    ss.vendored_frameworks = 'SWFoundationKit/Frameworks/**/*.framework'
#    ss.vendored_libraries = 'SWFoundationKit/Frameworks/**/*.a'
    # 远程第三方库
    ss.dependency 'Alamofire', '5.4.2'
    ss.dependency 'KeychainSwift'
    ss.dependency 'HandyJSON'
    ss.dependency 'FFRouter'
    ss.dependency 'Kingfisher'
  end
      
#  # 资源的话统一放在Resources，并将 Resources 的依赖打开
#  s.subspec "Resources" do |ss|
#   资源文件文件（编译时会自动打包为bundle,建议将图片放在SWFoundationKit.xcassets中，OtherResources放xib等资源）
#    ss.resource_bundles = {
#      'SWFoundationKit' => [
#           'SWFoundationKit/Assets/SWFoundationKit.xcassets',
#           'SWFoundationKit/Assets/OtherResources/**/*.{storyboard,xib,xcassets,lproj,plist,json}'
#       ]
#    }
#  end
  
  # 源码依赖
  s.subspec "File" do |ss|
    ss.source_files = 'SWFoundationKit/Classes/**/*'
#    ss.dependency 'SWFoundationKit/Resources'
    ss.dependency 'SWFoundationKit/Dependency'
  end
  
  # Framework包依赖, 使用打包脚本打包后可用
  s.subspec "Framework" do |ss|
#    ss.public_header_files = 'SWFoundationKit/PackageFramework/SWFoundationKit.framework/Headers/*.h'
    ss.vendored_frameworks = 'SWFoundationKit/PackageFramework/SWFoundationKit.xcframework'
    ss.dependency 'SWFoundationKit/Dependency'
#    # 如果Resources中，使用resource_bundles的形式添加资源，需要看看打包完成后的framework是否已包含bundle文件夹再决定是否打开资源的依赖
#    ss.dependency 'SWFoundationKit/Resources'
  end
  
# 使用Framework（默认）方式时，如果pod install过程中提示target has transitive dependencies that include static binaries:
# 可在podfile文件里加上下面这句话再试试
# pre_install do |installer| Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
# end

end
