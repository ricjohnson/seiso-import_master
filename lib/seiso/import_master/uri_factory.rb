module Seiso
  class ImportMaster
  
    # URI factory.
    #
    # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
    # Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
    # License:: Apache 2.0
    class UriFactory

      # Creates a new URI factory for the given base URI.
      # - base_uri: Base URI (e.g., http://seiso.example.com)
      def initialize(base_uri)
        @base_uri = base_uri
        @v1_uri = "#{@base_uri}/v1"
      end
      
      # Returns the URI for the given item type.
      # - type: Item type (e.g., services, service-instances, ip-address-roles, etc.)
      def type_uri(type)
        if type == 'ip-address-roles'
          raise ArgumentError, "ip-address-roles is not a top-level type"
        else
          return v1_uri type
        end
      end
      
      # Returns the URI for the given item.
      # - type: Item type
      # - keys: One or more item keys, which collectively uniquely identify the item within the type
      def item_uri(type, *keys)
        if type == 'ip-address-roles'
          return v1_uri "service-instances/#{keys[0]}/ip-address-roles/#{keys[1]}"
        else
          return v1_uri "#{type}/#{keys[0]}"
        end
      end
      
      private
      
      # Resolves a relative path to the full URI.
      # - path: relative path
      def v1_uri(path)
        "#{@base_uri}/v1/#{path}"
      end
    end
  end
end
