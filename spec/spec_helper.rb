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

#----------------------------------------------------------
# Setup timezone.
#
# Our default timezone is UTC, to avoid local time compromise
# test code seed generation.

ENV['TZ'] = 'UTC'

#----------------------------------------------------------
require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.expand_path('.'))
$LOAD_PATH.unshift(File.expand_path('./libraries'))
$LOAD_PATH.unshift(File.expand_path('./resources'))
$LOAD_PATH.unshift(File.expand_path('../chef-google-auth/lib'))

require 'network_blocker'

# Enable access to localhost as Chef creates a fake HTTP to fetch the proxy
# info. Refer offending code and explanation at:
# chef-12.19.36/lib/chef/monkey_patches/net_http.rb:49
Google::Dns::NetworkBlocker.instance.allowed_test_hosts \
  << { host: '::1', port: 80 }

files = []
files << 'spec/bundle.rb'
files << 'spec/copyright.rb'
files << 'spec/fake_auth.rb'
files << 'spec/fake_cred.rb'
files << 'spec/test_constants.rb'
files << File.join('libraries', '**', '*.rb')
files << File.join('resources', '**', '*.rb')

# Require chef first as spec/credential.rb is dependant
require 'chef'

# Require all files so we can track them via code coverage
Dir[*files].reject { |p| File.directory? p }
           .each do |f|
             puts "Auto requiring #{f}" \
               if ENV['RSPEC_DEBUG']
             require f
           end

require 'pp'
require 'yaml'
require 'chefspec'

# Matchers required for ChefSpec Resource tests
def create(res_type, res_name)
  ChefSpec::Matchers::ResourceMatcher.new(res_type, :create, res_name)
end

def delete(res_type, res_name)
  ChefSpec::Matchers::ResourceMatcher.new(res_type, :delete, res_name)
end

RSpec.configure do |c|
  c.filter_run_excluding broken: true
end
