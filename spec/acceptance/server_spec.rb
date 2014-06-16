require 'spec_helper_acceptance'

describe 'integration', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'running standard install' do
    it 'should run with no errors' do
      pp = <<-EOS
      class { '::site::roles::base': }
      class { '::site::roles::mysql::server': }
      class { '::site::roles::mysql::newrelic_agent': }
      class { '::site::roles::webserver': }
      class { '::site::roles::memcached': }
      class { '::site::roles::memcached::newrelic_agent': }
      class { '::site::roles::webserver::drush': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      # disabled because several of the modules we depend on run stuff with every execution
      #expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe service('apache2') do
      it {
        should be_enabled
      }
      it {
        should be_running
      }
    end

    describe service('mysql') do
      it {
        should be_enabled
      }
      it {
        should be_running
      }
    end

    describe service('memcached') do
      it {
        should be_enabled
      }
      it {
        should be_running
      }
    end

    describe service('newrelic-daemon') do
      it {
        should be_enabled
      }
      it {
        should be_running
      }
    end

    describe service('newrelic-memcached-java-plugin') do
      it {
        should be_enabled
      }
      it {
        should be_running
      }
    end

    describe service('newrelic-mysql-plugin') do
      it {
        should be_enabled
      }
      it {
        should be_running
      }
    end

    describe service('newrelic-sysmond') do
      it {
        should be_enabled
      }
      it {
        should be_running
      }
    end

    describe port(80) do
      it {
        should be_listening
      }
    end

    describe port(3306) do
      it {
        should be_listening
      }
    end

    describe port(443) do
      it {
        pending("enable SSL support")
        should be_listening
      }
    end

    describe port(11211) do
      it {
        should be_listening
      }
    end

    describe package('php5') do
      it { should be_installed }
    end

    describe package('php5-mysql') do
      it { should be_installed }
    end

    describe package('php5-memcached') do
      it { should be_installed }
    end

    describe package('imagemagick') do
      it { should be_installed }
    end
  end
end
