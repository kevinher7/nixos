{lib, ...}: {
  imports = [
    ./aerospace.nix
    ./ghostty.nix
    ./alacritty.nix
    ./betterlockscreen.nix
    ./qutebrowser.nix
    ./rquickshare.nix
    ./rofi.nix
    ./skim.nix
    ./nixvim
    ./agents
    ./openvpn
    ./t3code.nix
    ./vicinae.nix
    ./zathura.nix
    ./zen-browser
  ];

  options.myPrograms = {
    aerospace.enable = lib.mkEnableOption "AeroSpace window manager";
    ghostty.enable = lib.mkEnableOption "ghostty terminal emulator";
    alacritty.enable = lib.mkEnableOption "alacritty terminal emulator";
    betterlockscreen.enable = lib.mkEnableOption "betterlockscreen screen locker";
    qutebrowser.enable = lib.mkEnableOption "qutebrowser browser";
    rquickshare.enable = lib.mkEnableOption "rquickshare file sharing";
    rofi.enable = lib.mkEnableOption "rofi application launcher";
    skim.enable = lib.mkEnableOption "Skim pdf viewer defaults (macOS)";
    nixvim.enable = lib.mkEnableOption "nixvim (neovim) editor";
    agents = {
      claude-code.enable = lib.mkEnableOption "Claude Code CLI";
      codex.enable = lib.mkEnableOption "Codex CLI";
      opencode.enable = lib.mkEnableOption "OpenCode AI assistant";
      work-toolkit.enable = lib.mkEnableOption "Claude-only work toolkit on the macbook";
    };
    openvpn.enable = lib.mkEnableOption "openvpn split-tunnel wrapper (ovpn/ovpn-down/ovpn-status)";
    t3code = {
      cli.enable = lib.mkEnableOption "t3code CLI (`t3 serve`)";
      desktop.enable = lib.mkEnableOption "t3code desktop app (macOS only)";
    };
    zen-browser.enable = lib.mkEnableOption "zen browser (twilight)";
    vicinae.enable = lib.mkEnableOption "vicinae launcher";
    zathura.enable = lib.mkEnableOption "zathura pdf viewer";
  };
}
