[![Gem Version](https://badge.fury.io/rb/graphqr.svg)](https://rubygems.org/gems/graphqr)
[![Build Status](https://travis-ci.com/QultureRocks/graphqr.svg?branch=master)](https://travis-ci.com/QultureRocks/graphqr)
[![Maintainability](https://api.codeclimate.com/v1/badges/7f7b51e89e8fe4de1b23/maintainability)](https://codeclimate.com/github/QultureRocks/graphqr/maintainability)

# GraphQR

A compilation of useful extensions and helpers for [graphql-ruby](https://github.com/rmosolgo/graphql-ruby).

- [API Documentation](https://qulturerocks.github.io/graphqr/)
- [Qulture.Rocks](https://qulture.rocks)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphqr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphqr

## Configuration (optional)

GraphQR uses `pagy` and `pundit` by default and activates both `Authorization` and `Pagination` modules.
If you'd like to create a specific configuration, create `config/initializers/graphql.rb` with

```
GraphQR.configure do |config|
  config.use_pagination = true # or false to disable
  config.use_authorization = true # or false to disable

  config.paginator = :pagy # only pagy is available for now
  config.policy_provider = :pundit # only pundit is available for now
end
```

## Modules

To use the extensions correctly add
```
field_class GraphQR::Fields::BaseField
```

to your `BaseObject` class. This will add the `paginate` options to your fields and add the necessary extensions according to the modules you activated.

### Pagination

The Pagination module consists in a easier way of dealing with pages. Instead of using `cursors` we implemented a more Rails way using `per` and `page`.
Our implementation is (for now) based on [Pagy](https://github.com/ddnexus/pagy) so you must have it installed.

To use the Pagination module add

```
extend GraphQR::Pagination
```

to any `GraphQL::Schema::Object` you'd like, but we recommend adding it to your `BaseObject` class.

#### Usage

```
field :users, UserType.pagination_type, paginate: true
```

A `pagination_type` adds the `per` and `page` arguments and adds a `page_info` field to the response.

Example gql:
```
users(per: 10, page: 1) {
  nodes {
    id
    name
  }
}
```

### Authorization

The Authorization module in some wrappers around a `PolicyProvider` (only Pundit for now). And allows some basic behaviors.
Everything on this module depends on a `policy_provider` passed to the GraphQL context. You can add it like this:

```
context = {
  policy_provider: GraphQR::Policies::PunditProvider.new(policy_context: pundit_user)
  ...
}

Schema.execute(query, variables: variables, context: context, operation_name: operation_name)
```

#### Authorized

This module adds a check on the object policy before resolving it. It always searches for the `show?` policy of the record.
It works by extending the `authorized?` method.

To add this behavior, add
```
extend GraphQR::Authorized
```
to any `GraphQL::Schema::Object` you'd like, but we recommend adding it to your `BaseObject` class.

Example:

```
users {
  id
  tags {
    id
  }
}
```

In this case, the authorization check will run for each `user`, calling `UserPolicy.show?` and for each tag, calling `TagPolicy.show?`.
If any policy returns falsy, the object is returned as `null`.

#### ScopeItems

This module adds the PolicyProvider scope to the fields that represent an `ActiveRecord::Relation`. It works by implementing the `self.scope_items` method.

To add this behavior, add
```
extend GraphQR::ScopeItems
```
to any `GraphQL::Schema::Object` you'd like, but we recommend adding it to your `BaseObject` class.

Example:

```
users {
  id
}
```

In this case, the `users` list will be scoped using `UserPolicy::Scope` provided by Pundit.

#### AuthorizeGraphQL

This module is a wrapper around the PolicyProvider authorization.
It adds the `authorize_graphql` method, similar to Pundit's `authorize`, but it returns an `GraphQL::ExecutionError` instead of a `Pundit::NotAuthorizedError`

To add this behavior, add
```
include GraphQR::AuthorizeGraphQL
```
where you want to use this methos, but we recommend adding it to your `Mutations` and `Resolvers` classes.

Example:

```
authorize_graphql User, :index?
```

### Helpers

We also provide some helpers to make implementing GraphQL on ruby easier.

#### ApplyScopes

This modules is based on the [has_scope](https://github.com/plataformatec/has_scope/) gem.
It provides an `apply_scopes` method that can search for model scopes and use them on a collection

To add this method, add
```
include GraphQR::ApplyScopes
```
where you'd like to use it, but we recommend adding it to your `Resolvers`.

Example:

```
apply_scopes(User, { order_by_name: true, with_id: [1,2,3] })
```

#### QueryField

This module adds the `query_field` helper.
It adds an easy way of creating simple fields with resolvers.

To add this method, add
```
extend GraphQR::QueryField
```
to your `BaseObject`.

Read more about its use in the [documentation](https://qulturerocks.github.io/graphqr/GraphQR/QueryField.html)


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/QultureRocks/graphqr. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GraphQR project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/QultureRocks/graphqr/blob/master/CODE_OF_CONDUCT.md).
