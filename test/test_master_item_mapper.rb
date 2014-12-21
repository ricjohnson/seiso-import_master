require 'minitest/autorun'
require 'seiso/import_master/master_item_mapper'

# Author:: Willie Wheeler (mailto:wwheeler@expedia.com)
# Copyright:: Copyright (c) 2014-2015 Expedia, Inc.
# License:: Apache 2.0

class TestMasterItemMapper < MiniTest::Unit::TestCase

  def setup
    link_factory = Class.new do
      def self.link(type, key_name, key_value)
        { "foo" => "bar" }
      end
    end
    @mapper = Seiso::ImportMaster::MasterItemMapper.new link_factory
  end

  def test_map_all_illegal_type
    assert_raises(ArgumentError) do
      @mapper.map_all('some-bogus-type', [])
    end
  end

  def test_map_one_illegal_type
    assert_raises(ArgumentError) do
      @mapper.map_one('some-bogus-type', {})
    end
  end
  
  def test_map_data_center
    from = {
      'key' => 'amazon-us-east-1a',
      'name' => 'Amazon US East 1a',
      'region' => 'amazon-us-east-1'
    }
    to = @mapper.map_one('data-centers', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
    refute_nil(to['region'])
  end

  def test_map_environment
    from = {
      'key' => 'prod',
      'name' => 'Production',
      'aka' => 'Live',
      'description' => 'Production environment'
    }
    to = @mapper.map_one('environments', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
    assert_equal(from['aka'], to['aka'])
    assert_equal(from['description'], to['description'])
  end

  def test_map_health_status
    from = {
      'key' => 'healthy',
      'name' => 'Healthy',
      'statusType' => 'success'
    }
    to = @mapper.map_one('health-statuses', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
    refute_nil(to['statusType'])
  end

  def test_map_infrastructure_provider
    from = {
      'key' => 'amazon',
      'name' => 'Amazon'
    }
    to = @mapper.map_one('infrastructure-providers', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
  end

  def test_map_load_balancer
    from = {
      'name' => 'LB-1-2-3-4',
      'type' => 'NetScaler',
      'ipAddress' => '1.2.3.4',
      'dataCenter' => 'amazon-us-east-1a',
      'apiUrl' => 'https://1.2.3.4/api'
    }
    to = @mapper.map_one('load-balancers', from)
    assert_equal(from['name'], to['name'])
    assert_equal(from['type'], to['type'])
    assert_equal(from['ipAddress'], to['ipAddress'])
    refute_nil(to['dataCenter'])
    assert_equal(from['apiUrl'], to['apiUrl'])
  end

  def test_map_load_balancer_nil_data_center
    from = {
      'name' => 'LB-1-2-3-4',
      'type' => 'NetScaler',
      'ipAddress' => '1.2.3.4',
      'apiUrl' => 'https://1.2.3.4/api'
    }
    to = @mapper.map_one('load-balancers', from)
    assert_nil(to['dataCenter'])
  end
  
  def test_map_machine
    from = {
      'name' => 'ip-1-2-3-4',
      'ipAddress' => '1.2.3.4',
      'fqdn' => 'seiso01.dev.example.com',
      'hostname' => 'seiso01',
      'domain' => 'dev.example.com',
      'os' => 'linux',
      'platform' => 'amazon',
      'platformVersion' => '201409'
    }
    to = @mapper.map_one('machines', from)
    assert_equal(from['name'], to['name'])
    assert_equal(from['ipAddress'], to['ipAddress'])
    assert_equal(from['fqdn'], to['fqdn'])
    assert_equal(from['hostname'], to['hostname'])
    assert_equal(from['domain'], to['domain'])
    assert_equal(from['os'], to['os'])
    assert_equal(from['platform'], to['platform'])
    assert_equal(from['platformVersion'], to['platformVersion'])
  end

  def test_map_node
    from = {
      'name' => 'seiso01-dev',
      'serviceInstance' => 'seiso-dev',
      'machine' => 'ip-1-2-3-4',
      'ipAddresses' => [
        {
          'ipAddressRole' => 'internal',
          'ipAddress' => '1.2.10.1'
        }, {
          'ipAddressRole' => 'partners',
          'ipAddress' => '1.2.10.2'
        }
      ]
    }
    to = @mapper.map_one('nodes', from)
    assert_equal(from['name'], to['name'])
    refute_nil(to['serviceInstance'])
    refute_nil(to['machine'])

    # TODO Move these to a test_ip_address method
#    assert_equal(from['ipAddresses'][0]['ipAddressRole'], to['ipAddresses'][0]['ipAddressRole']['name'])
#    assert_equal(from['ipAddresses'][0]['ipAddress'], to['ipAddresses'][0]['ipAddress'])
#    assert_equal(from['ipAddresses'][1]['ipAddressRole'], to['ipAddresses'][1]['ipAddressRole']['name'])
#    assert_equal(from['ipAddresses'][1]['ipAddress'], to['ipAddresses'][1]['ipAddress'])
  end

  def test_map_region
    from = {
      'key' => 'amazon-us-east-1',
      'name' => 'Amazon US East 1',
      'regionKey' => 'US East',
      'infrastructureProvider' => 'amazon'
    }
    to = @mapper.map_one('regions', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
    assert_equal(from['regionKey'], to['regionKey'])
    refute_nil(to['infrastructureProvider'])
  end

  def test_map_rotation_status
    from = {
      'key' => 'enabled',
      'name' => 'Enabled',
      'statusType' => 'success'
    }
    to = @mapper.map_one('rotation-statuses', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
    refute_nil(to['statusType'])
  end

  def test_map_service
    from = {
      'key' => 'seiso',
      'name' => 'Seiso',
      'description' => 'Devops data repo',
      'platform' => 'Java',
      'scmRepository' => 'https://github.com/ExpediaDotCom/seiso',
      'group' => 'devops',
      'type' => 'web-service',
      'owner' => 'wwheeler'
    }
    to = @mapper.map_one('services', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
    assert_equal(from['description'], to['description'])
    assert_equal(from['platform'], to['platform'])
    assert_equal(from['scmRepository'], to['scmRepository'])
    refute_nil(to['group'])
    refute_nil(to['type'])
    refute_nil(to['owner'])
  end

  def test_map_service_group
    from = {
      'key' => 'devops',
      'name' => 'DevOps'
    }
    to = @mapper.map_one('service-groups', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
  end

  def test_map_service_instance
    from = {
      'key' => 'seiso-dev',
      'service' => 'seiso',
      'environment' => 'dev',
      'dataCenter' => 'amazon-us-west-1b',
      'loadBalanced' => true,
      'loadBalancer' => {
        'name' => 'DEV-1-2-3-4'
      },
      'minCapacityDeploy' => 50,
      'minCapacityOps' => 75,
      'ipAddressRoles' => [
        {
          'name' => 'internal',
          'description' => 'Internal role'
        }, {
          'name' => 'partners',
          'description' => 'Partners role'
        }
      ],
      'ports' => [
        {
          'number' => 8443,
          'protocol' => 'https',
          'description' => 'UI port'
        }, {
          'number' => 8444,
          'protocol' => 'https',
          'description' => 'API port'
        }
      ]
    }
    to = @mapper.map_one('service-instances', from)
    assert_equal(from['key'], to['key'])
    
    refute_nil(to['service'])
    refute_nil(to['environment'])
    refute_nil(to['dataCenter'])
    refute_nil(to['loadBalancer'])
    assert_equal(from['loadBalanced'], to['loadBalanced'])
    assert_equal(from['minCapacityDeploy'], to['minCapacityDeploy'])
    assert_equal(from['minCapacityOps'], to['minCapacityOps'])

    # TODO Move these to a test_ip_address_role method
#    assert_equal(from['ipAddressRoles'].length, to['ipAddressRoles'].length)
#    refute_nil(to['ipAddressRoles'][0]['serviceInstance'])
#    refute_nil(to['ipAddressRoles'][1]['serviceInstance'])

    # TODO Move these to a test_service_instance_port method
#    assert_equal(from['ports'].length, to['ports'].length)
#    refute_nil(to['ports'][0]['serviceInstance'])
#    refute_nil(to['ports'][1]['serviceInstance'])
  end

  def test_map_service_type
    from = {
      'key' => 'web-service',
      'name' => 'Web Service'
    }
    to = @mapper.map_one('service-types', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
  end

  def test_map_status_type
    from = {
      'key' => 'warning',
      'name' => 'Warning'
    }
    to = @mapper.map_one('status-types', from)
    assert_equal(from['key'], to['key'])
    assert_equal(from['name'], to['name'])
  end
end
