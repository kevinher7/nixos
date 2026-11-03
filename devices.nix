{
  devices = {
    kebee.addresses = ["100.64.230.2" "fd7a:115c:a1e0::6601:e62e"];
    kebean.addresses = ["100.100.107.57" "fd7a:115c:a1e0::5d33:6b3a"];
    kebean-win.addresses = ["100.84.115.55" "fd7a:115c:a1e0::db01:7381"];
    beans-btw.addresses = ["100.85.14.25" "fd7a:115c:a1e0::bb01:e52"];
    uribo-btw.addresses = ["100.87.121.69" "fd7a:115c:a1e0::da01:798b"];
    pixel-9a.addresses = ["100.111.183.39" "fd7a:115c:a1e0::d301:b728"];
    njqm10.addresses = ["100.85.118.26" "fd7a:115c:a1e0::5339:761b"];
  };

  groups = {
    private = ["kebee" "kebean" "kebean-win" "beans-btw" "uribo-btw" "pixel-9a"];
    vaultGuests = ["njqm10"];
  };
}
