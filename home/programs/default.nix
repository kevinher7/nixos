{lib, ...}: {
  imports = [
    ./ghostty.nix
    ./alacritty.nix
    ./betterlockscreen.nix
    ./qutebrowser.nix
    ./rquickshare.nix
    ./tmux.nix
    ./nixvim
    ./opencode
  ];

  options.myPrograms = {
    ghostty.enable = lib.mkEnableOption "ghostty terminal emulator";
    alacritty.enable = lib.mkEnableOption "alacritty terminal emulator";
    betterlockscreen.enable = lib.mkEnableOption "betterlockscreen screen locker";
    qutebrowser.enable = lib.mkEnableOption "qutebrowser browser";
    rquickshare.enable = lib.mkEnableOption "rquickshare file sharing";
    tmux.enable = lib.mkEnableOption "tmux terminal multiplexer";
    nixvim.enable = lib.mkEnableOption "nixvim (neovim) editor";
    opencode.enable = lib.mkEnableOption "opencode AI assistant";
  };
}
