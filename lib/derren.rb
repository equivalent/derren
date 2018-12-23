
module Derren
  def self.call
    config = Config.new('./config.yml')
    puts "Worknig with application: #{config.app.name}"

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

    def combined_name
      "#{config.app.name}#{name}"
    end

    def setup
      endpoint = nil
      cmd = "az storage account create --name #{combined_name} --kind StorageV2 --resource-group #{config.app.name}"
      if system(cmd)
        cmd = "az storage blob service-properties update --account-name #{combined_name} --static-website --404-document index.html --index-document index.html"
        if system(cmd)

          cmd = %{az storage account show --name #{combined_name} --resource-group #{config.app.name}}
          show_response = `cmd`
          endpoint = JSON.parse(show_response).fetch("primaryEndpoints.web")
        else
          raise "Was not able to make #{combined_name} static website host"
        end
      else
        raise "Was not able to create storage account #{combined_name}"
      end
      endpoint
    end

    def sync
      # 'az storage blob upload-batch -s <SOURCE_PATH> -d $web --account-name <ACCOUNT_NAME>'
    end

    def app_path
      @app_path
    end
  end
end

module Derren
  class Application
    attr_reader :name, :location

    def initialize(name:, location:)
      @name = name
      @location = location
    end

    def create
      if system("az group create --name #{name} --location #{location}")
        true
      else
        raise "Was not able to create storage account #{name}"
      end
    end

    def exist?
      res = `az storage account check-name --name #{name}`
      avalible = JSON.parse(res.to_s)['nameAvailable'] # true/false
      !avalible
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

    def app
      app_hash = conf.fetch('app')
      app = Application.new(
        name: app_hash.fetch('name'),
        location: app_hash.fetch('location'))

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

    def location
      conf.fetch('location')
    end

    private

    def conf
      @conf ||= YAML.load_file(path)
    end
  end
end
