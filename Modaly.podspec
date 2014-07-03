Pod::Spec.new do |s|
  s.name         = "Modaly"
  s.version      = "0.1.0"
  s.summary      = "Segue to present a custom size view controller from storyboard"
  s.homepage     = "https://github.com/patoroco/Modaly"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "Jorge Maroto Garcia" => "patoroco@gmail.com" }
  s.source       = { :git => "https://github.com/patoroco/Modaly.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.source_files = 'Modaly'
  s.frameworks   = 'UIKit'
  s.requires_arc = true
end