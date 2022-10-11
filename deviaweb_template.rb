run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY

    gem "devise"
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"

    #________________________________________
    # Gems added manually

    gem 'capistrano', '~> 3.11'
    gem 'capistrano-rails', '~> 1.4'
    gem 'capistrano-passenger', '~> 0.2.0'
    gem 'capistrano-rbenv', '~> 2.1', '>= 2.1.4'
    gem 'ed25519', '~> 1.2', '< 1.3'
    gem 'bcrypt_pbkdf', '~> 1.0', '< 2.0'

    # localisation
    gem 'geocoder'

    # scraping
    gem 'open-uri'
    gem 'nokogiri', '~> 1.6', '>= 1.6.6.2'

    #________________________________________

  RUBY
end

inject_into_file "Gemfile", after: 'gem "debug", platforms: %i[ mri mingw x64_mingw ]' do
<<-RUBY

  gem "dotenv-rails"
RUBY
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')
gsub_file("Gemfile", '# gem "image_processing", "~> 1.2"', 'gem "image_processing", "~> 1.2"')

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

inject_into_file "config/initializers/assets.rb", after: "# Rails.application.config.assets.precompile += %w( admin.js admin.css )" do
  <<~RUBY


    # Custom fonts
    Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
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
      <%= favicon_link_tag asset_path('https://raw.githubusercontent.com/ouic/fullstack-images/master/uikit/logo.png') %>

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
          <%= image_tag "https://raw.githubusercontent.com/ouic/fullstack-images/master/uikit/logo.png", class: "logo" %>
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
            <% if current_user.admin? %>
              <li class="nav-item active">
                <%= link_to "Admin", user_registration_path, class: "btn-navbar" %>
              </li>
            <% end %>
            <li class="nav-item dropdown">
              <%= image_tag "https://raw.githubusercontent.com/ouic/fullstack-images/master/uikit/profile_picture.png", class: "avatar-bordered dropdown-toggle", id: "navbarDropdown", data: { bs_toggle: "dropdown" }, 'aria-haspopup': true, 'aria-expanded': false %>
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

# Home page
########################################
file "app/views/pages/menu.html.erb", <<~HTML
  <div id="wallpaper-gradient">

      <div id="robot" class="col-md-8 col-lg-8">
        <h1>developpeurs<br><br>intelligence artificielle<br>&<br>applications web</h1>
        <%# if user_signed_in? %>
          <%# <p>Bonjour <%= current_user.email</p> %>
        <%# else %>
        <%# end %>
        <%= link_to menu_path do %>
          <p class="home-button">suivant</p>
        <% end %>
      </div>

  </div>
HTML

# Menu page
########################################
file "app/views/pages/menu.html.erb", <<~HTML
  <div id="euclidian">
    <div class="container">
      <h1>Menu</h1>
    </div>

    <div class="container">
      <div class="row">

        <div class="col-md-6 col-lg-4">
          <div class="cards_item">
            <%= link_to menu_path do %>
              <div id="card-1" class="card">
                <div class="card_image">
                  <div class="card_content">
                    <h2 class="card_title">Web</h2>
                    <p class="card_text">Sites internet, IA, applications, blogs</p>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>

        <div class="col-md-6 col-lg-4">
          <div class="cards_item">
            <%= link_to menu_path do %>
              <div id="card-2" class="card">
                <div class="card_image">
                  <div class="card_content">
                    <h2 class="card_title">Forum</h2>
                    <p class="card_text">Discussions, tutoriels, messages</p>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        </div>

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

  run "rm config/routes.rb"
  file "config/routes.rb", <<~RUBY
    Rails.application.routes.draw do

      # devise
      ################################
      devise_for :users
      resources :users

      # pages
      ################################
      # get "/puzzle" => 'pages#puzzle'
      get "/menu" => "pages#menu"

      # home
      ################################
      root to: "pages#home"

      # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

      # Defines the root path route ("/")
      # root "articles#index"
    end
  RUBY

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

  generate("scaffold_controller", "User", "email", "nickname", "first_name", "last_name", "phone_number", "birth_date:date", "gender", "ip_address", "admin:boolean", "address:string", "latitude:float", "longitude:float")
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

      def after_sign_in_path_for(resource)
        stored_location_for(resource) || menu_path
      end

      def after_sign_up_path_for(resource)
        stored_location_for(resource) || menu_path
      end

      def after_sign_out_path_for(resource)
        stored_location_for(resource) || menu_path
      end
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
      skip_before_action :authenticate_user!, only: %i[ home menu puzzle ] # ne pas s'authentifier sur les pages suivantes
      # before_action :authenticate_user!, except: [:show, :index] # ne pas s'authentifier sur les fonctions suivantes

      def home
      end

      def menu
      end

      def puzzle
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

  append_file "package.json", <<~JSON
    import "bootstrap"
  JSON

  # package.json
  ########################################
  run "rm package.json"
  file "package.json", <<~JSON
    {
      "name": "deviaweb.fr",
      "private": "true",
      "dependencies": {
        "@hotwired/stimulus": "^3.1.0",
        "@hotwired/turbo-rails": "^7.2.0",
        "@popperjs/core": "^2.11.6",
        "bootstrap": "^5.2.2",
        "webpack": "^5.74.0",
        "webpack-cli": "^4.10.0"
      },
      "scripts": {
        "build": "webpack --config webpack.config.js"
      }
    }
  JSON

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
