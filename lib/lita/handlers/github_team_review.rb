require 'octokit'
require 'date'

module Lita
  module Handlers
    class GithubTeamReview < Handler
      config :username, required: true
      config :password, required: true
      config :default_org, required: true

      route(/^review\s+(.+)/, :review, command: true, help: {
        "review <org>/<team>" => "Responds with all issues that need review for a GitHub team. If <org> is omitted, we assume the team is part of a default GitHub organization (see bot configuration)."
      })

      def review(response)
        team_arg = response.args[0]
        if response.args.length != 1
          response.reply "The review command only takes one argument."
          response.reply "Please pass a valid github team as a string."
        end

        if team_arg.include?("/")
          team_string = team_arg
        else
          teams_in_default_org = []
          github_client.organization_teams(config.default_org).each do |team|
            teams_in_default_org << team[:slug]
          end

          unless teams_in_default_org.include?(team_arg)
            response.reply "The team you passed (#{team_arg}) is not a valid team in the #{config.default_org} org."
            response.reply "Valid teams include:"
            response.reply "  #{teams_in_default_org.join("\n  ")}"
            return nil
          end
          team_string = "#{config.default_org}/#{team_arg}"
        end

        begin
          issues = github_client.search_issues("team:#{team_string} is:open is:pr")[:items]
        rescue Octokit::UnprocessableEntity => e
          # parse the error response from octokit
          response.reply e.message.match(/\bmessage:\s+\K.*$/)[0]
          return nil
        end

        if issues.length == 0
          response.reply "There are currently no pull requests to review for #{team_string}!"
          response.reply "To mark a pull request as needing review, mention it in the description on Github (e.g. @#{team_string})."
        else
          response.reply "There are #{issues.length} issues and pull requests currently in need of review for #{team_string}.\n"
        end

        issues.each do |issue|
          response.reply issue[:title]
          response.reply "Author:  #{issue[:user][:login]}"
          response.reply "Url:     #{issue[:html_url]}"
          days = Time.now.to_date.mjd - issue[:created_at].to_date.mjd
          if days > 0
            response.reply "Created #{days} days ago\n"
          else
            response.reply "Created less than one day ago\n"
          end
        end
      end

      private

      def github_client
        @github_client ||= Octokit::Client.new(:login => config.username, :password => config.password)
      end
    end

    Lita.register_handler(GithubTeamReview)
  end
end
