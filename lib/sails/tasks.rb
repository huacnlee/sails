if defined?(ActiveRecord::Base)
  load 'active_record/railties/databases.rake'

  class << ActiveRecord::Tasks::DatabaseTasks
    def env
      @env ||= Sails.env
    end

    def migrations_paths
      [Sails.root.join("db/migrate")]
    end

    def database_configuration
      YAML.load open(Sails.root.join('config/database.yml')).read
    end

    def db_dir
      Sails.root.join("db")
    end
  end
end

namespace :db do
  namespace :migrate do
    desc "Create new migration file. use `rake db:migrate:create NAME=create_users`"
    task :create do
      name = ENV['NAME']
      abort("no NAME specified. use `rake db:migrate:create NAME=create_users`") if !name

      migrations_dir = File.join("db", "migrate")
      version = ENV["VERSION"] || Time.now.utc.strftime("%Y%m%d%H%M%S")
      filename = "#{version}_#{name}.rb"
      migration_name = name.gsub(/_(.)/) { $1.upcase }.gsub(/^(.)/) { $1.upcase }

      FileUtils.mkdir_p(migrations_dir)

      open(File.join(migrations_dir, filename), 'w') do |f|
        f << (<<-EOS).gsub("        ", "")
        class #{migration_name} < ActiveRecord::Migration
          def self.change
          end
        end
        EOS
      end
      puts filename
    end
  end
end

desc "Generate code from thrift IDL file"
task :generate do
  puts "Generating Thrift code..."
  out = Sails.root.join("app/services/gen-rb")

  cmd = "thrift --gen rb -out #{out} -strict #{Sails.config.app_name}.thrift"
  puts "> #{cmd}"
  system cmd
  puts "[Done]"
end

task :gen => :generate
