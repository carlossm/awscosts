require 'httparty'
require 'json'

class AWSCosts::EBS

  TYPES = { 'Amazon EBS General Purpose (SSD) volumes' => :ssd_general,
            'Amazon EBS Provisioned IOPS (SSD) volumes' => :ssd_provisioned_iops,
            'Amazon EBS Magnetic volumes' => :standard,
            'ebsSnapsToS3' => :snapshots_to_s3 }

  def initialize data
    @data= data
  end

  def price type = nil
    type.nil? ? @data : @data[type]
  end

  def self.fetch region
    transformed = AWSCosts::Cache.get_jsonp('/pricing/1/ebs/pricing-ebs.min.js') do |data|
      result = {}
      data['config']['regions'].each do |r|
        container = {}
        r['types'].each do |type|
          container[TYPES[type['name']]] = {}
          type['values'].each do |value|
            container[TYPES[type['name']]][value['rate']] = value['prices']['USD'].to_f
          end
        end
        result[r['region']] = container
      end
      result
    end
    self.new(transformed[region])
  end

end

