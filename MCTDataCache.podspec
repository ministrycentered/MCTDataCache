Pod::Spec.new do |s|
  s.name         = "MCTDataCache"
  s.version      = "1.0.1"
  s.summary      = "A short description of MCTDataCache."
  s.homepage     = "https://github.com/ministrycentered/MCTDataCache"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Skylar Schipper" => "skylar@pco.bz" }
  s.platform     = :ios, "7.1"
  s.source       = { :git => "https://github.com/ministrycentered/MCTDataCache.git", :tag => s.version.to_s }
  s.source_files = "MCTDataCache", "MCTDataCache/**/*.{h,m}"
  s.requires_arc = true
end