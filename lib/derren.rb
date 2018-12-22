module Derren
  def self.call
    conf = Config.new('./config.yml')
    p conf.app.name
    p conf.app.spas.first.app_path
  end
end


module Derren
  class SPA
    def initialize(name)
      @name = name
    end

    attr_reader :name
    attr_accessor :project_folder_path
    attr_writer :app_path

    def app_path
      @app_path
    end
  end
end

module Derren
  class Application
    attr_reader :name

    def initialize(name)
      @name = name
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
      app = Application.new(app_hash.fetch('name'))

      app_hash
        .fetch('spas')
        .each do |name, spa_hash|
          spa = SPA.new(name)
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
