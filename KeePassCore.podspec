#
# Be sure to run `pod lib lint KeePassCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KeePassCore'
  s.version          = '0.1.0'
  s.summary          = 'A short description of KeePassCore.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Igor Kotkovets/KeePassCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Igor Kotkovets' => 'igorkotkovets@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/Igor Kotkovets/KeePassCore.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.osx.deployment_target  = '10.14'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'KeePassCore/Classes/**/*.{swift,h,m,c}'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2',
'SWIFT_INCLUDE_PATHS' => '$(PODS_TARGET_SRCROOT)/KeePassCore/SwiftZLib $(PODS_TARGET_SRCROOT)/KeePassCore/libxml2' }
  s.preserve_paths = 'KeePassCore/SwiftZLib/module.modulemap KeePassCore/libxml2/*'

#  s.preserve_paths = 'CocoaPods/**/*'
#  s.pod_target_xcconfig = {
#    'SWIFT_INCLUDE_PATHS[sdk=macosx*]'           => '$(PODS_ROOT)/KeePassCore/CocoaPods/macosx',
#    'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]'         => '$(PODS_ROOT)/KeePassCore/CocoaPods/iphoneos',
#    'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]'  => '$(PODS_ROOT)/KeePassCore/CocoaPods/iphonesimulator',
#    'SWIFT_INCLUDE_PATHS[sdk=appletvos*]'        => '$(PODS_ROOT)/KeePassCore/CocoaPods/appletvos',
#    'SWIFT_INCLUDE_PATHS[sdk=appletvsimulator*]' => '$(PODS_ROOT)/KeePassCore/CocoaPods/appletvsimulator',
#    'SWIFT_INCLUDE_PATHS[sdk=watchos*]'          => '$(PODS_ROOT)/KeePassCore/CocoaPods/watchos',
#    'SWIFT_INCLUDE_PATHS[sdk=watchsimulator*]'   => '$(PODS_ROOT)/KeePassCore/CocoaPods/watchsimulator'
#  }
  s.libraries = 'z','xml2'
end
