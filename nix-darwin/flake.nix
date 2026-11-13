{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          environment.systemPackages = [
            pkgs.vim
            pkgs.neovim
          ];

          nix = {
            settings = {
              experimental-features = "nix-command flakes";
              trusted-users = [
                "guidooffermans"
                "pothos"
                "root"
              ];
            };

            buildMachines = [
              {
                hostName = "eu.nixbuild.net";
                system = "x86_64-linux";
                maxJobs = 100;
                supportedFeatures = [
                  "benchmark"
                  "big-parallel"
                ];
              }
            ];
            distributedBuilds = true;
          };

          programs = {
            ssh = {
              knownHosts = {
                nixbuild = {
                  hostNames = [ "eu.nixbuild.net" ];
                  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
                };
              };
              extraConfig = ''
                Host eu.nixbuild.net
                PubkeyAcceptedKeyTypes ssh-ed25519
                ServerAliveInterval 60
                IPQoS throughput
                IdentityFile /Users/guidooffermans/.ssh/pothos-services
              '';
            };
            zsh = {
              # Enable alternative shell support in nix-darwin.
              enable = true;
            };
          };

          system = {
            # Set Git commit hash for darwin-version.
            configurationRevision = self.rev or self.dirtyRev or null;
            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            stateVersion = 5;
          };

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Guidos-MacBook-Pro
      darwinConfigurations."Guidos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
