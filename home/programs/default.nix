{
  lib,
  inputs,
  ...
}: {
  imports = [
    ./ghostty.nix
    ./alacritty.nix
    ./betterlockscreen.nix
    ./kanshi.nix
    ./qutebrowser.nix
    ./rquickshare.nix
    ./tmux.nix
    ./nixvim
    ./agents
    ./openvpn
    ./t3code.nix
    ./zen-browser
  ];

  options.myPrograms = {
    ghostty.enable = lib.mkEnableOption "ghostty terminal emulator";
    alacritty.enable = lib.mkEnableOption "alacritty terminal emulator";
    betterlockscreen.enable = lib.mkEnableOption "betterlockscreen screen locker";
    kanshi.enable = lib.mkEnableOption "kanshi dynamic display configuration";
    qutebrowser.enable = lib.mkEnableOption "qutebrowser browser";
    rquickshare.enable = lib.mkEnableOption "rquickshare file sharing";
    tmux.enable = lib.mkEnableOption "tmux terminal multiplexer";
    nixvim.enable = lib.mkEnableOption "nixvim (neovim) editor";
    agents = {
      claude-code.enable = lib.mkEnableOption "Claude Code CLI (macbook only)";
      codex.enable = lib.mkEnableOption "Codex CLI";
      opencode.enable = lib.mkEnableOption "OpenCode AI assistant";
      work.enable = lib.mkEnableOption "Claude-only work plugin on the macbook";
      toolkitSource = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default =
          if inputs ? agent-toolkit
          then inputs.agent-toolkit.outPath
          else null;
        defaultText = lib.literalExpression "inputs.agent-toolkit.outPath or null";
        description = ''
          Agent toolkit source with skills/, agents/, commands/, and plugins/work/.
          Null leaves existing content unmanaged during the attended migration.
        '';
      };
    };
    openvpn.enable = lib.mkEnableOption "openvpn split-tunnel wrapper (ovpn/ovpn-down/ovpn-status)";
    t3code = {
      cli.enable = lib.mkEnableOption "t3code CLI (`t3 serve`)";
      desktop.enable = lib.mkEnableOption "t3code desktop app (macOS only)";
    };
    zen-browser.enable = lib.mkEnableOption "zen browser (twilight)";
  };
}
