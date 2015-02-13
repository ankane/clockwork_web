# Clockwork Web

A web interface for [Clockwork](https://github.com/tomykaira/clockwork)

- see list of jobs
- see last run
- disable jobs

Screenshot, demo, and better UI coming soon

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

To see the last run and disable jobs, hook up Redis.

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

## TODO

- demo
- better design

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/clockwork_web/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/clockwork_web/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
