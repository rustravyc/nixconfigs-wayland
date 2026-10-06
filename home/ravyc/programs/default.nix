{ pkgs, ... }:

# [ here some aliases, you can change it if you dont like it, but everything works ]
{
  programs.bash = {
    enable = true;
    initExtra = ''
      export PS1="\[\033[1;33m\][\w]\[\033[0m\] "
    '';
    shellAliases = {
      rebuild = "doas nixos-rebuild switch --flake /etc/nixos#morphine";
      v = "vim";
      larp = "fastfetch";
      conf = "doas vim /etc/nixos/hosts/morphine/configuration.nix";
      home = "doas vim /etc/nixos/home/ravyc/home.nix";
      shell = "doas vim /etc/nixos/home/ravyc/programs/default.nix";
      flake = "doas vim /etc/nixos/flake.nix";
      wm = "doas vim /home/ravyc/.config/sway/config";
      terminal = "doas vim /home/ravyc/.config/foot/foot.ini";
      snake = "python3 ";
      revive = "doas nix-channel --update";
      clean = "doas nix-collect-garbage -d";
      boot = "doas /nix/var/nix/profiles/system/bin/switch-to-configuration boot";
    };
  };

# [ you can change some things here, just if you know what are you doing ] 

services.mako = {
  enable = true;
  settings = {
    font = "TerminessNerdFont 10";
    width = 320;
    height = 110;
    margin = "10";
    padding = "12";
    border-size = 2;
    border-radius = 0;
    anchor = "top-right";
    default-timeout = 5000;
    ignore-timeout = 0;
    layer = "overlay";

    background-color = "#282828e6";
    progress-color = "#3c3836";
    border-color = "#d79921";
    text-color = "#ebdbb2";
  };
};


home.file."/home/ravyc/.config/xkb/symbols/scroll".text = ''
default partial modifier_keys xkb_symbols "map_to_mod3" {
    modifier_map Mod3 { Scroll_Lock };
};
'';

home.file."/home/ravyc/.config/sway/status.sh" = {
  executable = true;
  text = ''
    #!/bin/sh

    interval=1

    cpu_usage() {
        read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

        prev_idle=$((idle + iowait))
        prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))

        sleep 0.5

        read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

        idle_now=$((idle + iowait))
        total_now=$((user + nice + system + idle + iowait + irq + softirq + steal))

        idle_delta=$((idle_now - prev_idle))
        total_delta=$((total_now - prev_total))

        if [ "$total_delta" -eq 0 ]; then
            echo "0"
        else
            awk "BEGIN {printf \"%.0f\", (1 - $idle_delta / $total_delta) * 100}"
        fi
    }

    ram_used() {
    ${pkgs.gawk}/bin/awk '
        /MemTotal:/ { total = $2 }
        /MemAvailable:/ { available = $2 }
        END {
            printf "%.1fG", (total - available) / 1048576
        }
    ' /proc/meminfo
}


     uptime() {
    ${pkgs.gawk}/bin/awk '{
        seconds = int($1)
        days = int(seconds / 86400)
        hours = int((seconds % 86400) / 3600)
        minutes = int((seconds % 3600) / 60)

        if (days > 0)
            printf "%dd %dh", days, hours
        else if (hours > 0)
            printf "%dh %dm", hours, minutes
        else
            printf "%dm", minutes
    }' /proc/uptime
}

    temperature() {
        if [ -r /sys/class/hwmon/hwmon1/temp1_input ]; then
            temp=$(${pkgs.coreutils}/bin/cat /sys/class/hwmon/hwmon1/temp1_input)
            echo "$((temp / 1000))°C"
        else
            echo "n/a"
        fi
    }

    json_escape() {
        ${pkgs.gawk}/bin/awk '{
            gsub(/\\/, "\\\\");
            gsub(/"/, "\\\"");
            printf "%s", $0
        }'
    }

    printf '{"version":1}\n[\n[]'

    while true; do
        TIME=$(${pkgs.coreutils}/bin/date '+%H:%M')
        RAM=$(ram_used)
        CPU=$(cpu_usage)
        UPTIME=$(uptime)
        TEMP=$(temperature)

        printf ',['
        printf '{"full_text":"[   %s ]","color":"#d79921","background":"#282828"},' "$TIME"
        printf '{"full_text":"[   %s ]","color":"#d79921","background":"#282828"},' "$RAM"
        printf '{"full_text":"[   %s%% ]","color":"#d79921","background":"#282828"},' "$CPU"
        printf '{"full_text":"[   %s ]","color":"#d79921","background":"#282828"},' "$UPTIME"
        printf '{"full_text":"[   %s ]","color":"#d79921","background":"#282828"}' "$TEMP"
        printf ']'

        sleep "$interval"
    done
  '';
};

home.file."/home/ravyc/.config/sway/config".text = ''
exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec mako
output HDMI-A-2 mode 1600x900@74.997Hz
font pango:TerminessNerdFontPropo 12
for_window [app_id=".*"] floating enable
for_window [class=".*"] floating enable
focus_follows_mouse yes
popup_during_fullscreen smart
default_floating_border pixel 1

client.focused          #d79921 #d79921 #282828 #83a598 #d79921
client.unfocused        #3c3836 #3c3836 #ebdbb2 #3c3836 #3c3836
client.focused_inactive #504945 #504945 #d5c4a1 #504945 #504945
client.urgent           #cc241d #cc241d #fbf1c7 #cc241d #cc241d


