# NFS External Storage Provisioner

## Introduction
This provisioner requires an External NFS Server to work. It dynamically creates Directories in the remote NFS Server

[A guide to setting up dynamic NFS provisioning in Kubernetes](https://www.youtube.com/watch?v=DF3v2P8ENEg)

## NFS Server Setup

Learn how to [Mount and Use Block Volumes](https://www.scaleway.com/en/docs/storage/block/how-to/mount-and-use-volume/)

This assumes that you have a storage Server with a block volume mounted on `/mnt/external`

You can look at the the [Full Guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-20-04)

1. Install NFS Server and Create Directory to Shar
```bash
# Install the NFS Server
sudo apt update
sudo apt install nfs-kernel-server

# Create Volume
sudo mkdir /mnt/external/nfs -p
sudo chown nobody:nogroup /mnt/external/nfs
```

2. Add the following to `/etc/exports`, Note that `*` shares to all clients. If you want to lock this down, you can put specific IPAddress

```bash
/mnt/external/nfs  *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)
```
3. Restart NFS Server

```bash
# export nfs share
sudo exportfs -rav
# restart server
sudo systemctl restart nfs-kernel-server

# Verify that it was exported
sudo showmount -e localhost
```

4. Verify that all nodes can mount the NFS Server

```bash
# Install the NFS utils
sudo apt update
sudo apt install nfs-common

# Create Mount Point
sudo mkdir -p /mnt/nfs_clientshare

# Mount the NFS Share
mount 192.168.43.234:/mnt/external/nfs  /mnt/nfs_clientshare

# You can test with creating a file
touch sample-test.txt

# Then you cna verify it by checking /mnt/external/nfs on the storage server to see if you can see the file

# And finally, you can unmount with
umount /mnt/nfs_clientshare
```

## NFS Storage Deployment

To Deploy the storage provisioner, After cloning the repository, simply update `/storage/nfs-storage/deployment.yaml` and replace the values labeled `<<nfs-server-ip>>` and optionally the path `/mnt/external/nfs` if you used something else

If you have no other storage class in your cluster and want to make this the default storage, simply uncomment the lines in `/storage/nfs-storage/class.yaml`

```bash
  # annotations:
  #   storageclass.kubernetes.io/is-default-class: "true"
```

And then you can deploy it simply using

```bash
kubectl create ns nfs-storage
kubectl apply -k nfs-storage
```