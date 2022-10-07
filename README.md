# Experiment in container-native Fedora derivative 

This repository demonstrates 
https://fedoraproject.org/wiki/Changes/OstreeNativeContainerStable

Two things are built from here:

- A cloud-init guest qcow2 (usable in systems like OpenStack, Kubevirt, via libvirt, or AWS etc.)
- A container image

# Using the disk image

If you're familiar with a system like OpenStack or KubeVirt, you can upload
the qcow2 and use it in the same way as any other cloud-init guest image.

To test things out on a system with libvirt (could be a Linux desktop or
standalone server), the [libvirt cloud init support](https://blog.wikichoon.com/2020/09/virt-install-cloud-init.html)
works.

## Using the container image

The same OS image is *also* a container image, available at
`ghcr.io/cgwalters/dnfimage-cloud`, so you can run it via podman/docker/Kubernetes/etc.

It's not expected to use this as an "application" base image; while it
would work to `dnf -y install httpd` in this and run it as e.g.
a Kubernetes pod, that's not actually the intended use.  

For now, start by booting the VM image.

# Things to try

## dnf upgrade

Type `dnf upgrade` - notice it *fetches a container image* to perform upgrades;
it's not doing package-by-package upgrades.  We're using [skopeo](https://github.com/containers/skopeo/)
to *fetch* container images, but we're not actually running the OS as a container
in any way.

(Incidentally, today this repository tracks [a COPR](https://copr.fedorainfracloud.org/coprs/g/CoreOS/continuous/)
 tracking git main of several projects, so updates are frequent)

The system you're running is actually a [rpm-ostree](https://github.com/coreos/rpm-ostree/)
system - we've just swapped out about half of the "ostree stuff" for
a focus instead on fetching container images.

But this transition was designed carefully to keep the "good parts" of
rpm-ostree; we haven't done a complete rewrite (in fact, all of this
container functionality is purely additive today).

As the message says, you can `systemctl reboot` or `dnf image apply-live`
as you prefer.

## Deriving custom builds as containers

What's much more interesting and exciting though is the model of
creating derived bootable operating systems using
*any container build tooling you want*.

Look at [examples/ansible-firewalld](examples/ansible-firewalld)
for just one example.  You can build this (e.g. via podman
or whatever), and push it to a registry.  You can automate
builds using quay.io or Github actions or...whatever.

Try writing your own `Dockerfile` that does something; perhaps
installs `cowsay` or `freeipa` or whatever.  Or does
`curl` on a binary utility you want that's not an RPM.  Use
a multi-stage Dockerfile build.

Once you have your custom dervied OS image, on the node run:

```
$ dnf image rebase --experimental --no-signature-verification $image
```

Then either boot into it `reboot` or `dnf image apply-live`.

Then, try modifying your container - add a new package, or better - remove
a package in your Dockerfile.  Then have your container rebuilt and repushed,
and just `dnf upgrade` to get it.

## Client-side layering

The container-native functionality is new.  But actually, `rpm-ostree` has for years now
had support for client side layering.  So going back to your
VM (not in a Dockerfile), type `dnf install $package`.  Imagine
a scenario where you're building your "golden OS state" as a container
and applying it to a hundred machines; but you want just one (or a few)
to have a particular package.

With client side layering, this makes it really easy to have *per machine state*.
You can easily [override the kernel](https://coreos.github.io/rpm-ostree/administrator-handbook/#using-overrides-and-usroverlay) on one particular machine *without*
building a new container.

However, you can still reset back to the golden image too!

Effectively, `dnf image` just adds the superpower of booting and upgrading
from container images, *without* compromising the ability to do
per-machine state or *requiring* one to build a new image to update.
