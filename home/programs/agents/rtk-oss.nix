{
  lib,
  rtk,
}:
rtk.overrideAttrs (oldAttrs: {
  pname = "rtk-oss";
  cargoBuildNoDefaultFeatures = true;
  cargoCheckNoDefaultFeatures = true;
  meta = oldAttrs.meta // {license = lib.licenses.asl20;};
})
