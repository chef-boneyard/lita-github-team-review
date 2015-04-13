# lita-github-team-review

This is a lita handler for listing pull requests and
issues that are in need of review for a team.

## Configuration

```
config.handlers.github_team_review.username #username of a valid github user
config.handlers.github_team_review.password #password for that user
```

## Usage

### In Hipchat

```
botname review <team>
```

### In Github

To use, simply mention the team you want to review your pull request in github. You can do this via `@chef/<your_chef_team_name>`. After that, they will show up in the bot.

Contact `tyler <at> chef <dot> io` if you need any help :)

Happy reviewing!

### TODO

+ Tests
+ Better hipchat output
+ Periodicly output in team rooms?
