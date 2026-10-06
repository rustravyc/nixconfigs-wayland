{ config, pkgs, ... }:
# [ PLEASE READ ALL THE COMMENTS ]
# [ you will see here some WI-FI drivers configuration for aic8800, if you dont use it, just remove it. ]
# [ sure, change things here just if you know what are you doing, every configuration have a comment explaining what thats does. ]

let
  aic8800 = config.boot.kernelPackages.callPackage ./aic8800.nix {};
in

{
 imports = [
    ./hardware-configuration.nix
];
# [ configs for home-manager ]
home-manager.backupFileExtension = "backup";
# [ unfree software and nixld enable ]
programs.nix-ld.enable = true;
nixpkgs.config.allowUnfree = true;
# [ gvfs, tumbler and 32bit configs ]
services.gvfs.enable = true;
services.tumbler.enable = true;
hardware.graphics.enable32Bit = true;
# [ auto-optmise-store can slow a rebuild, but your system will stay pretty clean ]
 nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
     auto-optimise-store = true;
};

# [ this auto delete generations older than 5 days ]
nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 5d";
};
# [ kernel zen as default and some intel cpu tweaks. ]
boot.kernelPackages = pkgs.linuxPackages_zen;
hardware.firmwareCompression = "none";
hardware.cpu.intel.updateMicrocode = true;
services.fstrim.enable = true;
services.irqbalance.enable = true;
boot.extraModprobeConfig = ''
      options aic_load_fw aic_fw_path=${config.hardware.firmware}/lib/firmware/aic8800
'';
# [ aic8800 driver configuration ]
boot.extraModulePackages = [
    aic8800
];
boot.kernelModules = [
    "aic_load_fw"
    "aic8800_fdrv"
  ];

  hardware.firmware = [
    aic8800
  ];
# [ systemd boot as default ]
boot.loader.systemd-boot.enable = true;
boot.loader.efi.canTouchEfiVariables = true;
# [ important system configs, including hostname, username and opendoas ]
security.rtkit.enable = true;
security.polkit.enable = true;
programs.dconf.enable = true;
networking.hostName = "morphine"; # [ change to the hostname you like it ]
networking.networkmanager.enable = true;
time.timeZone = "America/Fortaleza";
i18n.defaultLocale = "pt_BR.UTF-8";
console = {
  font = "Lat2-Terminus16";
     keyMap = "br-abnt2";
   };
   users.users.ravyc = { # [ same thing here, change to your username ]
     isNormalUser = true;
     description = "ravyc";
     extraGroups = [
       "networkmanager"
       "wheel"
       "audio"
       "video"
       "input"
     ];
   };
   security.doas = {
     enable = true;
     extraRules = [{
       users = [ "ravyc" ];
       keepEnv = true;
       persist = true;
     }];
   };
# [ terminess bcs i like it ]
fonts = {
  fontconfig.enable = true;
  packages = with pkgs; [
    nerd-fonts.terminess-ttf
  ];
};
# [ xserver services configs ]
services.xserver = {
   enable = true;
   xkb = {
      layout = "br";
      variant = "abnt2";
  };
};
# [ ly as default display manager ]
services.displayManager.ly = {
  enable = true;
  settings = {
    bigclock = false;
    header_checksum = false;
    hide_borders = false;
    bg = 0;
    fg = 7;
    border_fg = 7;
    active_border_fg = 7;
  };
};
# [ flatpak and xdg ]
services.flatpak.enable = true;
xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
  ];
  config = {
    common = {
      default = [ "gtk" ];
    };
  };
};
# [ pipewire sound configuration ]
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
};
# [ obs configs ]
programs.obs-studio = {
  enable = true;
  plugins = with pkgs.obs-studio-plugins; [
    wlrobs
    obs-pipewire-audio-capture
    obs-backgroundremoval
  ];
};
# [ here all the sway configs ]
programs.sway = {
  enable = true;
  extraPackages = with pkgs; [
    swaylock-effects
    swayidle
    foot
    fuzzel
    brightnessctl
    wl-clipboard
  ];
};
security.pam.services.swaylock = {};
# [ all my pkgs ]
environment.systemPackages = with pkgs; [
# [ programming stuff ]
vim-full
neovim
python3
nodejs
# [ system essentials ]
libnotify
pavucontrol
nwg-look
thunar
mpv
mako
grim
slurp
feh
ffmpeg
appimage-run
unzip
unrar
usbutils
# [ web pkgs ]
git
curl
firefox
# [ some gtk themes ]
gruvbox-gtk-theme
gruvbox-dark-gtk
gruvbox-dark-icons-gtk
#[ personal pkgs ]
obsidian
cmatrix
cava
htop
pipes
];

system.stateVersion = "26.05";
}
