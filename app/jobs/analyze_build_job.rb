class AnalyzeBuildJob < ActiveJob::Base
  queue_as :default

  def perform(build_id)
    build = Build.find(build_id)
    repository = build.repository
    begin
      start_time = Time.now
      system("mkdir", "-p", build.analyze_path)
      Dir.chdir(build.analyze_path)
      system("git", "clone", repository.clone_url)
      system("rm", "#{repository.name}/.rvmrc")
      Dir.chdir(repository.name)
      system("git", "reset", "--hard", build.last_commit_id)
      system("cp", repository.config_file_path, build.config_directory_path)
      system("rails_best_practices --format yaml --silent --output-file #{build.yaml_output_file} --with-git #{build.analyze_path}/#{repository.name}")
      RailsBestPractices::Core::Runner.base_path = File.join(build.analyze_path, repository.name)
      build.current_errors.each do |error|
        error.highlight = (build.last_errors_memo[error.short_filename + error.message] != error.git_commit)
      end
      File.open(build.html_output_file, 'w+') do |file|
        eruby = Erubis::Eruby.new(File.read(build.template_file))
        file.puts eruby.evaluate(
          :errors         => build.current_errors,
          :github         => true,
          :github_name    => repository.github_name,
          :last_commit_id => build.last_commit_id,
          :git            => true
        )
      end
      end_time = Time.now
      build.warning_count = build.current_errors.size
      build.duration = end_time - start_time
      build.finished_at = end_time
      build.complete!
      repository.touch(:last_build_at)
      UserMailer.notify_build_success(build).deliver if repository.recipient_emails.present?
    rescue => e
      Rollbar.error(e)
      build.fail!
    ensure
      system("rm", "-rf", "#{build.analyze_path}/#{repository.name}")
    end
  end
end
