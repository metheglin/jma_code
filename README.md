# README

# DEVELOPMENT GUIDE

## REPL

Since `Gemfile` has the line below, you just run `require "jma_code"` in `bundle exec irb` to start `JMACode`.

```
gem "jma_code", path: './'
```

```
bundle install
```

```
bundle exec irb

# (irb):> require "jma_code"
# (irb):> ame_list = JMACode::PointAmedas::Ame.load_20240325
```

## Local Build

Since it has `Rakefile`, you just run the following command to make build and install it on your local.

```
bundle exec rake build
bundle exec rake install
```

Then you just run `require "jma_code"` in `irb` to start `JMACode`.

```
irb

(irb):> require "jma_code"
(irb):> ame_list = JMACode::PointAmedas::Ame.load_20240325
```

## Publish Gem

If you have the right to publish it to rubygems, run it.

```
bundle exec rake build
gem push ./pkg/jma_code-${VERSION}.gem
```
