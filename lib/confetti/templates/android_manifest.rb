module Confetti
  module Template
    class AndroidManifest < Base
      include JavaChecks

      DEFAULT_MIN_SDK = "7"

      GAP_PERMISSIONS_MAP = {
        "camera"        => %w{CAMERA},
        "notification"  => %w{VIBRATE},
        "geolocation"   => %w{ACCESS_COARSE_LOCATION
                              ACCESS_FINE_LOCATION
                              ACCESS_LOCATION_EXTRA_COMMANDS},
        "media"         => %w{RECORD_AUDIO
                              RECORD_VIDEO
                              MODIFY_AUDIO_SETTINGS},
        "contacts"      => %w{READ_CONTACTS
                              WRITE_CONTACTS
                              GET_ACCOUNTS},
        "file"          => %w{WRITE_EXTERNAL_STORAGE},
        "network"       => %w{ACCESS_NETWORK_STATE},
        "battery"       => %w{BROADCAST_STICKY}
      }

      ORIENTATIONS_MAP = {
        :default    => "unspecified",
        :landscape  => "landscape",
        :portrait => "portrait"
      }

      def package_name
        convert_to_java_package_id(@config.package)
      end

      def class_name
        convert_to_java_identifier(@config.name.name) if @config
      end

      def output_filename
        "AndroidManifest.xml"
      end

      def version
        @config.version_string || '0.0.1'
      end

      def version_code
        if @config.version_code.nil?
          '1'
        else
          int = @config.version_code.to_i
          int == 0 ? '1' : int.to_s
        end
      end

      def app_orientation
        ORIENTATIONS_MAP[@config.orientation]
      end

      def permissions
        permissions = []
        phonegap_api = /http\:\/\/api.phonegap.com\/1[.]0\/(\w+)/
        feature_names = @config.feature_set.map { |f| f.name }
        feature_names.sort

        feature_names.each do |f|
          feature_name = f.match(phonegap_api)[1] if f.match(phonegap_api)
          associated_permissions = GAP_PERMISSIONS_MAP[feature_name]

          permissions.concat(associated_permissions) if associated_permissions
        end

        permissions.sort!
        permissions.map { |f| { :name => f } }
      end

      def install_location
        valid_choices = %w(internalOnly auto preferExternal)
        choice = @config.preference("android-installLocation").to_s

        valid_choices.include?(choice) ? choice : "internalOnly"
      end

      def min_sdk_version
        choice = @config.preference("android-minSdkVersion").to_s

        int_value?(choice) ? choice : DEFAULT_MIN_SDK
      end

      def max_sdk_version_attribute
        choice = @config.preference("android-maxSdkVersion")

        if int_value?(choice)
          "android:maxSdkVersion=\"#{ choice }\""
        end
      end

      def int_value? val
        return if val.nil?

        integer = /^\d+$/
        val.to_s.match(integer)
      end
    end
  end
end
