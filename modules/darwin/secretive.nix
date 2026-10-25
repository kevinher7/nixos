_: {
  homebrew.casks = ["secretive"];

  programs.ssh.extraConfig = ''
    Host beans-btw kebean uribo-btw
      IdentityAgent ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
  '';
}
