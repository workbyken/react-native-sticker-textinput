Pod::Spec.new do |s|
    s.name         = "react-native-sticker-textinput"
    s.version      = "0.1.0"
    s.summary      = "UITextView bridge that captures emoji & iOS stickers for React Native."
    s.license      = "MIT"
    s.homepage     = "https://github.com/workbyken/react-native-sticker-textinput"
    s.author       = { "Ken" => "kw@workbyken.com" }
  
    # For local/node_modules use, CocoaPods gets the podspec via :path, so this is fine:
    s.source       = { :path => "." }
  
    s.platform     = :ios, "13.0"
    s.swift_version = "5.0"
    s.source_files = "ios/*.{h,m,mm,swift}"
  
    # RN core dep
    s.dependency "React-Core"
  end
  