require "json"
require "seiso/connector"
require "yaml"
require_relative "import_master/link_factory"
require_relative "import_master/master_item_mapper"
require_relative "import_master/uri_factory"

# Seiso namespace module
module Seiso

  # Imports Seiso data master files into Seiso.
  #
  # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
  # Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
  # License:: Apache 2.0
  
  class ImportMaster
    
    # Initializes the importer with a Seiso connector.
    def initialize(seiso_settings)
      @seiso = Seiso::Connector.new seiso_settings
      
      # TODO Inject dependencies?
      @uri_factory = Seiso::UriFactory.new @seiso.base_uri
      @link_factory = Seiso::LinkFactory.new @uri_factory
      @mapper = Seiso::MasterItemMapper.new @link_factory
      
      @loaders = {
        'json' => ->(file) { JSON.parse(IO.read(file)) },
        'yaml' => ->(file) { YAML.load_file file }
      }
    end

    # Imports a list of master files in order. Legal formats are 'json' (default) and 'yaml'.
    def import_files(files, format = 'json')
      loop do
        file = files.pop
        puts "Processing #{file}"
        import_file file
        break if files.empty?
      end
    end
    
    # Imports a data master file. Legal formats are 'json' (default) and 'yaml'.
    def import_file(file, format = 'json')
      loader = @loaders[format]
      raise ArgumentError, "Illegal format: #{format}" if loader.nil?
      doc = loader.call(file)
      import_doc doc
    end
    
    # Imports a data master document.
    def import_doc(doc)
      type = doc['type']
      master_items = doc['items']
      
      # There are some special cases
      if type == 'nodes'
        do_import_nodes master_items
      elsif type == 'service-instances'
        do_import_service_instances master_items
      else
        do_import_items(type, master_items)
      end
    end
    
    private
    
    def do_import_items(type, items)
      seiso_items = @mapper.map_all(type, items)
      @seiso.put_items(type, seiso_items)
    end
    
    # Imports the nodes, along with their associated IP addresses.
    def do_import_nodes(nodes)
      nips = detach_children(nodes, 'node', 'name', 'ipAddresses')
      do_import_items('nodes', nodes)
      do_import_items('node-ip-addresses', nips)
    end
    
    # Imports the service instances, along with their associated ports and IP address roles.
    def do_import_service_instances(service_instances)
      ports = detach_children(service_instances, 'serviceInstance', 'key', 'ports')
      roles = detach_children(service_instances, 'serviceInstance', 'key', 'ipAddressRoles')
      do_import_items('service-instances', service_instances)
      do_import_items('service-instance-ports', ports)
      do_import_items('ip-address-roles', roles)
    end
    
    # Enriches children with a link to the parent, detaches them from the parent, and returns all detached children.
    def detach_children(parents, parent_prop, parent_key, child_prop)
      all_children = []
      parents.each do |p|
        children = p[child_prop]
        children.each { |c| c[parent_prop] = p[parent_key] }
        all_children.push(*children)
        p.delete child_prop
      end
      all_children
    end
  end
end
