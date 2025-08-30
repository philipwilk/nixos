{
  config,
  pkgs,
  lib,
  ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  config = {
    boot = {
      supportedFilesystems = [ "zfs" ];
      kernelPackages = lib.mkForce latestKernelPackage;
      zfs.forceImportRoot = false;
    };
    services.zfs.autoScrub.enable = true;
    /*
      fileSystems."/mnt/zfs/location" = {
        device  = "zfspool/dataset";
        fsType = "zfs";
        options = [ "zfsutil" ]; # removes need for dataset to have a legacy mountpoint
      };
    */
    /*
      # Creating a pool
      sudo zpool create -O compression=zstd -O mountpoint=none -O xattr=sa -O acltype=posixacl -o ashift=12 colossus raidz2 $DISKS

      # Creating a dataset
      zfs create colossus/root

      # Mounting
      mkdir -p /mnt/zfs/colossus
      mount -t zfs colossus/root /mnt/zfs/colossus -o zfsutil

      # steps to take in an emergency scenario where a single disk root partition fails
      # plug in a new drive
      # reboot into a nixos-minimal live usb
      # if the drive is larger than current, you may be able to do zfs replace (old) (new)
      # however, this will not work if the new drive is the same size or smaller than the old one
      # you will therefore need to create a new pool using the new drive, and copy the datasets over
      # for example:

      # create new fat boot part, then fill rest of drive with a part for zfs
      fdisk /dev/sdx
        g
        n
        1
        (enter)
        +1000M
        t
        1
        n
        2
        (enter)
        (enter)
        w

      # import the old pool, with -f, as the live usb counts as a different machine than the host
      zpool import (oldpool) -fF
      # try to repair what you can
      zpool scrub (oldpool)
      # create the new pool:
      zpool create -O compression=zstd -O mountpoint=none -O xattr=sa -O acltype=posixacl -o ashift=12 newroot /dev/(disk)(part 2)
      # copy data over. this may take a while. this is the easy part.
      zfs send (oldpool)/root | zfs receive newroot/root
      # repeat for home etc
      zfs send (oldpool)/home | zfs receive newroot/home

      # need to generate a new bootloader part
      # if old root still has sufficient data integrity, can use nixos-enter to make our life easy
      # mount root at /mnt
      mount -t zfs newroot/root /mnt -o zfsutil
      # mount home (if on own part)
      mount -t zfs newroot/home /mnt/home -o zfsutil
      # mount boot part
      mount /dev/(sdx1) /mnt/boot

      # revenge of https://github.com/NixOS/nixpkgs/issues/39665 ???
      mount -o bind,ro /etc/resolv.conf /mnt/etc/resolv.conf

      # load into original machine's environment
      nixos-enter

      # update your flake with new fat partition id and new zfs pool name in the fileSystems config
      # can retrieve these by using nixos-generate-config
      nano (yourflake)/hardware-configuration.nix

      # rebuild bootloader
      # substituters option is necessary if you host your own substituter... on the same machine...
      nixos-rebuild --install-bootloader boot --flake (your flake)#(hostname) --option substituters https://cache.nixos.org

      # remember to export the new pool or zfs wont mount the new pool...
      quit
      zpool export newroot
    */
  };
}
