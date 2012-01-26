class RepositoryConfigs
  attr_accessor :configs

  def initialize(repository)
    @repository = repository
  end

  def write(configs)
    result = {}
    configs.each do |_, config|
      config_name = config.delete("name")
      next unless config_name
      result[config_name] = {}
      config.each do |key, value|
        if key =~ /_count$/
          result[config_name][key] = value.to_i
        elsif key =~ /_methods$/
          result[config_name][key] = value.split(",").map(&:strip)
        end
      end
    end
    File.open(@repository.config_file_path, 'w+') do |file|
      file.write(result.to_yaml)
    end
    notify_remote(result.to_yaml)
  end

  def read
    YAML.load_file(@repository.config_file_path)
  end

  def notify_remote(configs)
    if @repository.update_configs_url?
      Typhoeus::Request.post(@repository.update_configs_url, :params => {:configs => configs})
    end
  end
  handle_asynchronously :notify_remote
end
