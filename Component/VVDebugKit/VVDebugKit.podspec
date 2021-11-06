#
# Be sure to run `pod lib lint VVDebugKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VVDebugKit'
  s.version          = '0.4.3'
  s.summary          = 'A short description of VVDebugKit.'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://172.16.6.11:8050/Component/VVDebugKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dailiangjin' => 'dailiangjin@vv.cn' }
  s.source           = { :git => 'http://172.16.6.11:8050/Component/VVDebugKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  #s.static_framework = true

  s.source_files = 'VVDebugKit/Classes/**/*'
  
  s.resource_bundles = {
    'VVDebugKit' => ['VVDebugKit/Assets/**/*.{storyboard,xib,xcassets,lproj,plist}']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'SWFoundationKit'
  s.dependency 'SWBusinessKit'
  s.dependency 'SWUIKit'
  s.dependency 'Aspects'
  s.dependency 'SnapKit'
  s.dependency 'RxCocoa'
end