set $mod Mod1
set $left h
set $down j
set $up k
set $right l
set $term foot
set $menu fuzzel
output * bg /home/ravyc/wallpaper/wallpaper.jpg fill

   input type:keyboard {
       xkb_layout "br"
       repeat_delay 200
       repeat_rate 80
       xkb_options "scrolllock:mod3"
   }

    bindsym $mod+Return exec $term
    bindsym $mod+q kill
    bindsym $mod+d exec $menu
    floating_modifier $mod normal
    bindsym $mod+r reload
    bindsym $mod+Shift+e exec 'pkill sway'
    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right
    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right
    bindsym $mod+1 workspace number 1
    bindsym $mod+2 workspace number 2
    bindsym $mod+3 workspace number 3
    bindsym $mod+4 workspace number 4
    bindsym $mod+5 workspace number 5
    bindsym $mod+6 workspace number 6
    bindsym $mod+7 workspace number 7
    bindsym $mod+8 workspace number 8
    bindsym $mod+9 workspace number 9
    bindsym $mod+0 workspace number 10
    bindsym $mod+Shift+1 move container to workspace number 1
    bindsym $mod+Shift+2 move container to workspace number 2
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9
    bindsym $mod+Shift+0 move container to workspace number 10
    bindsym $mod+b splith
    bindsym $mod+v splitv
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split
    bindsym $mod+f fullscreen
    bindsym $mod+Shift+d floating toggle
    bindsym $mod+space focus mode_toggle
    bindsym $mod+Shift+minus move scratchpad
    bindsym $mod+minus scratchpad show
mode "resize" {
    bindsym $left resize shrink width 10px
    bindsym $down resize grow height 10px
    bindsym $up resize shrink height 10px
    bindsym $right resize grow width 10px
    bindsym Left resize shrink width 10px
    bindsym Down resize grow height 10px
    bindsym Up resize shrink height 10px
    bindsym Right resize grow width 10px
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
   bindsym $mod+p exec swaylock
   bindsym $mod+a exec pavucontrol
   bindsym Print exec grim ~/screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png
   bindsym $mod+Print exec grim -g "$(slurp)" ~/screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png
bar {
    position top
    font pango:TerminessNerdFontPropo 11
    status_command /home/ravyc/.config/sway/status.sh
    colors {
        background #282828
        statusline #ebdbb2
        separator  #504945

        focused_workspace  #d79921 #d79921 #282828
        active_workspace   #3c3836 #3c3836 #ebdbb2
        inactive_workspace #282828 #282828 #a89984
        urgent_workspace   #cc241d #cc241d #fbf1c7
}
'';

home.file."/home/ravyc/.config/swaylock/config".text = ''
screenshots
clock
indicator
effect-blur=18x18

inside-color=28282888
inside-clear-color=3c383688
inside-ver-color=45858888
inside-wrong-color=cc241d88

ring-color=458588
ring-clear-color=d79921
ring-ver-color=458588
ring-wrong-color=cc241d

key-hl-color=a89984
bs-hl-color=cc241d
text-color=ebdbb2
text-clear-color=d79921
text-ver-color=458588
text-wrong-color=cc241d
'';

home.file."/home/ravyc/.config/fuzzel/fuzzel.ini".text = ''
[main]
font=TerminessNerdFont:size=14
prompt=": "
icon-theme=Papirus
fields=filename,name,generic,exec,categories,keywords
lines=10
width=40
horizontal-pad=20
vertical-pad=12
inner-pad=8
image-size-ratio=0.5
line-height=18
letter-spacing=0
layer=top
exit-on-keyboard-focus-loss=yes

[border]
width=2
radius=0

[colors]
background=282828e6
text=ebdbb2ff
match=fe8019ff
selection=d79921ff
selection-text=ebdbb2ff
selection-match=fe8019ff
border=d78821ff
'';

home.file."/home/ravyc/.config/foot/foot.ini".text = ''
[main]
font=TerminessNerdFont:size=12
pad=8x8
initial-color-theme=dark

[colors-dark]
alpha=0.9

background=282828
foreground=ebdbb2

regular0=3c3836   # black
regular1=cc241d   # red
regular2=98971a   # green
regular3=d79921   # yellow
regular4=458588   # blue
regular5=b16286   # magenta
regular6=689d6a   # cyan
regular7=a89984   # white

bright0=504945    # bright black
bright1=fb4934    # bright red
bright2=b8bb26    # bright green
bright3=fabd2f    # bright yellow
bright4=83a598    # bright blue
bright5=d3869b    # bright magenta
bright6=8ec07c    # bright cyan
bright7=ebdbb2    # bright white
''; 

home.file.".vimrc".text = ''
    call plug#begin('~/.vim/plugged')
    Plug 'joshdick/onedark.vim'
    Plug 'catppuccin/vim', { 'as': 'catppuccin' }
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'jiangmiao/auto-pairs'
    Plug 'sheerun/vim-polyglot'
    call plug#end()

    let g:airline_theme='catppuccin_macchiato'
    syntax on
    set clipboard=unnamedplus
    set number relativenumber
    set mouse=a
    set encoding=utf-8
    set noswapfile
    set nobackup
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set expandtab
    set autoindent
    set smartindent
    set hlsearch
    set incsearch
    set ignorecase
    set smartcase
    set scrolloff=8
    set showmode
    set wildmenu

    let mapleader = " "
    nnoremap <leader>c :nohlsearch<CR>
    nnoremap <leader>w :w<CR>
    nnoremap <C-h> <C-w>h
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <C-l> <C-w>l
  '';
}
