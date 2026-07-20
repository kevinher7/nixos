{...}: {
  # Central home for nixpkgs package workarounds/overrides.
  # Keep each entry documented with the reason and a removal condition,
  # so stale overrides can be pruned once upstream catches up.
  nixpkgs.overlays = [
    # cherrypy 18.10.0 ships a known-flaky, timing-sensitive session test
    # (test_session.py::test_0_Session, 1s Max-Age) that upstream itself marks
    # `@pytest.mark.flaky`. Under a loaded Nix builder all reruns lose and the
    # build fails. It is only pulled in as a *test* input via poetry ->
    # cachecontrol -> cherrypy (nothing uses it at runtime), so skipping its
    # check phase is safe. Remove once a nixpkgs bump fixes/patches the test.
    (_final: prev: {
      pythonPackagesExtensions =
        prev.pythonPackagesExtensions
        ++ [
          (_pyfinal: pyprev: {
            cherrypy = pyprev.cherrypy.overridePythonAttrs {doCheck = false;};
          })
        ];
    })
  ];
}
