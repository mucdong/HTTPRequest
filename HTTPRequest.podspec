#
# Be sure to run `pod lib lint HTTPRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HTTPRequest'
  s.version          = '2.0'
  s.summary          = 'HTTPRequest is HTTP request library with GET, POST method'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
HTTPRequest is Singleton queue object, it pushes request to a queue and send HTTP request one by one. After complete one request, the queue will send back it to delegate object if it's avaiable
                     DESC

  s.homepage         = 'https://github.com/mucdong/HTTPRequest'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mucdong' => 'doannguyen06@gmail.com' }
  s.source           = { :git => 'https://github.com/mucdong/HTTPRequest.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/mucdong'

  s.ios.deployment_target = '8.0'

  s.source_files = 'HTTPRequest/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HTTPRequest' => ['HTTPRequest/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
