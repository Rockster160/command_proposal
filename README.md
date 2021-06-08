# CommandProposal

Rake Tasks are cumbersome. They are often written as one-offs, then have to wait for CI/CD before deploying, and finally being able to run your code through terminal access. After all of that- the task itself is rarely deleted after running, leaving stale code that litters your code base. Sometimes it's useful to be able to find these tasks again for future reference, but digging through version control isn't ideal.
This process leaves a lot to be desired. It has very low visibility and is not easy to audit or verify.

This CommandProposal gem offers a solution: A mountable Rails Engine that provides a UI for devs to enter their task, get it approved by another developer, and then run. Results are stored and can be used for future reference to see that the task was executed as expected. It can always be run again if need be and each iteration will store the code as it was and the results it gave.

Requiring approval from another member of the team allows the code to still go through a review process. This also encourages pairing on the code to make sure it's safe to run against a production environment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'command_proposal'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install command_proposal

Mount the engine in your routes:

    mount ::CommandProposal::Engine => "/commands"

Install and run the migrations:

    rails generate command_proposal:install
    rails db:migrate

Add config as desired:

    ::CommandProposal.configure do |config|
      config.user_class = User # Defaults to `User` - change if your base user class has a different model name
      config.role_scope = :admin # Scope for your user class that determines users who are permitted to interact with commands (highly recommended to make this very exclusive, as any users in this scope will be able to interact with your database directly)
      config.user_name = :name # Method to call to display a user's name
      config.proposal_callback = Proc.new { |iteration|
        # Callback code for when a new command is proposed.
        # `iteration` can be used for showing current information.
        # Methods available:
        # `iteration.name`
        # `iteration.description`
        # `iteration.args`
        # `iteration.code`
        # `iteration.result`
        # `iteration.status`
        # `iteration.author`
        # `iteration.approver`
        # `iteration.approved_at`
        # `iteration.started_at`
        # `iteration.completed_at`
        # `iteration.stopped_at`
        # Route to find the current iteration:
        # Rails.application.routes.url_helpers.command_path(iteration)
      }
      config.success_callback = Proc.new { |iteration|
        # Callback code for when a running command executes successfully
      }
      config.failed_callback = Proc.new { |iteration|
        # Callback code for when a running command fails to complete
      }
    end

## Usage

Visit `/commands` to begin using

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/command_proposal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/command_proposal/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CommandProposal project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/command_proposal/blob/master/CODE_OF_CONDUCT.md).
