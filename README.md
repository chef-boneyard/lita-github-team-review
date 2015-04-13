# lita-github-team-review

This is a lita handler for listing pull requests and
issues that are in need of review for a team.

## Usage

### In Hipchat

```
botname review <team>
```

### In Github

Simply assign your team's github review user to a PR
or issue on github to have the bot pick it up. These
users must be configured separately and follow a
specific format (see below). For example, the legion
of builds team has the github user `lob-review`.
`botname review lob` will properly return all PRs
that that user is assigned to.

### Implementation

Due to the limited nature of the github API, looking
up all pull requests for a team or organization is not
possible. It would be possible to find all users for a
team and list their PRs, but you have to be auth'ed
as that user.

Instead, we simply create a new user of the format
`<team_name>-review` in github, and deploy that user's
credentials in the root dir of the repo under a file
named `<team_name>-review-config.yml`. The bot will
parse any yml files of that format and use the creds
to auth as that user and find all the issues it
belongs to. So a call to `botname review lob` will
load `lob-review-config.yml` from the root of the
repo (so we'll need to deploy that with Chef) and
use its contents to auth against the github API as
that user, finding all PRs its assigne of.

See example.yml for format.

### Setting Up A New Team

1. Create a new github user named `<team_name>-review`.
2. Have someone with privileges invite that user to the Chef organization with read access (if you want to be able to find private repos needing review).
3. In the deploy cookbook, deploy `<team_name>-review-config.yml` to the root of the installed repo with the proper values (see example.yml).
4. Deploy the cookbook.
5. Assign `<team_name>-review` to github issues and pull requests that need review from your team.

Upon doing the above, you can now call

```
@julia review <team_name>
```

to list all pull requests needing review.

Contact `tyler <at> chef <dot> io` if you need any help :)

Happy reviewing!

### TODO

+ Tests
+ Better hipchat output
+ Periodicly output in team rooms?
