{
  lib,
  rtk,
}:
rtk.overrideAttrs (oldAttrs: {
  pname = "rtk-oss";
  cargoBuildNoDefaultFeatures = true;
  cargoCheckNoDefaultFeatures = true;
  checkFlags = (oldAttrs.checkFlags or []) ++ ["--test-threads=1"];
  meta = oldAttrs.meta // {license = lib.licenses.asl20;};
})
