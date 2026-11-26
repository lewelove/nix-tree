{ ... }:

{
  boot = {
    kernel.sysctl."vm.vfs_cache_pressure" = 200;
    tmp = {
      useTmpfs = false;
      cleanOnBoot = true;
    };
  };
}
