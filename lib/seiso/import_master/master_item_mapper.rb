module Seiso
  class ImportMaster

    # Maps the data master format to the Seiso API format.
    #
    # Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
    # Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
    # License:: Apache 2.0
    class MasterItemMapper
    
      def initialize(link_factory)
        @link_factory = link_factory
        @mappers = {
          'data-centers' => data_center_mapper,
          'environments' => environment_mapper,
          'health-statuses' => health_status_mapper,
          'infrastructure-providers' => infrastructure_provider_mapper,
          'ip-address-roles' => ip_address_role_mapper,
          'load-balancers' => load_balancer_mapper,
          'machines' => machine_mapper,
          'nodes' => node_mapper,
          'node-ip-addresses' => node_ip_address_mapper,
          'regions' => region_mapper,
          'rotation-statuses' => rotation_status_mapper,
          'services' => service_mapper,
          'service-groups' => service_group_mapper,
          'service-instances' => service_instance_mapper,
          'service-instance-ports' => service_instance_port_mapper,
          'service-types' => service_type_mapper,
          'status-types' => status_type_mapper
        }
      end

      # Maps a list of items.
      # - type: Item type
      # - items: Item list
      def map_all(type, items)
        mapper = mapper_for type
        result = []
        items.each { |i| result << mapper.call(i) }
        result
      end
      
      # Maps a single item.
      # - type: Item type
      # - item: Item
      def map_one(type, item)
        mapper_for(type).call item
      end
      
      private
      
      # Returns a link for the specified item, or nil if key_value is nil.
      def link_for(type, key_name, key_value)
        # Do nil check here (even though link factory does it too) since the unit test requires this behavior.
        return key_value.nil? ? nil : @link_factory.link(type, key_name, key_value)
      end
      
      # Returns a mapper lambda for the specified type.
      def mapper_for(type)
        mapper = @mappers[type]
        raise ArgumentError, "Unknown type: #{type}" if mapper.nil?
        mapper
      end
      
      # Returns a mapper lambda.
      def data_center_mapper
        ->(dc) {
          {
            'key' => dc['key'],
            'name' => dc['name'],
            'region' => link_for('regions', 'key', dc['region'])
          }
        }
      end
      
      # Returns a mapper lambda.
      def environment_mapper
        ->(e) {
          {
            'key' => e['key'],
            'name' => e['name'],
            'aka' => e['aka'],
            'description' => e['description'],
            
            # FIXME Deprecated, don't use.
            'rank' => e['rank']
          }
        }
      end
      
      # Returns a mapper lambda.
      def health_status_mapper
        ->(hs) {
          {
            'key' => hs['key'],
            'name' => hs['name'],
            'statusType' => link_for('status-types', 'key', hs['statusType'])
          }
        }
      end
      
      # Returns a mapper lambda.
      def infrastructure_provider_mapper
        ->(ip) {
          {
            'key' => ip['key'],
            'name' => ip['name']
          }
        }
      end
      
      # Returns a mapper lambda.
      def ip_address_role_mapper
        # Suppressing IP addresses since we don't import those from master files.
        ->(r) {
          {
            'serviceInstance' => link_for('service-instances', 'key', r['serviceInstance']),
            'name' => r['name'],
            'description' => r['description']
          }
        }
      end
      
      # Returns a mapper lambda.
      def load_balancer_mapper
        ->(lb) {
          {
            'name' => lb['name'],
            'type' => lb['type'],
            'ipAddress' => lb['ipAddress'],
            'dataCenter' => link_for('data-centers', 'key', lb['dataCenter']),
            'apiUrl' => lb['apiUrl']
          }
        }
      end
      
      # Returns a mapper lambda.
      def machine_mapper
        ->(m) {
          {
            'name' => m['name'],
            'ipAddress' => m['ipAddress'],
            'fqdn' => m['fqdn'],
            'hostname' => m['hostname'],
            'domain' => m['domain'],
            'os' => m['os'],
            'platform' => m['platform'],
            'platformVersion' => m['platformVersion']
          }
        }
      end
      
      # Returns a mapper lambda.
      def node_mapper
        ->(n) {
          service_instance = n['serviceInstance']
          ip_addresses = n['ipAddresses']
          si_ref = link_for('service-instances', 'key', service_instance)
          
          result = {
            'name' => n['name'],
            'serviceInstance' => si_ref,
            'machine' => link_for('machines', 'name', n['machine'])
          }
          
=begin
      if ip_addresses
        result['ipAddresses'] = []
        ip_addresses.each do |ip|
          role_name = ip['ipAddressRole']
          result['ipAddresses'] << {
            'ipAddressRole' => @link_factory.ip_address_role_link(service_instance, role_name),
            'ipAddress' => ip['ipAddress']
          }
        end
      end
=end
        
          result
        }
      end
      
      # Returns a mapper lambda.
      def node_ip_address_mapper
        # Currently suppressing rotation status and endpoints since we don't import those from master files
        ->(nip) {
          {
            'node' => link_for('nodes', 'name', nip['node']),
            'ipAddressRole' => link_for('ip-address-roles', 'name', nip['ipAddressRole']),
            'ipAddress' => nip['ipAddress']
          }
        }
      end
      
      # Returns a mapper lambda.
      def region_mapper
        ->(r) {
          {
            'key' => r['key'],
            'name' => r['name'],
            'regionKey' => r['regionKey'],
            'infrastructureProvider' => link_for('infrastructure-providers', 'key', r['infrastructureProvider'])
          }
        }
      end
      
      # Returns a mapper lambda.
      def rotation_status_mapper
        ->(rs) {
          {
            'key' => rs['key'],
            'name' => rs['name'],
            'statusType' => link_for('status-types', 'key', rs['statusType'])
          }
        }
      end
      
      # Returns a mapper lambda.
      def service_mapper
        ->(s) {
          {
            'key' => s['key'],
            'name' => s['name'],
            'description' => s['description'],
            'group' => link_for('service-groups', 'key', s['group']),
            'type' => link_for('service-types', 'key', s['type']),
            'owner' => link_for('people', 'username', s['owner']),
            'platform' => s['platform'],
            'scmRepository' => s['scmRepository']
          }
        }
      end
      
      # Returns a mapper lambda.
      def service_group_mapper
        ->(sg) {
          {
            'key' => sg['key'],
            'name' => sg['name']
          }
        }
      end
      
      # Returns a mapper lambda.
      def service_instance_mapper
        ->(si) {
          key = si['key']
          ip_address_roles = si['ipAddressRoles']
          ports = si['ports']
          
          result = {
            'key' => key,
            'service' => link_for('services', 'key', si['service']),
            'environment' => link_for('environments', 'key', si['environment']),
            'dataCenter' => link_for('data-centers', 'key', si['dataCenter']),
            'loadBalanced' => si['loadBalanced'],
            'loadBalancer' => link_for('loadBalancer', 'name', si['loadBalancer']),
            'minCapacityDeploy' => si['minCapacityDeploy'],
            'minCapacityOps' => si['minCapacityOps'],
            
            # FIXME Deprecated. This is a hardcoded field for an internal Expedia app, and we will remove it.
            'eosManaged' => (si['eosManaged'] || false),
            
            # FIXME Deprecated. This is the old name for the minCapacityOps field.
            'requiredCapacity' => si['minCapacityOps']
          }
          
=begin
      if ip_address_roles
        result['ipAddressRoles'] = []
        ip_address_roles.each do |role|
          result['ipAddressRoles'] << {
            'serviceInstance' => link_for('service-instances', 'key', key),
            'name' => role['name'],
            'description' => role['description']
          }
        end
      end

      if ports
        result['ports'] = []
        ports.each do |port|
          result['ports'] << {
            'serviceInstance' => link_for('service-instances', 'key', key),
            'number' => port['number'],
            'protocol' => port['protocol'],
            'description' => port['description']
          }
        end
      end
=end
        
          result
        }
      end
      
      # Returns a mapper lambda.
      def service_instance_port_mapper
        # Suppressing endpoints since we don't import those from master files.
        ->(p) {
          {
            'serviceInstance' => link_for('service-instances', 'key', p['serviceInstance']),
            'number' => p['number'],
            'protocol' => p['protocol'],
            'description' => p['description']
          }
        }
      end
      
      # Returns a mapper lambda.
      def service_type_mapper
        ->(st) {
          {
            'key' => st['key'],
            'name' => st['name']
          }
        }
      end
      
      # Returns a mapper lambda.
      def status_type_mapper
        ->(st) {
          {
            'key' => st['key'],
            'name' => st['name']
          }
        }
      end
    end
  end
end
