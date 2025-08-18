{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
          pkgs.ncdu
          pkgs.iterm2
          pkgs.bartender
          pkgs.cyberduck
          pkgs.gimp
          pkgs.inkscape
          pkgs.numi
          pkgs.raycast
          pkgs.rectangle
          pkgs.spotify
          pkgs.tableplus
          pkgs.vscode
          pkgs.iterm2
          pkgs.curl
          pkgs.wget
          pkgs.ffmpeg
          pkgs.imagemagick
          pkgs.mailpit
          pkgs.p7zip
          pkgs.pnpm
          pkgs.yazi
          pkgs.tmux
          pkgs.keka
          pkgs.neovim
          pkgs.httpie
          pkgs.appcleaner
          pkgs.fzf
          pkgs.zoxide
          pkgs.mysql-client
        ];

      homebrew = {
        enable = true;

        brews = [
          "mas"
        ];

        casks = [
          "firefox"
          "sublime-text"
          "alt-tab"
          "ghostty"
          "dbngin"
          "google-chrome"
          "google-chrome@canary"
          "herd"
          "jiggler"
          "kap"
          "microsoft-azure-storage-explorer"
          "tinkerwell"
          "transnomino"
          "whatsapp"
          "smartgit"
          "appcleaner"
          "shottr"
          "keyclu"
          "homerow"
          "kindavim"
        ];

        masApps = {
          "ColorSlurp" = 1287239339;
          "Meeter" = 1510445899;
          "Toggl" = 1291898086;
          "DropOver" = 1355679052;
        };
      };

      fonts.packages = with pkgs; [
        meslo-lgs-nf
        source-code-pro
        nerd-fonts.fira-code
      ];


      security.pam.services.sudo_local.touchIdAuth = true;

      system.primaryUser = "jonathan.hf";

      system.defaults = {
        dock = {
          autohide = true;
          magnification = true;
          largesize = 46;
          tilesize = 35;
          mineffect = "genie";

          static-only = true; # Show only open applications in the Dock
          show-process-indicators = false; # Hides dots on opened apps
          show-recents = false;
          persistent-apps = []; # Remove all apps from the dock
          wvous-tr-corner = 2; # Mission control Top Right Hot Corner
          wvous-br-corner = 3; # Application windows Bottom Right Hot Corner
        };


        finder = {
          ShowStatusBar = true;
          ShowPathbar = true;
          CreateDesktop = false;
          AppleShowAllExtensions = true;
          FXDefaultSearchScope= "SCcf";
          FXPreferredViewStyle = "clmv";
          FXEnableExtensionChangeWarning = false;
          _FXSortFoldersFirst = true;
          _FXShowPosixPathInTitle = true;
        };

        WindowManager = {
          GloballyEnabled = false;
          StandardHideWidgets = true;
          StandardHideDesktopIcons = true;
          EnableStandardClickToShowDesktop = false;
        };

        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
          FirstClickThreshold = 1;
        };


        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleICUForce24HourTime = true;

          InitialKeyRepeat = 15;
          KeyRepeat = 1;
        };
      };

      system.activationScripts.activateSettings.text = ''
       # Following line should allow us to avoid a logout/login cycle
          /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
          
          # Make sure that sudo touch is also enabled when connected to external monitors
          sudo -u $USER defaults ~/Library/Preferences/com.apple.security.authorization.plist ignoreArd -bool TRUE
      '';

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#MX-IT07830
    darwinConfigurations."MX-IT07830" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "jonathan.hf";
          };
        }
      ];
    };
  };
}
