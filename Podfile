# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'Divineray' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
   pod 'Alamofire'
   pod 'IQKeyboardManagerSwift'
   pod 'SVProgressHUD'
   pod 'Kingfisher'
   pod 'Connectivity'
   pod 'SVProgressHUD'
   pod 'FBSDKLoginKit'
   pod 'Firebase/Auth'
   pod 'Firebase/Crashlytics'
   pod 'SDWebImage'
   pod 'Masonry'
   pod 'SwiftAudio'
   pod 'DateTimePicker'
   pod 'YouTubePlayer'
   pod 'Branch'
   pod 'Socket.IO-Client-Swift', '~> 15.1.0'
   pod 'AgoraRtcEngine_iOS'
   pod 'NextGrowingTextView'
   pod 'BottomPopup'
   pod 'FirebaseAuth'
   pod 'GrowingTextView'
   pod 'iOSPhotoEditor'
   pod 'SVProgressHUD'
   pod 'ToastViewSwift'
   
  # Pods for Divineray

  post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            xcconfig_path = config.base_configuration_reference.real_path
            xcconfig = File.read(xcconfig_path)
            xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
            File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
            end
        end
    end
  end

