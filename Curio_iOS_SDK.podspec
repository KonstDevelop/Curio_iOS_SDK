Pod::Spec.new do |s|
	s.name         = 'Curio_iOS_SDK'
	s.version      = '1.1.0'
	s.ios.deployment_target = '6.0'
	s.summary      = 'Curio is mobile analytics system of Turkcell, and this is Curio iOS Client SDK library'
	s.homepage     = 'https://github.com/Turkcell/Curio_iOS_SDK'
	s.license      = 'Apache 2.0'
	s.authors             = { 'Can Ciloglu' => 'can.ciloglu@turkcell.com.tr', 'Abdulbasit Tanhan' => 'abdulbasit.tanhan@turkcell.com.tr'  }
	s.social_media_url   = 'https://twitter.com/canciloglu'
	s.source       = { :git => 'https://github.com/Turkcell/Curio_iOS_SDK.git', :tag => s.version  }
	s.source_files  = 'CurioSDK.Core/CurioSDK'
	s.requires_arc = true
	s.frameworks = 'Foundation','UIKit', 'CoreTelephony', 'CoreLocation', 'CoreBluetooth'
	s.library = 'sqlite3'
end
