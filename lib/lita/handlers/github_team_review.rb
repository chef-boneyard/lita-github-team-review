require 'octokit'
require 'yaml'
require 'pp'

module Lita
  module Handlers
    class GithubTeamReview < Handler

      # TODO update help
      route(/^review\s+(.+)/, :review, command: true, help: {
        "review GITHUB_TEAM" => "Responds with all PRs that need review for a github team."
      })

      attr_reader :client

      def review(response)
          config = YAML.load_file('config.yml')
          @client = Octokit::Client.new(:login => config["login"], :password => config["password"])
          team_arg = response.args[0]
          if response.args.length != 1
            response.reply "The review command only takes one argument."
            response.reply "Please pass a valid github team as a string."
          end

          # get all chef teams and exit if the requested team doesn't exist
          result = get_team(team_arg)
          team = result[0]
          teams = result[1]
          if team.nil?
            response.reply "The team you passed (#{team_arg}) does not exist in the Chef org."
            response.reply "Valid teams are:"
            teams.each do |valid_teams|
              response.reply valid_teams.slug
            end
            return nil
          end

          get_pull_requests_that_need_review(team)

      end

      private

      def get_team(team_arg)
        teams = @client.organization_teams("chef")
        wanted_team = nil
        teams.each do |team|
          wanted_team = team if team.slug == team_arg
        end
        [wanted_team, teams]
      end

      def get_pull_requests_that_need_review(team)
        puts "Halp"
        #@client.user.login
        #Octokit.auto_paginate = true
        #puts issues @client.org_issues("chef")

        puts @client.list_issues.inspect
        @client.team_repositories(team.id).each do |team_repo|
          #puts @client.pull_requests(team_repo.id, :state => 'open')[0].inspect
        end

        @client.team_members(team.id).each do |member|

        end
      end
    end

    Lita.register_handler(GithubTeamReview)
  end
end
