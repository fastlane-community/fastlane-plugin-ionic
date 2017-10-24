require 'xcodeproj'
module Fastlane
  module Actions
    class UpgradeSuperOldXcodeProjectAction < Action
      def self.run(params)
        # print params
        FastlaneCore::PrintTable.print_values(config: params, title: "Summary for UpgradeSuperOldXcodeProjectAction")

        # create project.pbxproj path and check if file exists
        path = params[:path]
        path = File.join(File.expand_path(path), "project.pbxproj")
        UI.user_error!("Could not find path to project config '#{path}'. Pass the path to your project (not workspace)!") unless File.exist?(path)

        # start message
        UI.message("Upgrading Xcode project if necessary")

        # open project
        project = Xcodeproj::Project.open(params[:path])

        # upgrade super old xcode project
        # if there is no TargetAttributes
        if project.root_object.attributes["TargetAttributes"]
          UI.important("No Xcode project upgrade necessary")
        else
          UI.error("Xcode project seems to be a very old project file format")
          UI.important("Upgrading project to use Xcode8 signing")

          # exit if no team_id param
          # TODO In my previous adaption of this code I completely removed this. Here as well?
          unless params[:team_id]
            UI.important("TEAM id is not set")
            UI.error!("Provide :team_id")
          end

          # Add TargetAttributes to project attributes
          # for each target an entry with team id and signing mode
          target_attr_hash = {}
          project.root_object.targets.each do |target|
            new_hash = {}
            new_hash["CreatedOnToolsVersion"] = "8.0"
            new_hash["DevelopmentTeam"] = params[:team_id]
            new_hash["ProvisioningStyle"] = params[:use_automatic_signing] ? 'Automatic' : 'Manual'
            # TODO: Above: Do we need this as param? Fixed? To what of the two values?
            # In my previous adaption of this code I chose "Manual" - unfortunately didn't document why :/
            target_attr_hash[target.uuid] = new_hash
          end
          project.root_object.attributes["TargetAttributes"] = target_attr_hash

          # for each configuration set a signing identity
          # TODO what does this actually do? Do we need it?
          # TODO Does this directly change the `project`? (reference vs. value)
          project.build_configurations.each do |config|
            config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = config.name == "Release" ? 'iPhone Distribution' : "iPhone Development"
          end

          # set upgrade marker to xcode8
          project.root_object.attributes["LastUpgradeCheck"] = "0800"

          # save project
          project.save
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upgrades super old Xcode projects to Xcode 8"
      end

      def self.authors
        ["Jan Piotrowski", "mathiasAichinger", "hjanuschka"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "This plugin can upgrade super old Xcode (pre Xcode 8) projects to Xcode 8 format by adding the missing attributes to the project config and thereby enables using the `automatic_code_signing` actions on it."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_PROJECT_SIGNING_PROJECT_PATH",
                                       description: "Path to your Xcode project",
                                       verify_block: proc do |value|
                                         UI.user_error!("Path is invalid") unless File.exist?(File.expand_path(value))
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       env_name: "FASTLANE_TEAM_ID",
                                       optional: false,
                                       description: "Team ID, is used when upgrading project",
                                       is_string: true),
          FastlaneCore::ConfigItem.new(key: :use_automatic_signing,
                                       env_name: "FL_PROJECT_USE_AUTOMATIC_SIGNING",
                                       description: "Defines if project should use automatic signing",
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
