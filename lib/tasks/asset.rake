# lib/tasks/assets.rake
# The webpack task must run before assets:environment task.
# Otherwise Sprockets cannot find the files that webpack produces.
# This is the secret sauce for how a Heroku deployment knows to create the webpack generated JavaScript files.
# Rake::Task["assets:precompile"]
#   .clear_prerequisites
#   .enhance(["assets:compile_environment"])

namespace :asset do
  # In this task, set prerequisites for the assets:precompile task
  task compile_environment: :webpack do
    # return
    # Rake::Task["assets:environment"].invoke
  end

  desc "Compile assets with webpack"
  task :webpack do
    # return
    # if Rails.env.development?
    #   sh "cd client && npm run build:client"
    # else
    #   sh "npm install && cd client && npm run build:production:client"
    # end
  end

  task :clobber do
    # return
    # rm_r Dir.glob(Rails.root.join("app/assets/javascripts/generated/*"))
  end
end