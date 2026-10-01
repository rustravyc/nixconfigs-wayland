{ config, pkgs, ... }:

# [here my configuration, you really will need delete the hardware-configuration or this can cause some issues.]

{
  imports = [
    ./hardware-configuration.nix
  ];

# [some flake and kernel configuration, this is specific for intel GPU/CPU]

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 5d";
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  boot.kernelParams = [
    "intel_pstate=active"
    "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "i915.fastboot=1"
    "mitigations=off"
    "nowatchdog"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "kernel.nmi_watchdog" = 0;
    "kernel.unprivileged_userns_clone" = 1;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # [you can change the hostname and the timezone, but you need change in another places too.]

  networking.hostName = "morphine";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Fortaleza";
  i18n.defaultLocale = "pt_BR.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

# [terminess font as default, change to some font you like it or just add another one]

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.terminess-ttf
    ];
  };

# [kernel tweaks for intel]

  powerManagement.cpuFreqGovernor = "performance";
  hardware.cpu.intel.updateMicrocode = true;
  services.irqbalance.enable = true;
  services.fstrim.enable = true;

# [xserver configs, change to your language and keyboard]

  services.xserver = {
    enable = true;
    xkb = {
      layout = "br";
      variant = "abnt2";
    };
    videoDrivers = [ "modesetting" ];
    deviceSection = ''
      Option "TearFree" "true"
    '';
  };

# [ly as default display manager]

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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

# [change to your username]

  users.users.ravyc = {
    isNormalUser = true;
    description = "ravyc";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "input" ];
  };

# [yes, fucking doas as default...i just like it, but you can remove to set sudo to default. both works]

  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "ravyc" ];
      keepEnv = true;
      persist = true;
    }];
  };

  nixpkgs.config.allowUnfree = true;

# [here all my sway stuff, i really recommend you dont change any line here]

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

  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;

  home-manager.backupFileExtension = "backup"; 
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
  ];
};

  environment.systemPackages = with pkgs; [

# [programming stuff, you can delete it if you dont need it]

    python3
    uv
    sqlite
    nodejs
    vim
    neovim
    obsidian

# [some Wayland apps, essential to make sway works so i dont recommend remove it]

    libnotify
    pavucontrol
    nwg-look
    thunar
    mpv
    mako
    grim
    slurp
    betterlockscreen
    
# [some dev pkgs, you can remove it too]

    git
    curl
    gnumake
    gcc
    pkg-config
    unzip
    unrar
    glib

# [i use gtk catppuccin to set the gtk themes in general on dwm, but you can change it for some theme you like it]

    catppuccin-gtk
    catppuccin
    papirus-icon-theme
    papirus-nord
    firefox
    ffmpeg
    appimage-run

# [ here some gaming stuff, you can delete it  ] 

    pcsx2

  ];

  system.stateVersion = "26.05";
}
