Pod::Spec.new do |spec|

  spec.name         = "KDIOTPFieldView"
  spec.version      = "1.0"
  spec.summary      = "A CocoaPods library for One Time Password View written in Swift"

  spec.description  = <<-DESC
  This library helps you create One-Time-Password view for iOS Applications
                   DESC

  spec.homepage     = "https://github.com/Kenildhola/KDIOTPFieldView"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Kenil Dhola" => "kenildhola3@gmail.com" }
  
  spec.ios.deployment_target = "12.0"
  spec.swift_version = "5.0"  
  
  spec.source       = { :git => "https://github.com/Kenildhola/KDIOTPFieldView.git", :tag => "#{spec.version}" }
  spec.source_files  = "KDIOTPFieldView/**/*.{h,m,swift}"

end
