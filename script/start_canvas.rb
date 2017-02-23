#!/usr/bin/env ruby
require 'erb'
require 'yaml'
require 'pg'

class DatabaseStatus
  @@max_retries = 120

  def initialize(yaml_config = "/usr/src/app/config/database.yml", environment = ENV["RAILS_ENV"])
    @yaml_config = yaml_config
    @environment = environment
  end

  def reachable?
    retries = 0
    until ready? || retries > @@max_retries
      sleep 2
      retries += 1
    end
    retries <= @@max_retries
  end

  def populated?(table_name = 'users')
    !!PG::Connection.new(db_configuration) { |conn| conn.exec( "SELECT * FROM #{table_name}") }
  rescue
    false
  end

  private

  def ready?
    PG::Connection.ping(db_configuration) == PG::PQPING_OK
  end

  def db_configuration
    @db_configuration ||= begin
      configuration = YAML.load(ERB.new(File.read(@yaml_config)).result)[@environment]
      {
        host: configuration['host'],
        port: 5432,
        dbname: configuration['database'],
        user: configuration['username'],
        password: configuration['password'],
        connect_timeout: configuration['timeout']
      }
    end
  end
end

# Sometimes won't output properly so we force it to sync
$stdout.sync = true
puts '---- Attempting to reach Postgres ----'
database_container = DatabaseStatus.new
abort '---- Postgres is unreachable ----' unless database_container.reachable?

commands = ["./node_modules/.bin/brandable_css", "bundle exec unicorn -p 3000 -c config/unicorn.rb"]
commands.unshift("bundle exec rake db:create", "bundle exec rake db:initial_setup") unless database_container.populated?

command_string = "bash -c \"#{commands.join(" && ")}\""
puts "---- Starting command list ----", command_string
system( command_string )
