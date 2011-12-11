class RepositoryConfigs
  attr_accessor :configs

  def initialize(repository)
    @repository = repository
  end

  def write
    File.open(@repository.config_file_path, 'w+') do |file|
      file.write(@configs)
    end
  end

  def read
    @configs = YAML.load(File.open(@repository.config_file_path))
  end
end
