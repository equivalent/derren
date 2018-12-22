module Derren
  def self.call
    a = YAML.load_file('./config.yml')
    p a

  end
end

