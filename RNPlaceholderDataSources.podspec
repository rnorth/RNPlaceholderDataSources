#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "RNPlaceholderDataSources"
  s.version          = "0.1.0"
  s.summary          = "A placeholder UITableViewDataSource/UICollectionViewDataSource for use in building quick app mockups"
  s.homepage         = "https://github.com/rnorth/RNPlaceholderDataSources"
  s.license          = 'MIT'
  s.author           = { "Richard North" => "rich.north@gmail.com" }
  s.source           = { :git => "https://github.com/rnorth/RNPlaceholderDataSources.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/whichrich'

  s.platform     = :ios, '6.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.{h,m}'
  s.resources = 'data/**/*.{json,js,jpg,png}'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'AFNetworking', '2.2.2'
end
