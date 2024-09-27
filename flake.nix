{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim pkgs.vscode
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;
      # programs.vim.enable = true;
      # programs.vscode.enable = false;#das geht nicht

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;

      # allow TouchId
      security.pam.enableSudoTouchIdAuth = true;

      # networking
      networking.knownNetworkServices = ["Wi-Fi" "Ethernet Adaptor" "Thunderbolt Ethernet"];
      networking.dns = ["192.168.178.201" "1.1.1.1" "8.8.8.8"];

      # applications
      services.jankyborders.enable = true;
      services.jankyborders.active_color = "0xff00ff00";#"gradient(top_right=0x9992B3F5,bottom_left=0x9992B3F5)";
      #services.jankyborders.background_color = "0x00000000";
      services.jankyborders.inactive_color = "0x00000000";
      services.tailscale.enable = true;

      # System defaults
      system.defaults = {
         dock.autohide = true;
         dock.mru-spaces = false;
         NSGlobalDomain.AppleShowAllFiles = true;
         finder.AppleShowAllExtensions = true;
         #finder.AppleShowAllFiles = true;
         finder.ShowPathbar = true;
         finder.FXPreferredViewStyle = "Nlsv";
         loginwindow.LoginwindowText = "Yorrick@aqube.de";
         screencapture.location = "~/Pictures/screenshots";
         screensaver.askForPasswordDelay = 10;
         SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations.Yorricks-MacBook-Pro = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.Yorricks-MacBook-Pro.pkgs;
  };
}
