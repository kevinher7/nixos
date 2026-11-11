{
  config,
  inputs,
  pkgs,
  ...
}: let
  proxyEnvironment =
    config.networking.proxy.envVars
    // {
      HTTP_PROXY = config.networking.proxy.httpProxy;
      HTTPS_PROXY = config.networking.proxy.httpsProxy;
      NO_PROXY = config.networking.proxy.noProxy;
    };
in {
  imports = [
    ./default.nix
    ../../modules/t3code
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];

  microvm = {
    vcpu = 2;
    mem = 3072;
    writableStoreOverlay = "/nix/.rw-store";
    volumes = [
      {
        image = "root.img";
        mountPoint = "/";
        size = 40 * 1024;
      }
    ];
    interfaces = [
      {
        type = "tap";
        id = "vm-agent-dev";
        mac = "02:00:00:00:00:01";
      }
    ];
  };

  systemd.network = {
    enable = true;
    networks."20-agent-dev" = {
      matchConfig.MACAddress = "02:00:00:00:00:01";
      address = ["172.31.255.2/30"];
      networkConfig = {
        DHCP = "no";
        LinkLocalAddressing = "no";
        IPv6AcceptRA = false;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [22 3773];
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  networking.proxy = {
    httpProxy = "http://172.31.255.1:3129";
    httpsProxy = "http://172.31.255.1:3129";
    noProxy = "localhost,127.0.0.1,::1";
  };
  environment.systemPackages = with pkgs; [git curl jq nodejs python3];
  environment.sessionVariables = proxyEnvironment;

  users.users.agent = {
    isNormalUser = true;
    shell = pkgs.bashInteractive;
    openssh.authorizedKeys.keys = let
      keys = import ../../modules/networking/ssh-keys.nix;
    in [keys.kebee keys.kebean];
  };

  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      osFamily = "linux";
      username = "agent";
      hostname = "agent-dev";
      profile = "virtual";
    };
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
      inputs.stylix.homeModules.stylix
    ];
    users.agent = {
      imports = [
        ../../home/programs
        ../../home/common/git.nix
        ../../home/common/gh.nix
        ../../home/common/direnv.nix
      ];
      home.stateVersion = "25.11";
      myPrograms.agents = {
        claude-code.enable = true;
        codex.enable = true;
        opencode.enable = true;
        pi.enable = true;
      };
      programs.bash.enable = true;
    };
  };

  myModules.t3code = {
    enable = true;
    user = "agent";
    host = "172.31.255.2";
    openFirewall = false;
    githubToken.enable = false;
  };

  systemd.services = {
    t3code = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
      environment = proxyEnvironment;
    };
    nix-daemon.environment = proxyEnvironment;
  };
}
