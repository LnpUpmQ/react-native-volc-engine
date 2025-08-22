Pod::Spec.new do |s|
  s.name         = "EffectsARSDK"
  s.version      = "4.6.2"
  s.license      = {
  :type => 'Proprietary',
  :text => <<-LICENSE
  EffectsARSDK. All Rights Reserved.
  LICENSE
  }
  s.homepage     = 'https://github.com'
  s.authors      = 'lab-cv'
  s.summary      = 'Demo for effect-sdk'
  s.description  = <<-DESC
  * Demo for effect-sdk
  DESC


  s.frameworks   = 'Accelerate','AssetsLibrary','AVFoundation','CoreGraphics','CoreImage','CoreMedia','CoreVideo','Foundation','QuartzCore','UIKit','CoreMotion','Accelerate','JavaScriptCore'
  s.weak_frameworks = 'Metal','MetalPerformanceShaders', 'Photos', 'CoreML'
  s.source       = { :git => "./", :tag => s.version.to_s }
  s.source_files  =  "include/*.h"
  s.public_header_files = "include/*.h"
  s.header_mappings_dir = "include/"
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  if ENV['USE_CK'] != '1'
    s.vendored_libraries = 'libeffect-sdk.a'
  end

  s.libraries = 'stdc++', 'z'
  # s.ios.dependency 'SSZipArchive'
end
