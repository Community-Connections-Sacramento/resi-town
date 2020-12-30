# ResiTown Sacramento

This repository stores the code for the ResiTown Sacramento website.

The stack is:

- Ruby on Rails 6.0
- Tailwind CSS
- Postgres

# Running app locally

## Dependencies

- ruby `2.6.3`
- bundler `2.1.4`
- postgres

## Installation

Install and start postgresql:
- On macOS, you can use `pg_ctl -D /usr/local/var/postgres start`
- (To stop postgres use `pg_ctl -D /usr/local/var/postgres stop`)

Install dependencies:

```
bundle install
yarn install
```

Setup the database and seed data:

```
rails db:setup
```

## Configuration

Check config/initializers to edit admins, team, and email settings. All other settings can be configured in settings.yml

## Launch app

```
rails server
```

Then go to [http://localhost:3000](http://localhost:3000) to view app.


## Installation

See THEMING.md.

# Contributing

1. Fork the project
1. Create a branch with your changes
1. Submit a pull request

# License

MIT
