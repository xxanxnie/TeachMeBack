# TeachMeBack

TeachMeBack is a simple Ruby on Rails SaaS app that lets students exchange skills — like *“I’ll teach you guitar if you help me with Python.”*
---
Team Members:
* Annie Xu – jx2603
* Dylan Tran – dt2758
* Ramya Mohan – rm4105
* Kiel Malate – km3851
---

## Deployment
Heroku: https://teachmeback-e9b7cdefef4f.herokuapp.com/

## What We Accomplished (Iteration 1)
- Implemented the **Explore page** with dashboard features that display and filter skill exchange requests.  
- Built **access-control logic** redirecting logged-out users from protected pages to the login page.  
- Created the **signup and login flow** with `.edu` email validation to ensure only verified students can register.  
- Designed the **Skill Exchange Request model**, database migrations, and related controller actions for creating, listing, and viewing requests.  
- Set up **routes and navigation** between core pages (`/dashboard`, `/explore`, `/login`, `/signup`, `/requests`).  
- Added **Cucumber feature and RSpec tests** for access control, authentication, and dashboard/explore functionality.

## What We Accomplished (Iteration 2)
- Implemented a filtering system that lets users search for partners based on student/instructor role, skill category, and days they are available. These filters are processed in the backend through query parameters and ActiveRecord queries, and the UI supports toggle-style filtering and sorting options.
- Built the reciprocal matching logic. When one user sends a skill-exchange request to another, we store that request. If the second user sends a request back—whether for the same skill or a different one—we detect a mutual match, create a Match record, notify both users, and automatically create a chat channel.
- Implemented the messaging system so matched users can communicate. Each match spawns a Conversation model, and messages store the sender, content, and timestamp. We use ActionCable/WebSockets for real-time chat, and only the two matched users can access the conversation.
- With these features, we now have the full core loop: users can discover others, match, and chat after meeting.

## What We Accomplished (Final Iteration)
- Enhanced the search functionality on the explore page with comprehensive text search that queries across skills and user names.
- Expanded filtering capabilities by adding category-based filtering (`teach_category` and `learn_category`) to skill exchange requests.
- Updated matching algorithm - two users get matched only when what they're teaching and what they want to learn complement each other.
- Added profile enhancements allowing users to customize their profiles with additional fields including bio, location, and university. 


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
bundle exec cucumber

# Run a specific feature file:
bundle exec cucumber features/signup_login.feature
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

## Submission Info
- **Repository:** https://github.com/xxanxnie/TeachMeBack  
- **Iteration:** 1

## Sources
- In addition to using class material and feedback from our TA, we consulted AI for high level guidance, including understanding Rails conventions and framework best practices, and debugging. We also used AI for code suggestions when developing portions of the codebase. All suggestions were reviewed, adapted and integrated by our team.
