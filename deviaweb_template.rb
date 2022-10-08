run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "devise"
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"
  RUBY
end

inject_into_file "Gemfile", after: 'gem "debug", platforms: %i[ mri mingw x64_mingw ]' do
<<-RUBY

  gem "dotenv-rails"
RUBY
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')

# Assets
########################################
run "rm -rf app/assets/stylesheets"
run "rm -rf vendor"
run "curl -L https://github.com/lewagon/rails-stylesheets/archive/master.zip > stylesheets.zip"
run "unzip stylesheets.zip -d app/assets && rm -f stylesheets.zip && rm -f app/assets/rails-stylesheets-master/README.md"
run "mv app/assets/rails-stylesheets-master app/assets/stylesheets"

inject_into_file "config/initializers/assets.rb", before: "# Precompile additional assets." do
  <<~RUBY
    Rails.application.config.assets.paths << Rails.root.join("node_modules")
  RUBY
end

# Production
########################################

file "config/deploy/production.rb", <<~RUBY
    # config/deploy/production.rb

    # server-based syntax
    # ======================
    # Defines a single server with a list of roles and multiple properties.
    # You can define all roles on a single server, or split them:

    # server "example.com", user: "deploy", roles: %w{app db web}, my_property: :my_value
    # server "example.com", user: "deploy", roles: %w{app web}, other_property: :other_value
    # server "db.example.com", user: "deploy", roles: %w{db}

    server '37.187.119.17', user: 'ouic', roles: %w{app db web}

    # role-based syntax
    # ==================

    # Defines a role with one or multiple servers. The primary server in each
    # group is considered to be the first unless any hosts have the primary
    # property set. Specify the username and a domain or IP for the server.
    # Don't use `:all`, it's a meta role.

    # role :app, %w{deploy@example.com}, my_property: :my_value
    # role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
    # role :db,  %w{deploy@example.com}



    # Configuration
    # =============
    # You can set any configuration variable like in config/deploy.rb
    # These variables are then only loaded and set in this stage.
    # For available Capistrano configuration variables see the documentation page.
    # http://capistranorb.com/documentation/getting-started/configuration/
    # Feel free to add new variables to customise your setup.



    # Custom SSH Options
    # ==================
    # You may pass any option but keep in mind that net/ssh understands a
    # limited set of options, consult the Net::SSH documentation.
    # http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
    #
    # Global options
    # --------------
    #  set :ssh_options, {
    #    keys: %w(/home/user_name/.ssh/id_rsa),
    #    forward_agent: false,
    #    auth_methods: %w(password)
    #  }
    #
    # The server-based syntax can be used to override options:
    # ------------------------------------
    # server "example.com",
    #   user: "user_name",
    #   roles: %w{web app},
    #   ssh_options: {
    #     user: "user_name", # overrides user setting above
    #     keys: %w(/home/user_name/.ssh/id_rsa),
    #     forward_agent: false,
    #     auth_methods: %w(publickey password)
    #     # password: "please use keys"
    #   }

RUBY

inject_into_file "config/deploy.rb", before: "# Optionally, you can symlink your database.yml and/or secrets.yml file from the shared directory during deploy" do
  <<~RUBY
    set :application, "deviaweb.fr"
    set :repo_url, "git@github.com:ouic/deviaweb.fr.git"

    # Deploy to the user's home directory
    set :deploy_to, "/home/ouic/#{fetch :application}"

    # append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads', 'public/packs', 'node_modules'
    append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

    # Only keep the last 5 releases to save disk space
    set :keep_releases, 5
  RUBY
end

inject_into_file "Capfile", after: '# require "capistrano/passenger"' do
  <<~RUBY
    # Load custom tasks from `lib/capistrano/tasks` if you have any defined
    Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

    require 'capistrano/rails'
    require 'capistrano/passenger'
    require 'capistrano/rbenv'

    set :rbenv_type, :user
    set :rbenv_ruby, '3.1.2'
  RUBY
end

# Layout
########################################

gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)

# Flashes
########################################
file "app/views/shared/_flashes.html.erb", <<~HTML
  <% if notice %>
    <div class="alert alert-info alert-dismissible fade show m-1" role="alert">
      <%= notice %>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close">
      </button>
    </div>
  <% end %>
  <% if alert %>
    <div class="alert alert-warning alert-dismissible fade show m-1" role="alert">
      <%= alert %>
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close">
      </button>
    </div>
  <% end %>
HTML

run "curl -L https://raw.githubusercontent.com/lewagon/awesome-navbars/master/templates/_navbar_wagon.html.erb > app/views/shared/_navbar.html.erb"

inject_into_file "app/views/layouts/application.html.erb", after: "<body>" do
  <<~HTML
    <%= render "shared/navbar" %>
    <%= render "shared/flashes" %>
  HTML
end

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with [ouic/rails-templates](https://github.com/ouic/rails-templates), created by the [Deviaweb coding](https://www.deviaweb.fr) team.
MARKDOWN
file "README.md", markdown_file_content, force: true

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

########################################
# After bundle
########################################
after_bundle do
  # Generators: db  + pages controller
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate(:controller, "pages", "home", "--skip-routes", "--no-test-framework")

  # Routes
  ########################################
  route 'root to: "pages#home"'

  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
    # Ignore .env file containing credentials.
    .env*
    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Devise install + user
  ########################################
  generate("devise:install")
  generate("devise", "User")

  # Application controller
  ########################################
  run "rm app/controllers/application_controller.rb"
  file "app/controllers/application_controller.rb", <<~RUBY
    class ApplicationController < ActionController::Base
      before_action :authenticate_user!
    end
  RUBY

  # migrate + devise views
  ########################################
  rails_command "db:migrate"
  generate("devise:views")
  link_to = <<~HTML
    <p>Unhappy? <%= link_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete %></p>
  HTML
  button_to = <<~HTML
    <div class="d-flex align-items-center">
      <div>Unhappy?</div>
      <%= button_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete, class: "btn btn-link" %>
    </div>
  HTML
  gsub_file("app/views/devise/registrations/edit.html.erb", link_to, button_to)

  # Pages Controller
  ########################################
  run "rm app/controllers/pages_controller.rb"
  file "app/controllers/pages_controller.rb", <<~RUBY
    class PagesController < ApplicationController
      skip_before_action :authenticate_user!, only: [ :home ]

      def home
      end
    end
  RUBY

  # Environments
  ########################################
  environment 'config.action_mailer.default_url_options = { host: "http://localhost:3000" }', env: "development"
  environment 'config.action_mailer.default_url_options = { host: "http://www.deviaweb.fr" }', env: "production"

  # Yarn
  ########################################
  run "yarn add bootstrap @popperjs/core"
  append_file "app/javascript/application.js", <<~JS
    import "bootstrap"
  JS

  # Heroku
  ########################################
  run "bundle lock --add-platform x86_64-linux"

  # Dotenv
  ########################################
  run "touch '.env'"

  # Rubocop
  ########################################
  run "curl -L https://raw.githubusercontent.com/lewagon/rails-templates/master/.rubocop.yml > .rubocop.yml"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with devise template from https://github.com/ouic/rails-templates'"
end
