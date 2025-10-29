# TeachMeBack 🎓

TeachMeBack is a simple Ruby on Rails SaaS app that lets students exchange skills — like *“I’ll teach you guitar if you help me with Python.”*
---
Team Members:
* Annie Xu – jx2603
* Dylan Tran – dt2758
* Ramya Mohan – rm4105
* Kiel Malate – km3851
---

## Setup

### Install Ruby and rbenv (macOS)
```bash

# Install rbenv + ruby-build + sqlite
brew install rbenv ruby-build sqlite3

# Install Ruby
rbenv install 3.4.7
rbenv local 3.4.7

# Install Bundler
gem install bundler

# Create the development & test databases
bin/rails db:create

# Run migrations to create tables
bin/rails db:migrate

# Start app
bin/rails s

=> Booting Puma
=> Rails 8.x application starting in development
=> Listening on http://127.0.0.1:3000
```

## Run RSpec Tests

```bash
# Initialize RSpec (if you haven’t already):
rails generate rspec:install

# Run all RSpec tests:
bundle exec rspec

# Run a specific test file:
bundle exec rspec spec/requests/dashboard_spec.rb
```

## Run Cucumber Tests
```bash
# Initialize Cucumber (if you haven’t already):
rails generate cucumber:install

# Run all feature tests:
bundle exec rspec

# Run a specific feature file:
bundle exec cucumber signup_login.feature
```

## Routes

Root Route:
| Path | Method | Controller#Action | Description |
|------|---------|------------------|--------------|
| `/` | GET | `home#index` | Displays the home or landing page of the app. Serves as the main entry point. |

Core Pages:
| Path | Method | Controller#Action | Description |
|------|---------|------------------|--------------|
| `/explore` | GET | `dashboard#index` | Displays all available skills, users, or exchanges that users can browse. |
| `/match` | GET | `match#index` | Shows mutual matches between users — where one user’s offered skill matches another’s desired skill. |

Skill Exchange Requests:
| Path | Method | Controller#Action | Description |
|------|---------|------------------|--------------|
| `/skill_exchange_requests/new` | GET | `skill_exchange_requests#new` | Shows the form to create a new skill exchange request. |
| `/skill_exchange_requests` | POST | `skill_exchange_requests#create` | Handles submission of a new skill exchange request. |
| `/skill_exchange_requests/:id` | GET | `skill_exchange_requests#show` | Displays details for a specific skill exchange request. |
| `/requests` | GET | `skill_exchange_requests#index` | Lists all skill exchange requests created by or visible to the current user. |

Authentication:
| Path | Method | Controller#Action | Description |
|------|---------|------------------|--------------|
| `/login` | GET | `sessions#new` | Displays the login form for users. |
| `/login` | POST | `sessions#create` | Authenticates user credentials and logs them in. |
| `/logout` | DELETE | `sessions#destroy` | Logs out the current user and ends their session. |

User Management:
| Path | Method | Controller#Action | Description |
|------|---------|------------------|--------------|
| `/signup` | GET | `users#new` | Displays the signup form for new users. |
| `/users` | POST | `users#create` | Creates a new user account after signup form submission. |
| `/profile` | GET | `users#edit` | Displays the current user’s editable profile page. |
| `/profile` | PATCH | `users#update` | Updates and saves user profile changes. |