;; Indicate which modules to import to access the variables
;; used in this configuration.
(define-module (base-os)
  #:use-module (gnu)
  #:use-module (gnu system)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu system file-systems)
  #:use-module (gnu bootloader)
  #:use-module (gnu bootloader grub)
  ;#:use-modules (gnu packages xfce)
  #:use-module (gnu packages xorg)
  #:use-module (gnu services cups)
  #:use-module (gnu services desktop)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh)
  #:use-module (gnu services)
  #:use-module (gnu services base)
  #:use-module (gnu services xorg)
  #:use-module (gnu services linux)
  #:use-module (nongnu packages linux)
  #:use-module (gnu packages certs)
  #:use-module (nongnu system linux-initrd)
  #:use-module (nongnu packages nvidia)
  #:use-module (nongnu services nvidia)
  #:use-module (srfi srfi-1)
  #:use-module (guix transformations)
  #:use-module (gnu packages vim)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages terminals)
  #:use-module (nongnu packages mozilla)
  #:use-module (gnu packages web-browsers)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages wine)
  #:use-module (gnu packages vulkan)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages suckless)
  #:use-module (gnu packages haskell)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages xfce)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages linux)
  ; #:use-module (gnu services sound)
)

(define %gentoo-xorg-nvidia-config
"
Section \"ServerLayout\"
    Identifier     \"Layout0\"
    Screen      0  \"Screen0\" 0 0
    InputDevice    \"Keyboard0\" \"CoreKeyboard\"
    InputDevice    \"Mouse0\" \"CorePointer\"
    Option         \"Xinerama\" \"0\"
EndSection

Section \"Files\"
EndSection

Section \"Module\"
    Load           \"dbe\"
    Load           \"extmod\"
    Load           \"type1\"
    Load           \"freetype\"
    Load           \"glx\"
EndSection

Section \"InputDevice\"
    # generated from default
    Identifier     \"Mouse0\"
    Driver         \"mouse\"
    Option         \"Protocol\" \"auto\"
    Option         \"Device\" \"/dev/psaux\"
    Option         \"Emulate3Buttons\" \"no\"
    Option         \"ZAxisMapping\" \"4 5\"
EndSection

Section \"InputDevice\"
    # generated from default
    Identifier     \"Keyboard0\"
    Driver         \"kbd\"
EndSection

Section \"Monitor\"
    # HorizSync source: edid, VertRefresh source: edid
    Identifier     \"Monitor0\"
    VendorName     \"Unknown\"
    ModelName      \"LG Electronics LG IPS FULLHD\"
    HorizSync       30.0 - 83.0
    VertRefresh     56.0 - 75.0
    Option         \"DPMS\"
EndSection

Section \"Device\"
    Identifier     \"Device0\"
    Driver         \"nvidia\"
"
)

(define transform
  (options->transformation
    '((with-graft . "mesa=nvda"))))

(operating-system
  (kernel linux-6.1)
  (kernel-arguments
    (append '("modprobe.blacklist=nouveau")
    %default-kernel-arguments))
  (kernel-loadable-modules (list nvidia-module))
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_GB.utf8")
  (timezone "Europe/Paris")
  (keyboard-layout (keyboard-layout "us"))
  (host-name "epsilon")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "epsilon")
                  (comment "Epsilon")
                  (group "users")
                  (home-directory "/home/epsilon")
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list (replace-mesa i3-wm)
                          i3status
                          dmenu
                          st
                          vim
                          (replace-mesa alacritty)
                          nyxt
			  fuse
                          firefox
                          git
                          stow
                          (replace-mesa mesa-utils)
                          ; (replace-mesa dxvk)
                          vulkan-tools
                          tmux
                          curl
			  nvidia-driver
			  nvidia-settings
			  nvidia-htop
			  flatpak
			  xdg-desktop-portal
			  xdg-desktop-portal-gtk
			  gpustat)
                    %base-packages))

  (services
    (append (list
		 ; (service xfce-desktop-service-type (xfce-desktop-configuration (xfce (transform xfce))))
		 ; (simple-service 'i3-packages profile-service-type(list (transform i3-wm) i3status dmenu st))
		 ; (service pulseaudio-service-type)
		 ; (service alsa-service-type)
		 (service nvidia-service-type)
		 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service tor-service-type)
		 (service slim-service-type (slim-configuration
					      (display ":1")
					      (vt "vt8")
					      (xorg-configuration (xorg-configuration
								    (keyboard-layout keyboard-layout)
								    (modules (cons* nvidia-driver %default-xorg-modules))
								    (server (transform xorg-server))
								    ; (extra-config (list %gentoo-xorg-nvidia-config))
								    (drivers '("nvidia")))))))

                 ; (service nvidia-service-type)
                 ;; (set-xorg-configuration
                 ;;  (xorg-configuration (modules(cons* nvidia-driver %default-xorg-module))
		 ;;		      (drivers '("nvidia"))
		 ;;		      (keyboard-layout keyboard-layout))))
                 ;; (set-xorg-configuration
                 ;;  (xorg-configuration (keyboard-layout keyboard-layout))))
    (remove (lambda (service)
      (eq? (service-kind service) gdm-service-type))
	%desktop-services)))

           ; This is the default list of services we
           ; are appending to.
           ; %desktop-services))
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/")
                         (device (uuid
                                  "e4194457-afbb-4725-87b6-555b6bc4f286"
                                  'ext4))
                         (type "ext4"))
                       (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "249D-4506"
                                       'fat32))
                         (type "vfat")) %base-file-systems)))
