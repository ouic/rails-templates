run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "devise"
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"
    gem "image_processing", "~> 1.2"

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

# Layout
########################################

# gsub_file(
#   "app/views/layouts/application.html.erb",
#   '<meta name="viewport" content="width=device-width,initial-scale=1">',
#   '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
# )

# application.html.erb
########################################
run "rm -rf app/views/layouts/application.html.erb"
file "app/views/layouts/application.html.erb", <<~HTML
<!DOCTYPE html>
<html>
  <head>
    <!-- titre et description -->
    <title>Deviaweb</title>
    <meta name="description" content="Développeurs intelligence artificielle et applications Web">

    <!-- responsive -->
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <!-- CSS Javascript -->
    <%= stylesheet_link_tag "application", media: 'all', "data-turbo-track": "reload" %>
    <%= javascript_include_tag "application", "data-turbo-track": "reload", defer: true %>

    <!-- favicon -->
    <%= favicon_link_tag asset_path('https://raw.githubusercontent.com/ouic/fullstack-images/master/uikit/deviaweb_logo_et_fond.png') %>

    <!-- compatibilité microsoft Edge -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <!-- bootstrap -->
    <%# <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css"> %>

    <!-- fontawesome -->
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.10/css/all.css">
  </head>

  <body>
      <%= render "shared/navbar" %>
      <%= render "shared/flashes" %>

      <%= yield %>

      <!-- Including Bootstrap JS (with its Popper.js / jQuery dependency) so that dynamic components work -->
      <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
      <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.1/dist/umd/popper.min.js"></script>
      <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

  </body>
</html>
HTML

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

# inject_into_file "app/views/layouts/application.html.erb", after: "<body>" do
#   <<~HTML
#     <%= render "shared/navbar" %>
#     <%= render "shared/flashes" %>
#   HTML
# end

# navbar.html.erb
########################################
run "curl -L https://raw.githubusercontent.com/lewagon/awesome-navbars/master/templates/_navbar_wagon.html.erb > app/views/shared/_navbar.html.erb"

run "rm -rf app/views/shared/_navbar.html.erb"

file "app/views/shared/_navbar.html.erb", <<~HTML
<div class="navbar navbar-expand-sm navbar-light navbar-lewagon">
  <div class="container-fluid">
    <div class="logo">
      <%= link_to root_path, class: "navbar-brand" do %>
        <%= image_tag "logo.png", class: "logo" %>
        <h1>Dev<br>ia<br>web</h1>
      <% end %>
    </div>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarSupportedContent">
      <ul class="navbar-nav me-auto">
        <% if user_signed_in? %>
          <li class="nav-item active">
            <%= link_to "Menu", menu_path, class: "btn-navbar" %>
          </li>
          <li class="nav-item dropdown">
            <%= image_tag "profile_picture.png", class: "avatar-bordered dropdown-toggle", id: "navbarDropdown", data: { bs_toggle: "dropdown" }, 'aria-haspopup': true, 'aria-expanded': false %>
            <div class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown">
              <%= link_to "Menu", menu_path, class: "dropdown-item" %>
              <%= link_to "Déconnexion", destroy_user_session_path, data: {turbo_method: :delete}, class: "dropdown-item" %>
            </div>
          </li>
        <% else %>
          <li class="nav-item">
            <%= link_to "S'inscrire", new_user_registration_path, class: "btn-navbar" %>
            <%= link_to "Connexion", new_user_session_path, class: "btn-navbar" %>
          </li>
        <% end %>
      </ul>
    </div>
  </div>
</div>
HTML

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
  generate("devise", "User", "nickname", "first_name", "last_name", "phone_number", "birth_date:date", "gender", "ip_address", "admin:boolean")

  # generate("devise", "User", "nickname", "first_name", "last_name", "phone_number", "birth_date:date", "gender", "ip_address", "admin:boolean")
  # (à tester) rails g scaffold_controller User email nickname first_name last_name phone_number birth_date:date gender ip_address admin:boolean
  # then uncomment trackable lines

  # set admin boolean to false by default
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end

  generate("scaffold_controller", "User", "email", "nickname", "first_name", "last_name", "phone_number", "birth_date:date", "gender", "ip_address", "admin:boolean")
  gsub_file(
    "config/routes.rb",
    '  resources :users',
    ''
  )

  # config navigational_formats
  inject_into_file "config/initializers/devise.rb", after: "# config.navigational_formats = ['*/*', :html]" do
    <<-RUBY
      config.navigational_formats = ['*/*', :html, :turbo_stream]
    RUBY
  end

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
