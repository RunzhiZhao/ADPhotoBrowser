#
# Be sure to run `pod lib lint ADPhotoBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ADPhotoBrowser'
  s.version          = '1.0.0'
  s.summary          = 'A photo browser.'
  s.description      = <<-DESC
                        TODO: Add long description of the pod here.
                        一个清纯的图片浏览器
                       DESC
  s.homepage         = 'https://github.com/Runzhi.Zhao/ADPhotoBrowser'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Runzhi.Zhao' => '852356753@qq.com' }
  s.source           = { :git => 'https://github.com/Runzhi.Zhao/ADPhotoBrowser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '7.0'

  s.source_files = 'ADPhotoBrowser/Classes/**/**/*.{h,m}'
  
  # s.resource_bundles = {
  #   'ADPhotoBrowser' => ['ADPhotoBrowser/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'SDWebImage', '4.2.3'

end
