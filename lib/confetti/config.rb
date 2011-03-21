module Confetti
  class Config
    include Helpers
    include PhoneGap
    self.extend TemplateHelper

    attr_accessor :package, :version, :description, :height, :width
    attr_reader :author, :viewmodes, :name, :license, :content, 
                :icon_set, :feature_set, :preference_set, :xml_doc

    generate_and_write  :android_manifest, :android_strings, :webos_appinfo,
                        :ios_info, :symbian_wrt_info, :blackberry_widgets_config

    # classes that represent child elements
    Author      = Class.new Struct.new(:name, :href, :email)
    Name        = Class.new Struct.new(:name, :shortname)
    License     = Class.new Struct.new(:text, :href)
    Content     = Class.new Struct.new(:src, :type, :encoding)
    Icon        = Class.new Struct.new(:src, :height, :width, :extras)
    Feature     = Class.new Struct.new(:name, :required)
    Preference  = Class.new Struct.new(:name, :value, :readonly)

    def initialize(*args)
      @author           = Author.new
      @name             = Name.new
      @license          = License.new
      @content          = Content.new
      @icon_set         = TypedSet.new Icon
      @feature_set      = TypedSet.new Feature
      @preference_set   = TypedSet.new Preference
      @viewmodes        = []

      if args.length > 0 && is_file?(args.first)
        populate_from_xml args.first
      end
    end

    def populate_from_xml(xml_file)
      begin
        config_doc = REXML::Document.new(File.read(xml_file)).root
      rescue REXML::ParseException
        raise ArgumentError, "malformed config.xml"
      end

      fail "no doc parsed" unless config_doc

      # save reference to xml doc
      @xml_doc = config_doc

      @package = config_doc.attributes["id"]
      @version = config_doc.attributes["version"]

      config_doc.elements.each do |ele|
        attr = ele.attributes

        case ele.name
        when "name"
          @name = Name.new(ele.text.strip, attr["shortname"])
        when "author"
          @author = Author.new(ele.text.strip, attr["href"], attr["email"])
        when "description"
          @description = ele.text.strip
        when "icon"
          extras = attr.keys.inject({}) do |hash, key|
            hash[key] = attr[key] unless Icon.public_instance_methods.include? key
            hash
          end
          @icon_set << Icon.new(attr["src"], attr["height"], attr["width"], extras)
        when "feature"
          @feature_set  << Feature.new(attr["name"], attr["required"])
        end
      end
    end

    def icon
      @icon_set.first
    end

    def biggest_icon
      @icon_set.max { |a,b| a.width.to_i <=> b.width.to_i }
    end
  end
end
