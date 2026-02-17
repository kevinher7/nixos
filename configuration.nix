# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "beans-btw"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        ignoreUserConfig = true;
        waylandFrontend = false;

        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];

        settings = {
          globalOptions = {
            "Hotkey/TriggerKeys" = {
              "0" = "Zenkaku_Hankaku";
            };
          };

          inputMethod = {
            "Groups/0" = {
              Name = "Default";
              "Default Layout" = "jp";
              DefaultIM = "keyboard-jp";
            };
            "Groups/0/Items/0".Name = "keyboard-jp";
            "Groups/0/Items/1".Name = "mozc";
          };
        };

      };
    };
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

  services.xserver = {
    enable = true;
    windowManager.qtile.enable = true;
    desktopManager.runXdgAutostartIfNone = true;

    xkb.layout = "jp";
    displayManager.sessionCommands = ''
      xwallpaper --zoom ~/walls/girl-reading-book.png
      xset r rate 400 35 &
    '';
  };

  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "doom";
      battery_id = "BAT0";
      clock = "%c";
      doom_fire_height = 8;
    };
  };

  services.picom = {
    enable = true;
    backend = "glx";
    fade = true;
  };


  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Add this for standalone WM setups
  # Source: https://github.com/NixOS/nixpkgs/issues/390071
  environment.pathsToLink = [ "/share/wireplumber" ];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  services.tailscale.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kevin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;
  programs.light.enable = true;

  programs.xss-lock = {
    enable = true;
    lockerCommand = "xsecurelock";
  };

  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    ghostty
    pavucontrol
    btop
    xwallpaper
    pfetch
    pcmanfm
    rofi
    xsecurelock
    papirus-icon-theme
  ];

  environment.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  stylix = {
    enable = true;
    image = ./walls/girl-reading-book.png;

    polarity = "dark";

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # Open ports in the firewall.

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 9300 ];
    allowedUDPPorts = [ 5353 ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

