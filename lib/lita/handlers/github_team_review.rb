require 'octokit'
require 'yaml'

module Lita
  module Handlers
    class GithubTeamReview < Handler

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

        begin
          config = YAML.load_file("#{team_arg}-review-config.yml")
          @client = Octokit::Client.new(:login => config["login"], :password => config["password"])
        rescue Errno::ENOENT => ex
          response.reply "The team you passed (#{team_arg}) is yet configured for the review command."
          response.reply "Valid teams currently are:"
          Dir["./*.yml"].each do |team_yml_file|
            # strip ./ and -review-config.yml
            response.reply team_yml_file[2..-19]
          end
          return nil
        end

        issues = @client.list_issues
        if issues.length == 0
          response.reply "There are currently no issues or pull requests to review for team #{team_arg}!"
          response.reply "To mark an issue or pull request as needing review, assign it to the github user #{team_arg}-review."
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
