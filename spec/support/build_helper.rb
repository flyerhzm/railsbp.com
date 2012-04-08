module Support
  module BuildHelper
    def build_analyze_success
      path = Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321").to_s
      template = Rails.root.join("app/views/builds/rbp.html.erb").to_s
      File.expects(:exist?).with(path).returns(false)
      FileUtils.expects(:mkdir_p).with(path)
      FileUtils.expects(:cd).with(path)

      Git.expects(:clone).with("git://github.com/flyerhzm/railsbp.com.git", "railsbp.com")
      Dir.expects(:chdir).with("railsbp.com")
      FileUtils.expects(:cp).with(Rails.root.join("builds/flyerhzm/railsbp.com/rails_best_practices.yml").to_s, path + "/config")

      rails_best_practices = mock
      RailsBestPractices::Analyzer.expects(:new).with(path + "/railsbp.com", "format" => "html", "silent" => true, "output-file" => path + "/rbp.html", "with-github" => true, "github-name" => "flyerhzm/railsbp.com", "last-commit-id" => "987654321", "with-git" => true, "template" => template).returns(rails_best_practices)
      rails_best_practices.expects(:errors_filter_block=)
      rails_best_practices.expects(:analyze)
      rails_best_practices.expects(:output)

      runner = mock
      rails_best_practices.expects(:runner).returns(runner)
      runner.expects(:errors).returns([])
      FileUtils.expects(:rm_rf).with(path + "/railsbp.com")
      work_off
    end

    def build_analyze_failure
      File.expects(:exist?).raises()
      ExceptionNotifier::Notifier.expects(:background_exception_notification)
      work_off
    end
  end
end
