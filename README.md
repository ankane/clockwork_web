# Clockwork Web

A web interface for Clockwork

[View the demo](https://clockwork-web.herokuapp.com/)

- see list of jobs
- monitor jobs
- disable jobs

:tangerine: Battle-tested at [Instacart](https://www.instacart.com/opensource)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'clockwork_web'
```

And add it to your `config/routes.rb`.

```ruby
mount ClockworkWeb::Engine, at: "clockwork"
```

Be sure to secure the dashboard in production.

To monitor and disable jobs, hook up Redis in an initializer.

```ruby
ClockworkWeb.redis = Redis.new
```

#### Basic Authentication

Set the following variables in your environment or an initializer.

```ruby
ENV["CLOCKWORK_USERNAME"] = "andrew"
ENV["CLOCKWORK_PASSWORD"] = "secret"
```

#### Devise

```ruby
authenticate :user, lambda {|user| user.admin? } do
  mount ClockworkWeb::Engine, at: "clockwork"
end
```

## Monitoring

```ruby
ClockworkWeb.running?
ClockworkWeb.multiple?
```

## Customize

Change clock path

```ruby
ClockworkWeb.clock_path = Rails.root.join("clock") # default
```

Turn off monitoring

```ruby
ClockworkWeb.monitor = false
```

## TODO

- better design

## History

View the [changelog](CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/clockwork_web/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/clockwork_web/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
