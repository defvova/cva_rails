# cva_rails

> A tiny and simple gem for variant-based styling logic.

This gem offers a lightweight and straightforward solution for managing dynamic class names and
style variants in Ruby on Rails applications. It draws inspiration from the popular
[<strong>C</strong>lass <strong>V</strong>ariance <strong>A</strong>uthority (CVA)](https://github.com/joe-bell/cva) package from the JavaScript ecosystem.

By defining a collection of named style rules, the gem helps developers easily handle conditional styling based on schemas and runtime parameters. It’s particularly useful when working with complex UI states requiring dynamic styling.

## Supported Ruby and Rails versions

Ruby 3.1+ and Rails 7.0+ are supported.

<strong>Dependency: [clsx-rails](https://github.com/svyatov/clsx-rails)</strong>

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add cva_rails
```

Or add it manually to the Gemfile:

```ruby
gem 'cva_rails', '~> 1.0'
```

## Usage

The cva method allows you to define and manage class variants for your components efficiently.

Syntax
```ruby
cva(base_classes, variants)
```

1.  base_classes (String or Array)
A set of base CSS classes applied to the component by default.
2.  variants (Hash)
Defines the available style variants and their possible values.

Example Usage
```ruby
# app/components/alert_component.rb
class Alert
  include Cva::Helper

  cva("relative w-full rounded-lg border px-4 py-3 text-sm "\
      "[&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground [&>svg~*]:pl-7", {
    variants: {
      variant: {
        primary: "bg-background text-foreground",
        destructive:
          "border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive",
      },
      size: {
        small: "px-3 py-2",
        medium: "px-5 py-4"
      }
    },
  })
end
```

Rendered in a view as:

```erb
<div class="<%= Alert.variants({ variant: :primary, size: :small }) %>"></div>
<div class="<%= Alert.variants({ variant: :destructive, size: :medium }) %>"></div>
```

How it works
```ruby
Alert.variants({ variant: :primary, size: :small })
```
This method call combines the base classes of the Alert component with the classes defined for the :primary and :small variants.
- The base classes are always applied to the component.
- The selected variant classes (:primary and :small) are conditionally added, resulting in a combined class list.

This approach helps manage styling variations cleanly and efficiently.

## Compound Components

For larger, more complex components, you may end up wanting to create a set of composable components that work together.

```ruby
class BtnComponent
  include Cva::Helper

  cva("border px-4 py-2", {
    variants: {
      size: {
        small: "text-sm",
        medium: "text-base"
      },
      color: {
        green: "text-green-100",
        blue: "text-blue-100"
      }
    },
    compound_variants: [
      {
        size: :small,
        class: "h-10"
      }
    ]
  })
end

BtnComponent.variants({ size: :medium, color: :green }) # => border px-4 py-2 text-green-100 text-base
BtnComponent.variants({ size: :small, color: :green })  # => border px-4 py-2 text-green-100 text-base h-10
```

## Default Variants

You can define default variants in the schema to
automatically apply specific styles when no variant is explicitly provided.

```ruby
class BtnComponent
  include Cva::Helper

  cva("border px-4 py-2", {
    variants: {
      size: {
        small: "text-sm",
        medium: "text-base"
      },
      color: {
        green: "text-green-100",
        blue: "text-blue-100"
      }
    },
    compound_variants: [
      {
        size: :small,
        class: "h-10"
      }
    ],
    default_variants: {
      size: :medium,
      color: :green
    }
  })
end

BtnComponent.variants # => border px-4 py-2 text-green-100 text-base
```

## Example with TailwindCSS, [ViewComponent](https://viewcomponent.org/) and [TailwindMerge](https://github.com/gjtorikian/tailwind_merge)

ViewComponent is a framework for creating reusable, testable & encapsulated view components, built to integrate seamlessly with Ruby on Rails.
TailwindMerge is utility function to efficiently merge Tailwind CSS classes without style conflicts.

```ruby
# app/components/button_component.rb

class ButtonComponent < ViewComponent::Base
  include Cva::Helper

  cva("inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm "\
      "font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 "\
      "focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 "\
      "[&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0", {
        variants: {
          variant: {
            default:
              "bg-primary text-primary-foreground shadow hover:bg-primary/90",
            destructive:
              "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90",
            outline:
              "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground",
            secondary:
              "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80",
            ghost: "hover:bg-accent hover:text-accent-foreground",
            link: "text-primary underline-offset-4 hover:underline",
          },
          size: {
            default: "h-9 px-4 py-2",
            sm: "h-8 rounded-md px-3 text-xs",
            lg: "h-10 rounded-md px-8",
            icon: "h-9 w-9",
          },
        }
      })

  erb_template <<-ERB
    <a href="<%= @href %>" class="<%= TailwindMerge::Merger.new.merge(variants(@style_variants)) %>"><%= content %></a>
  ERB

  def initialize(href:, style_variants = {})
    @href = href
    @style_variants = style_variants
  end
end
```

Rendered in a view as:

```erb
<%= render(ButtonComponent.new(href: submit_path, { variant: :outline, size: :lg })) do %>
  Submit
<% end %>
```

Returning:
```html
<a href="/submit" class="base classes + outline classes + size classes">Submit</a>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and the created tag,
and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Conventional Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages.

Types of commits are:
- `feat`: a new feature
- `fix`: a bug fix
- `perf`: code that improves performance
- `chore`: updating build tasks, configs, formatting etc; no code change
- `docs`: changes to documentation
- `refactor`: refactoring code

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/defvova/cva_rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
