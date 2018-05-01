# Copyright 2017 Google Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ----------------------------------------------------------------------------
#
#     ***     AUTO GENERATED CODE    ***    AUTO GENERATED CODE     ***
#
# ----------------------------------------------------------------------------
#
#     This file is automatically generated by Magic Modules and manual
#     changes will be clobbered when the file is regenerated.
#
#     Please read more about how to change this file in README.md and
#     CONTRIBUTING.md located at the root of this package.
#
# ----------------------------------------------------------------------------

# Add our google/ lib
$LOAD_PATH.unshift ::File.expand_path('../libraries', ::File.dirname(__FILE__))

require 'chef/resource'
require 'google/dns/network/delete'
require 'google/dns/network/get'
require 'google/dns/network/post'
require 'google/dns/network/put'
require 'google/dns/property/enum'
require 'google/dns/property/integer'
require 'google/dns/property/managedzone_name'
require 'google/dns/property/string'
require 'google/dns/property/string_array'
require 'google/hash_utils'

module Google
  module GDNS
    # A provider to manage Google Cloud DNS resources.
    # rubocop:disable Metrics/ClassLength
    class ResourceRecordSet < Chef::Resource
      resource_name :gdns_resource_record_set

      property :rrs_label,
               String,
               coerce: ::Google::Dns::Property::String.coerce,
               name_property: true, desired_state: true
      property :type,
               equal_to: %w[A AAAA CAA CNAME MX NAPTR NS PTR SOA SPF SRV TXT],
               coerce: ::Google::Dns::Property::Enum.coerce, desired_state: true
      property :ttl,
               Integer,
               coerce: ::Google::Dns::Property::Integer.coerce,
               desired_state: true
      # target is Array of Google::Dns::Property::StringArray
      property :target,
               Array,
               coerce: ::Google::Dns::Property::StringArray.coerce,
               desired_state: true
      property :managed_zone,
               [String, ::Google::Dns::Data::ManagZoneNameRef],
               coerce: ::Google::Dns::Property::ManagZoneNameRef.coerce,
               desired_state: true

      property :credential, String, desired_state: false, required: true
      property :project, String, desired_state: false, required: true

      action :create do
        fetch = fetch_wrapped_resource(@new_resource, 'dns#resourceRecordSet',
                                       'dns#resourceRecordSetsListResponse',
                                       'rrsets')
        if fetch.nil?
          converge_by ['Creating gdns_resource_record_set',
                       "[#{new_resource.name}]"].join do
            # TODO(nelsonjr): Show a list of variables to create
            # TODO(nelsonjr): Determine how to print green like update converge
            puts # making a newline until we find a better way TODO: find!
            compute_changes.each { |log| puts "    - #{log.strip}\n" }
            change = create_change nil, updated_record, new_resource
            change_id = change['id'].to_i
            debug("created for transaction '#{change_id}' to complete")
            wait_for_change_to_complete change_id, @new_resource \
              if change['status'] == 'pending'
          end
        else
          @current_resource = @new_resource.clone
          @current_resource.rrs_label =
            ::Google::Dns::Property::String.api_parse(fetch['name'])
          @current_resource.type =
            ::Google::Dns::Property::Enum.api_parse(fetch['type'])
          @current_resource.ttl =
            ::Google::Dns::Property::Integer.api_parse(fetch['ttl'])
          @current_resource.target =
            ::Google::Dns::Property::StringArray.api_parse(fetch['rrdatas'])

          update
        end
      end

      action :delete do
        fetch = fetch_wrapped_resource(@new_resource, 'dns#resourceRecordSet',
                                       'dns#resourceRecordSetsListResponse',
                                       'rrsets')
        unless fetch.nil?
          converge_by ['Deleting gdns_resource_record_set',
                       "[#{new_resource.name}]"].join do
            change = create_change fetch, nil, @new_resource
            change_id = change['id'].to_i
            debug("created for transaction '#{change_id}' to complete")
            wait_for_change_to_complete change_id, @new_resource \
              if change['status'] == 'pending'
          end
        end
      end

      # TODO(nelsonjr): Add actions :manage and :modify

      private

      action_class do
        def resource_to_request
          request = {
            kind: 'dns#resourceRecordSet',
            name: new_resource.rrs_label,
            type: new_resource.type,
            ttl: new_resource.ttl,
            rrdatas: new_resource.target
          }.reject { |_, v| v.nil? }
          request.to_json
        end

        def update
          converge_if_changed do |_vars|
            # TODO(nelsonjr): Determine how to print indented like upd converge
            # TODO(nelsonjr): Check w/ Chef... can we print this in red?
            puts # making a newline until we find a better way TODO: find!
            compute_changes.each { |log| puts "    - #{log.strip}\n" }
            change = create_change fetch, updated_record, new_resource
            change_id = change['id'].to_i
            debug("created for transaction '#{change_id}' to complete")
            wait_for_change_to_complete change_id, new_resource \
              if change['status'] == 'pending'
          end
        end

        def self.fetch_export(resource, type, id, property)
          return if id.nil?
          resource.resources("#{type}[#{id}]").exports[property]
        end

        def self.resource_to_hash(resource)
          {
            project: resource.project,
            name: resource.rrs_label,
            kind: 'dns#resourceRecordSet',
            type: resource.type,
            ttl: resource.ttl,
            target: resource.target,
            managed_zone: resource.managed_zone
          }.reject { |_, v| v.nil? }
        end

        # Copied from Chef > Provider > #converge_if_changed
        def compute_changes
          properties = @new_resource.class.state_properties.map(&:name)
          properties = properties.map(&:to_sym)
          if current_resource
            compute_changes_for_existing_resource properties
          else
            compute_changes_for_new_resource properties
          end
        end

        # Collect the list of modified properties
        def compute_changes_for_existing_resource(properties)
          specified_properties = properties.select do |property|
            @new_resource.property_is_set?(property)
          end
          modified = specified_properties.reject do |p|
            @new_resource.send(p) == current_resource.send(p)
          end

          generate_pretty_green_text(modified)
        end

        def generate_pretty_green_text(modified)
          property_size = modified.map(&:size).max
          modified.map! do |p|
            properties_str = if @new_resource.sensitive
                               '(suppressed sensitive property)'
                             else
                               [
                                 @new_resource.send(p).inspect,
                                 "(was #{current_resource.send(p).inspect})"
                               ].join(' ')
                             end
            "  set #{p.to_s.ljust(property_size)} to #{properties_str}"
          end
        end

        # Write down any properties we are setting.
        def compute_changes_for_new_resource(properties)
          property_size = properties.map(&:size).max
          properties.map do |property|
            default = ' (default value)' \
              unless @new_resource.property_is_set?(property)
            next if @new_resource.send(property).nil?
            properties_str = if @new_resource.sensitive
                               '(suppressed sensitive property)'
                             else
                               @new_resource.send(property).inspect
                             end
            ["  set #{property.to_s.ljust(property_size)}",
             "to #{properties_str}#{default}"].join(' ')
          end.compact
        end

        def resource_to_query_predicate(resource)
          self.class.resource_to_query_predicate(resource)
        end

        def self.resource_to_query_predicate(resource)
          {
            name: resource.name,
            type: resource.type
          }
        end

        def fetch_auth(resource)
          self.class.fetch_auth(resource)
        end

        def self.fetch_auth(resource)
          resource.resources("gauth_credential[#{resource.credential}]")
                  .authorization
        end

        def fetch_resource(resource, self_link, kind)
          self.class.fetch_resource(resource, self_link, kind)
        end

        def debug(message)
          Chef::Log.debug(message)
        end

        def self.collection(data, extra = '', extra_data = {})
          URI.join(
            'https://www.googleapis.com/dns/v1/',
            expand_variables(
              [
                'projects/{{project}}/managedZones/{{managed_zone}}/changes',
                extra
              ].join,
              data, extra_data
            )
          )
        end

        def collection(data, extra = '', extra_data = {})
          self.class.collection(data, extra, extra_data)
        end

        def self.self_link(data)
          URI.join(
            'https://www.googleapis.com/dns/v1/',
            expand_variables(
              [
                'projects/{{project}}/managedZones/{{managed_zone}}/rrsets',
                '?name={{name}}&type={{type}}'
              ].join,
              data
            )
          )
        end

        def self_link(data)
          self.class.self_link(data)
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def self.return_if_object(response, kind)
          raise "Bad response: #{response.body}" \
            if response.is_a?(Net::HTTPBadRequest)
          raise "Bad response: #{response}" \
            unless response.is_a?(Net::HTTPResponse)
          return if response.is_a?(Net::HTTPNotFound)
          return if response.is_a?(Net::HTTPNoContent)
          result = JSON.parse(response.body)
          raise_if_errors result, %w[error errors], 'message'
          raise "Bad response: #{response}" unless response.is_a?(Net::HTTPOK)
          raise "Incorrect result: #{result['kind']} (expected '#{kind}')" \
            unless result['kind'] == kind
          result
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def return_if_object(response, kind)
          self.class.return_if_object(response, kind)
        end

        def self.extract_variables(template)
          template.scan(/{{[^}]*}}/).map { |v| v.gsub(/{{([^}]*)}}/, '\1') }
                  .map(&:to_sym)
        end

        def self.expand_variables(template, var_data, extra_data = {})
          data = if var_data.class <= Hash
                   var_data.merge(extra_data)
                 else
                   resource_to_hash(var_data).merge(extra_data)
                 end
          extract_variables(template).each do |v|
            unless data.key?(v)
              raise "Missing variable :#{v} in #{data} on #{caller.join("\n")}}"
            end
            template.gsub!(/{{#{v}}}/, CGI.escape(data[v].to_s))
          end
          template
        end

        def updated_record
          {
            kind: 'dns#resourceRecordSet',
            name: @new_resource.rrs_label,
            type: @new_resource.type,
            ttl: @new_resource.ttl.nil? ? 900 : @new_resource.ttl,
            rrdatas: @new_resource.target
          }
        end

        # Wraps the SOA resource to fetch from DNS API
        class SOAResource
          extend Forwardable

          attr_reader :name
          attr_reader :type

          alias rrs_label name

          def_delegators :@resource, :ttl, :target
          def_delegators :@resource, :managed_zone, :project, :credential
          def_delegators :@resource, :resources

          def initialize(args)
            @name = args[:name] || (raise 'Missing "name"')
            @type = args[:type] || (raise 'Missing "type"')
            @resource = SimpleDelegator.new(args[:resource]) \
              || (raise 'Missing "resource"')
          end
        end

        def unwrap_resource(result, resource)
          self.class.unwrap_resource(result, resource)
        end

        def self.unwrap_resource(result, _resource)
          # DNS service already did server-side filtering.
          result.first
        end

        def prefetch_soa_resource
          resource = SOAResource.new(
            type: 'SOA',
            name: "#{@new_resource.rrs_label.split('.').drop(1).join('.')}.",
            resource: @new_resource
          )
          result = fetch_wrapped_resource(resource, 'dns#resourceRecordSet',
                                          'dns#resourceRecordSetsListResponse',
                                          'rrsets')
          if result.nil?
            raise ['Google DNS Managed Zone ', "'#{resource.managed_zone}'",
                   'recipe not found.'].join(' ')
          end
          result
        end

        def create_change(original, updated, resource)
          create_req = ::Google::Dns::Network::Post.new(
            collection(resource), fetch_auth(resource),
            'application/json', resource_to_change_request(original, updated)
          )
          return_if_change_object create_req.send
        end

        # Fetch current SOA. We need the last SOA so we can increment its serial
        def update_soa
          original_soa = prefetch_soa_resource

          # Create a clone of the SOA record so we can update it
          updated_soa = original_soa.clone
          updated_soa.each_key do |k|
            updated_soa[k] = original_soa[k].clone \
              unless original_soa[k].is_a?(Integer)
          end

          soa_parts = updated_soa['rrdatas'][0].split(' ')
          soa_parts[2] = soa_parts[2].to_i + 1
          updated_soa['rrdatas'][0] = soa_parts.join(' ')
          [original_soa, updated_soa]
        end

        def resource_to_change_request(original_record, updated_record)
          original_soa, updated_soa = update_soa
          result = new_change_request
          add_additions result, updated_soa, updated_record
          add_deletions result, original_soa, original_record
          ::Google::HashUtils.camelize_keys(result).to_json
        end

        def add_additions(result, updated_soa, updated_record)
          result[:additions] << updated_soa unless updated_soa.nil?
          result[:additions] << updated_record unless updated_record.nil?
        end

        def add_deletions(result, original_soa, original_record)
          result[:deletions] << original_soa unless original_soa.nil?
          result[:deletions] << original_record unless original_record.nil?
        end

        # TODO(nelsonjr): Merge and delete this code once async operations
        # declared in api.yaml is moved to master from:
        #   https://cloud-internal.googlesource.com/cloud-graphite-team/
        #   config-modules/codegen/+/
        #   2ccb0eb5cb207f67b297c6058d2455240d7316bf/
        #   compute/api.yaml#9
        def wait_for_change_to_complete(change_id, resource)
          status = 'pending'
          while status == 'pending'
            debug("waiting for transaction '#{change_id}' to complete")
            status = get_change_status(change_id, resource)
            sleep(0.5) unless status == 'done'
          end
          debug("transaction '#{change_id}' complete")
        end

        def get_change_status(change_id, resource)
          change_req = ::Google::Dns::Network::Get.new(
            collection(resource, '/{{id}}', id: change_id), fetch_auth(resource)
          )
          return_if_change_object(change_req.send)['status']
        end

        def new_change_request
          {
            kind: 'dns#change',
            additions: [],
            deletions: [],
            start_time: Time.now.iso8601
          }
        end

        def return_if_change_object(response)
          raise "Bad request: #{response.body}" \
            if response.is_a?(Net::HTTPBadRequest)
          raise "Bad response: #{response}" \
            unless response.is_a?(Net::HTTPResponse)
          return unless response.class >= Net::HTTPOK
          result = JSON.parse(response.body)
          raise "Incorrect result: #{result['kind']}" \
            unless result['kind'] == 'dns#change'
          result
        end

        def fetch_resource(resource, self_link, kind)
          self.class.fetch_resource(resource, self_link, kind)
        end

        def self.fetch_resource(resource, self_link, kind)
          get_request = ::Google::Dns::Network::Get.new(
            self_link, fetch_auth(resource)
          )
          return_if_object get_request.send, kind
        end

        def fetch_wrapped_resource(resource, kind, wrap_kind, wrap_path)
          self.class.fetch_wrapped_resource(resource, kind, wrap_kind,
                                            wrap_path)
        end

        def self.fetch_wrapped_resource(resource, kind, wrap_kind, wrap_path)
          result = fetch_resource(resource, self_link(resource), wrap_kind)
          return if result.nil? || !result.key?(wrap_path)
          result = unwrap_resource(result[wrap_path], resource)
          return if result.nil?
          raise "Incorrect result: #{result['kind']} (expected #{kind})" \
            unless result['kind'] == kind
          result
        end

        def self.raise_if_errors(response, err_path, msg_field)
          errors = ::Google::HashUtils.navigate(response, err_path)
          raise_error(errors, msg_field) unless errors.nil?
        end

        def self.raise_error(errors, msg_field)
          raise IOError, ['Operation failed:',
                          errors.map { |e| e[msg_field] }.join(', ')].join(' ')
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
