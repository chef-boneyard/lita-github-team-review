require 'octokit'
require 'yaml'

module Lita
  module Handlers
    class GithubTeamReview < Handler
      config :username, required: true
      config :password, required: true

      route(/^review\s+(.+)/, :review, command: true, help: {
        "review GITHUB_TEAM" => "Responds with all issues that need review for a github team."
      })

      attr_reader :client

      def review(response)
        team_arg = response.args[0]
        if response.args.length != 1
          response.reply "The review command only takes one argument."
          response.reply "Please pass a valid github team as a string."
        end

        @client = Octokit::Client.new(:login => config.username, :password => config.password)

        valid_teams = []
        team_found = false
        @client.organization_teams("chef").each do |team|
          team_found = true if team[:slug] == team_arg
          valid_teams << team[:slug]
        end

        unless team_found
          response.reply "The team you passed (#{team_arg}) is not a valid github Chef team."
          response.reply "Valid responses are:"
          valid_teams.each do |team_slug|
            response.reply team_slug
          end
          return nil
        end

        issues = @client.search_issues("team:chef/#{team_arg} is:open is:pr")[:items]
        if issues.length == 0
          response.reply "There are currently no pull requests to review for team #{team_arg}!"
          response.reply "To mark a pull request as needing review, mention it in the description on Github."
          response.reply "For example: @chef/<your_chef_org_team_name>"
        else
          response.reply "There are #{issues.length} issues and pull requests currently in need of review for team #{team_arg}.\n"
        end

        issues.each do |issue|
          response.reply issue[:title]
          response.reply "Author: #{issue[:user][:login]}"
          response.reply "Url:    #{issue[:html_url]}\n"
        end
      end
    end

    Lita.register_handler(GithubTeamReview)
  end
end
