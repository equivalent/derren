module Derren
  def self.call
    MainMenu.new.call
  end
end

module Derren
  class MainMenu
    attr_reader :config

    def initialize
      @config = Config.new('./config.yml')
    end

    def call
      puts "Worknig with application: #{config.app.name}"
      main_menu_setup = 'Setup'
      main_menu_deploy = 'Deploy'

      case Inputs.pick([
        main_menu_setup,
        main_menu_deploy])
      when main_menu_setup
        config.app.create unless config.app.exist?
        config.app.spas.each { |spa| spa.setup }
      when main_menu_deploy
        spa = pick_spa
        spa.deploy
        puts "\n"
        puts spa.endpoint
      end
    end

    private

    def pick_spa
      deploy_option_list = config.app.spas.map(&:name)
      deploy_option = Inputs.pick(deploy_option_list)
      spa = config.app.spas.find { |spa| spa.name == deploy_option }
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
      "#{app_name}#{name}"
    end

    def app_name
      config.app.name
    end

    def deploy
      cmd = "az storage blob upload-batch --source #{project_folder_path} --destination '$web' --account-name #{combined_name}"
      if system(cmd)
        puts "Deploy of SPA #{name} finished.\n\n#{endpoint}"
      else
        raise "Deploy of SPA #{name} failed"
      end
    end

    def endpoint
      @endpoint ||= endpoint!
    end

    def endpoint!
      cmd = %{az storage account show --name #{combined_name} --resource-group #{app_name}}
      puts cmd
      show_response = `#{cmd}`
      JSON.parse(show_response).fetch("primaryEndpoints").fetch('web')
    end

    def setup
      cmd = "az storage account create --name #{combined_name} --kind StorageV2 --resource-group #{app_name}"
      if system(cmd)
        cmd = "az storage blob service-properties update --account-name #{combined_name} --static-website --404-document index.html --index-document index.html"
        if system(cmd)
          puts "SPA #{name} setup finished (Created under azure storage name#{combined_name}"
        else
          raise "Was not able to make #{combined_name} static website host"
        end
      else
        raise "Was not able to create storage account #{combined_name}"
      end
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
