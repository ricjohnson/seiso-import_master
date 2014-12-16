# Seiso namespace module
module Seiso
  
  # Link factory, supporting HATEOAS principle.
  #
  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
  # License:: Apache 2.0
  
  class LinkFactory

    # Creates a new link factory, injecting the URI factory.
    # - uri_factory: URI factory
    def initialize(uri_factory)
      @uri_factory = uri_factory
    end
    
    # Creates a new link. Only for link involving a single key, at least for now.
    # - type: Item type (e.g., services, service-instances, data-centers, etc.)
    # - key_name: name of the property the item type uses as a unique key
    # - key_value: key value
    def link(type, key_name, key_value)
      return nil if key_value.nil?
      
      {
        '_self' => @uri_factory.item_uri(type, key_value),
        
        # FIXME Deprecated. To replace with _self URI above.
        key_name => key_value
      }
    end

    # Creates a new IP address role link.
    # - service_instance_key: Service instance key
    # - role_name: IP address role name
    def ip_address_role_link(service_instance_key, role_name)
      {
        '_self' => @uri_factory.item_uri('ip-address-roles', service_instance_key, role_name),
        
        # FIXME These are deprecated. To replace with _self URI above.
        'serviceInstance' => {
          'key' => service_instance_key
        },
        'name' => role_name
      }
    end
  end
end
