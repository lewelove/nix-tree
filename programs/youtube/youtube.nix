{ ... }:

{
  flake.nixosModules.youtube = { ... }: {
    webApps.youtube = {
      name = "YouTube";
      url = "https://www.youtube.com/";
      icon = "${./youtube.svg}";
    };
  };
}
