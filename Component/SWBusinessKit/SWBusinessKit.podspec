#
# Be sure to run `pod lib lint SWBusinessKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SWBusinessKit'
  s.version          = '1.7.4'
  s.summary          = '业务层框架'

  s.description      = <<-DESC
  业务层统一框架
                       DESC

  s.homepage         = 'http://172.16.6.11:8050/Component/SWBusinessKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dailiangjin' => 'dailiangjin@vv.cn' }
  s.source           = { :git => 'http://172.16.6.11:8050/Component/SWBusinessKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = "5.4.2"
  
  s.default_subspec = 'File' 
    
#  # 有依赖库的话统一放在Dependency，并将 Framework 的依赖打开
  s.subspec "Dependency" do |ss|
#    # 系统库
#    ss.frameworks = 'UIKit', '...'
#    ss.libraries = 'c++', '...'
#    # 本地第三方库，建议统一放在Frameworks文件夹中
#    ss.vendored_frameworks = 'SWBusinessKit/Frameworks/**/*.framework'
#    ss.vendored_libraries = 'SWBusinessKit/Frameworks/**/*.a'
#    # 远程第三方库
    ss.dependency 'Alamofire', '5.4.2'
    ss.dependency 'SWFoundationKit'
    ss.dependency 'RxSwift','5.1.1'
    ss.dependency 'RxCocoa'
    ss.dependency 'KingfisherWebP'
  end
      
#  # 资源的话统一放在Resources，并将 Resources 的依赖打开
  s.subspec "Resources" do |ss|
#    # 使用bundle文件夹作为资源（可减少包的大小，如果有多层文件夹，需要指定正确的路径才能获取到资源）
#    ss.resources = "SWBusinessKit/Assets/SWBusinessKit.bundle"
#    # 资源文件文件（编译时会自动打包为bundle，不需要特别指定路径就可以获取到资源，缺点是bundle会比较大）
    ss.resource_bundles = {
      'SWBusinessKit' => ['SWBusinessKit/Assets/**/*']
    }
  end
  
  # 源码依赖
  s.subspec "File" do |ss|
    ss.source_files = 'SWBusinessKit/Classes/**/*'
    ss.dependency 'SWBusinessKit/Resources'
    ss.dependency 'SWBusinessKit/Dependency'
  end
  
  # Framework包依赖, 使用打包脚本打包后可用
  s.subspec "Framework" do |ss|
    ss.vendored_frameworks = 'SWBusinessKit/PackageFramework/SWBusinessKit.xcframework'
    # 关闭bitcode
    ss.pod_target_xcconfig = {
      "ENABLE_BITCODE" => "YES"
    }
    ss.dependency 'SWBusinessKit/Dependency'
    # 如果Resources中，使用resource_bundles的形式添加资源，需要看看打包完成后的framework是否已包含bundle文件夹再决定是否打开资源的依赖
#    ss.dependency 'SWBusinessKit/Resources'
  end
  
# 使用Framework（默认）方式时，如果pod install过程中提示target has transitive dependencies that include static binaries:
# 可在podfile文件里加上下面这句话再试试
# pre_install do |installer| Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
# end

end
