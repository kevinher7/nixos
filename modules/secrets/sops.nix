_:
{
  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      pihole_password = {
        neededForUsers = false;
        owner = "pihole";
        group = "pihole";
        mode = "0400";
      };
    };
  };
}
