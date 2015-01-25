module Seiso
  class ImportMaster

    # Maps the data master format to the Seiso API format.
    #
    # Author:: Willie Wheeler
    # Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
    # License:: Apache 2.0
    class MasterItemMapper
    
      def initialize
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
      
      # Returns a mapper lambda for the specified type.
      def mapper_for(type)
        mapper = @mappers[type]
        raise ArgumentError, "Unknown type: #{type}" if mapper.nil?
        mapper
      end
      
      def data_center_mapper
        ->(dc) {
          {
            'key' => dc['key'],
            'name' => dc['name'],
            'region' => { 'key' => dc['region'] }
          }
        }
      end
      
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
      
      def health_status_mapper
        ->(hs) {
          {
            'key' => hs['key'],
            'name' => hs['name'],
            'statusType' => { 'key' => hs['statusType'] }
          }
        }
      end
      
      def infrastructure_provider_mapper
        ->(ip) {
          {
            'key' => ip['key'],
            'name' => ip['name']
          }
        }
      end
      
      def ip_address_role_mapper
        # Suppressing IP addresses since we don't import those from master files.
        ->(r) {
          {
            'serviceInstance' => { 'key' => r['serviceInstance'] },
            'name' => r['name'],
            'description' => r['description']
          }
        }
      end
      
      def load_balancer_mapper
        ->(lb) {
          seiso_lb = {
            'name' => lb['name'],
            'type' => lb['type'],
            'ipAddress' => lb['ipAddress'],
            'apiUrl' => lb['apiUrl']
          }
          
          dc = lb['dataCenter']
          seiso_lb['dataCenter'] = { 'key' => dc } unless dc.nil?
          
          seiso_lb
        }
      end
      
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
      
      def node_mapper
        ->(n) {
          seiso_node = {
            'name' => n['name'],
            'serviceInstance' => { 'key' => n['serviceInstance'] }
          }

          machine = n['machine']
          seiso_node['machine'] = { 'name' => machine } unless machine.nil?

          seiso_node
        }
      end
      
      def node_ip_address_mapper
        # Currently suppressing rotation status and endpoints since we don't import those from master files
        ->(nip) {
          {
            'node' => { 'name' => nip['node'] },
            'ipAddressRole' => { 'name' => nip['ipAddressRole'] },
            'ipAddress' => nip['ipAddress']
          }
        }
      end
      
      def region_mapper
        ->(r) {
          {
            'key' => r['key'],
            'name' => r['name'],
            'regionKey' => r['regionKey'],
            'infrastructureProvider' => { 'key' => r['infrastructureProvider'] }
          }
        }
      end
      
      def rotation_status_mapper
        ->(rs) {
          {
            'key' => rs['key'],
            'name' => rs['name'],
            'statusType' => { 'key' => rs['statusType'] }
          }
        }
      end
      
      def service_mapper
        ->(s) {
          seiso_service = {
            'key' => s['key'],
            'name' => s['name'],
            'description' => s['description'],
            'platform' => s['platform'],
            'scmRepository' => s['scmRepository']
          }

          group = s['group']
          seiso_service['group'] = { 'key' => group } unless group.nil?

          type = s['type']
          seiso_service['type'] = { 'key' => type } unless type.nil?

          owner = s['owner']
          seiso_service['owner'] = { 'username' => owner } unless owner.nil?

          seiso_service
        }
      end
      
      def service_group_mapper
        ->(sg) {
          {
            'key' => sg['key'],
            'name' => sg['name']
          }
        }
      end
      
      def service_instance_mapper
        ->(si) {
          key = si['key']
          ip_address_roles = si['ipAddressRoles']
          ports = si['ports']
          
          seiso_si = {
            'key' => key,
            'service' => { 'key' => si['service'] },
            'environment' => { 'key' => si['environment'] },
            'loadBalanced' => si['loadBalanced'],
            'minCapacityDeploy' => si['minCapacityDeploy'],
            'minCapacityOps' => si['minCapacityOps'],
            
            # FIXME Deprecated. This is a hardcoded field for an internal Expedia app, and we will remove it.
            'eosManaged' => (si['eosManaged'] || false),
            
            # FIXME Deprecated. This is the old name for the minCapacityOps field.
            'requiredCapacity' => si['minCapacityOps']
          }

          data_center = si['dataCenter']
          seiso_si['dataCenter'] = { 'key' => data_center } unless data_center.nil?
          
          load_balancer = si['loadBalancer']
          seiso_si['loadBalancer'] = { 'name' => load_balancer } unless load_balancer.nil?

          seiso_si
        }
      end
      
      def service_instance_port_mapper
        # Suppressing endpoints since we don't import those from master files.
        ->(p) {
          {
            'serviceInstance' => { 'key' => p['serviceInstance'] },
            'number' => p['number'],
            'protocol' => p['protocol'],
            'description' => p['description']
          }
        }
      end
      
      def service_type_mapper
        ->(st) {
          {
            'key' => st['key'],
            'name' => st['name']
          }
        }
      end
      
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
