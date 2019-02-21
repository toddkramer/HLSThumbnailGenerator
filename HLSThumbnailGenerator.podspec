Pod::Spec.new do |s|
  s.name = 'HLSThumbnailGenerator'
  s.version = '0.5.0'
  s.license = 'MIT'
  s.summary = 'Substitute for AVAssetImageGenerator when generating thumbnails from streaming video.'
  s.homepage = 'https://github.com/toddkramer/HLSThumbnailGenerator'
  s.author = 'Todd Kramer'
  s.source = { :git => 'https://github.com/toddkramer/HLSThumbnailGenerator.git', :tag => s.version }

  s.module_name = 'HLSThumbnailGenerator'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Sources/**/*.swift'
end
