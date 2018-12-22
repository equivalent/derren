module Derren
  def self.call
    config = Config.new('./config.yml')
    puts "Worknig with application: #{config.app.name}"

    binding.irb
    unless config.app.exist?
      config.app.create
    end

    config.app.spas.first(1).each do |spa|
      spa.setup
    end
  end
end


module Derren
  class SPA
    def initialize(name, config:)
      @name = name
      @config = config
    end

    attr_reader :name, :config
    attr_accessor :project_folder_path
    attr_writer :app_path

    def setup
      cmd = "az storage blob service-properties update --account-name #{config.app.name} --static-website --404-document index.html --index-document index.html"
      binding.irb
      res1=  system(cmd)

      res2 = `az storage account show -n #{config.app.name} -g #{config.resource_group} --query "primaryEndpoints.web"`
      binding.irb
        
    end

    def app_path
      @app_path
    end
  end
end

module Derren
  class Application
    attr_reader :name, :config

    def initialize(name, config: config)
      @name = name
      @config = config
    end


    def create
      if system("az storage account create --name #{name} -g #{config.resource_group}")
        true
      else
        raise "Was not able to create storage account #{name}"
      end
    end

    def exist?
      res = `az storage account check-name --name #{name}`
      JSON.parse(res.to_s)['nameAvailable'] # true/false
    end

    def spas
      @spas ||= []
    end
  end
end

module Derren
  class Config
    attr_reader :path

    def initialize(path_to_config)
      @path = path_to_config
    end

    def resource_group
      conf.fetch('resource_group')
    end

    def app
      app_hash = conf.fetch('app')
      app = Application.new(app_hash.fetch('name'), config: self)

      app_hash
        .fetch('spas')
        .each do |name, spa_hash|
          spa = SPA.new(name, config: self)
          spa.app_path = spa_hash['app_path']
          spa.project_folder_path = spa_hash.fetch('project_folder_path')

          app.spas << spa
        end

      app
    end

    private

    def conf
      @conf ||= YAML.load_file(path)
    end
  end
end
