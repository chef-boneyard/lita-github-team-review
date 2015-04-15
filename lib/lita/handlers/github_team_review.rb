require 'octokit'
require 'date'

module Lita
  module Handlers
    class GithubTeamReview < Handler
      config :username, required: true
      config :password, required: true

      route(/^review\s+(.+)/, :review, command: true, help: {
        "review <org>/<team>" => "Responds with all issues that need review for a GitHub team."
      })

      def review(response)
        if response.args.length != 1
          response.reply(render_template("multi_line", lines: ["The review command only takes one argument.\n",
                                                               "Please pass a valid github team as a string."]))
          return nil
        end
        team_string = response.args[0]

        begin
          issues = github_client.search_issues("team:#{team_string} is:open is:pr")[:items]
        rescue Octokit::UnprocessableEntity => e
          # parse the error response from octokit
          response.reply e.message.match(/\bmessage:\s+\K.*$/)[0]
          return nil
        end

        if issues.length == 0
          response.reply(render_template("multi_line", lines: ["There are currently no pull requests to review for #{team_string}!\n",
                                                               "To mark a pull request as needing review, mention it in the description on Github (e.g. @#{team_string})."]))
        else
          response.reply(render_template("multi_line", lines: ["There are #{issues.length} issues and pull requests currently in need of review for #{team_string}.\n"]))
        end

        message = []
        issues.each do |issue|
          message << "#{issue[:title]}\n"
          message << "Author: #{issue[:user][:login]}\n"
          days = Time.now.to_date.mjd - issue[:created_at].to_date.mjd
          if days > 0
            message << "Created: #{days} days ago\n"
          else
            message << "Created: Less than one day ago\n"
          end
          message << "Url: #{issue[:html_url]}\n"
        end
        response.reply(render_template("multi_line", lines: message))
      end

      private

      def github_client
        @github_client ||= Octokit::Client.new(:login => config.username, :password => config.password)
      end
    end

    Lita.register_handler(GithubTeamReview)
  end
end
