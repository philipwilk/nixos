# Migration plan for moving /var/lib state on sou host

State is currently split between `/pool` and `/var/lib`, where `/pool` is a raidz2 zpool known as `storagepool`, and `/var/lib` is a raidz1 zpool known as `root`, which is on the same disks as the root and boot mounts.
This is problematic as os state and application state are being stored together, when they should be indepedent (application state should not be dependent on integrity of os state).

The state will be moved fully to `storagepool`, which will be renamed to `statepool`, with the `/pool` mountpoint being deprecated in favour of using the new `/var/lib` mount.
The existing `pool` dataset on `statepool` will be renamed to `state`.
All uses of `storagepool` will be updated to use `statepool`, and all uses of `/pool` will be updated to use `/var/lib`.

## Estimated downtime: 30min

## Proposed migration steps

1. shut down `sou`

1. boot `sou` off a nixos bootable usb

1. 1. import the `root` pool via `zpool import root -fF`
   1. mount the `root` dataset via `mount -t zfs root/root /mnt -o zfsutil`
   1. mount `/mnt/boot` point via `mount /dev/disk/by-id/ata-WDC_WDS100T1R0A-68A4W0_25143R801025-part1 /mnt/boot`
   1. mount the cold spare boot mountpoint, `/mnt/boot2` via `mount /dev/disk/by-id/ata-WDC_WDS100T1R0A-68A4W0_25143R801032-part1 /mnt/boot2`
   1. mount `resolv.conf` for passthrough so net works later in nixos-enter, via `mount -o bind,ro /etc/resolv.conf /mnt/etc/resolv.conf`

1. import `storagepool`, renaming it in the process, by doing `zpool import storagepool statepool -fF`

1. scrub the pool to ensure integrity via `zpool scrub statepool`

1. rename the dataset via `zfs rename statepool/pool statepool/state`

1. mount `statepool/state` in a temporary location for the move, via `mount -t zfs statepool/state /mnt/state -o zfsutil`

1. copy all contents of `/mnt/var/lib` to `/mnt/state` via `cp /mnt/var/lib/* /mnt/state/`

1. 1. create old state location, `mkdir -p /mnt/var.old/lib`
   1. move contents of `/mnt/var/lib` to `/mnt/var.old/lib` via `mv /mnt/var/lib/* /mnt/var.old/lib/`

1. use `nixos-enter`

1. navigate to flake location `cd /home/philip/repos/nixos`

1. replace all uses of `/pool` with `/var/lib`. this may require some searching.

1. 1. in `sou`'s hardware config
   1. rename mounts that use `storagepool/pool` to `statepool/state`
   1. rename `/mnt/pool` mountpoint to `/var/lib`

1. rebuild the nixos system and reinstall the bootloader via `sudo nixos-rebuild switch --flake .#sou --install-bootloader`

1. prepare `sou` for next boot

1) exit the `nixos-enter` via `quit`
1) unmount all locations, `umount /mnt/boot` `umount /mnt/boot2` `umount /mnt/state` `umount /mnt`
1) CRITICAL: export all zfs pools. THE SYSTEM WILL NOT BOOT if this is not done. `zpool export root` `zpool export statepool`

16. reboot `sou`

## Hazards

- `sou` may refuse to boot due to zpool mount failure if all zpools are not exported correctly
- state be unused if all options are not updated. this dill be fixed with a system rebuild and correct config
- acme certs may be re-issued if state is not retained correctly

## Outcomes

- `storagepool/pool` had a legacy mountpoint, preventing the regular mounting approach from working. This was resolved trivially via `zfs set mountpoint=none storagepool/pool`
- `sou` did not boot for 3 hours as I did not realise i had to add `mpt3sas` kernel module to the initrd module list; resolved trivially by adding `boot.initrd.kernelModules = [ "mpt3sas" ];` to `sou`'s hardware configuration
- grafana has not carried its state correctly; will recover from old folder
- nextcloud's mariadb has exploded and is missing a table; will recover from old folder

Successfully migrated all other state to new location on `statepool/state`
