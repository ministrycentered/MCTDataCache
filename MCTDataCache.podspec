Pod::Spec.new do |s|
  s.name         = "MCTDataCache"
  s.version      = "1.0.2"
  s.summary      = "MCTDataCache is a file/data cache for iOS"
  s.homepage     = "https://github.com/ministrycentered/MCTDataCache"
  s.license      = { :type => "MIT" }
  s.author       = { "Skylar Schipper" => "skylar@pco.bz" }
  s.platform     = :ios, "7.1"
  s.source       = { :git => "git@github.com:ministrycentered/MCTDataCache.git", :tag => s.version.to_s }
  s.source_files = "MCTDataCache", "MCTDataCache/**/*.{h,m}"
  s.requires_arc = true
end
