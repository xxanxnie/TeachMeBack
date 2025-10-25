# TeachMeBack 🎓

TeachMeBack is a simple Ruby on Rails SaaS app that lets students exchange skills — like *“I’ll teach you guitar if you help me with Python.”*

---

## 🚀 Getting Started

### 1️⃣ Install Ruby and rbenv (macOS)
```bash
# Install rbenv + ruby-build
brew install rbenv ruby-build

# Install Ruby
rbenv install 3.4.7
rbenv local 3.4.7

# Install Bundler
gem install bundler

# Create the development & test databases
bin/rails db:create

# Run migrations to create tables (users, skill_exchange_requests, etc.)
bin/rails db:migrate

# Start app
bin/rails s

=> Booting Puma
=> Rails 8.x application starting in development
=> Listening on http://127.0.0.1:3000
```

Request skill
http://localhost:3000/skill_exchange_requests/new