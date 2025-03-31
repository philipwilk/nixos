{
  ...
}:
{
  config = {
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;
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
    */
  };
}
