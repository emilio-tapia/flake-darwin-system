{ self, config, pkgs, lib, ... }: 

{
  options = {
    fontPackage.enable = lib.mkEnableOption "Enable fontPackage-specific macOS configurations.";
  };

  config = lib.mkIf config.fontPackage.enable {

     fonts.packages = with pkgs; [
      # System Fonts
      dejavu_fonts
      # liberation_ttf
      ubuntu_font_family
      fira-code
      jetbrains-mono
      source-code-pro
      noto-fonts
      # noto-fonts-cjk
      nerd-fonts.droid-sans-mono
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      # noto-fonts-emoji
      meslo-lgs-nf 

      # Google Fonts (examples)
      (pkgs.google-fonts.override { fonts = [ "Roboto" "Open Sans" "Lato" "Montserrat" "Poppins" ]; })
    ];

  };
}
