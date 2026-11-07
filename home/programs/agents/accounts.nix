{lib}:
lib.mkOption {
  type = lib.types.attrsOf (lib.types.submodule {
    options.home = lib.mkOption {
      type = lib.types.addCheck lib.types.str (home:
        home
        != ""
        && lib.all (part: part != "" && part != "." && part != "..") (lib.splitString "/" home));
      description = "Home-relative directory for an independent account, excluding T3 shadow homes.";
    };
  });
  default = {};
  description = "Accounts receiving shared global instructions.";
}
