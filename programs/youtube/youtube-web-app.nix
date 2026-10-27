{ ... }:

{
  flake.nixosModules.youtube-web-app = { ... }: {
    webApps.youtube = {
      name = "YouTube";
      url = "https://www.youtube.com/";
      icon = "${./youtube.svg}";
    };
  };
}
