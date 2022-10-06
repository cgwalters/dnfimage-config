# Experiment in container-native Fedora derivative 

This repository demonstrates 
https://fedoraproject.org/wiki/Changes/OstreeNativeContainer
combined with https://github.com/coreos/rpm-ostree/issues/2883

The code here was originally forked from
https://github.com/coreos/fedora-coreos-config/
but it must be emphasized:
*The resulting system does not use Ignition* (by default).
Instead, there are cloud-specific builds and disk images.

For the moment, only GCE is tested, and the build uses
`google-guest-agent`.  See for example
https://pagure.io/fedora-kickstarts/blob/main/f/fedora-cloud-base.ks

# Using

[Boot an instance in GCP](https://url.corp.redhat.com/7606f9c), and log in however you prefer; for example
using the GUI console's "SSH" tab.

# Things to try

## dnf upgrade

Type `dnf upgrade` - notice it *fetches a container image* to perform upgrades;
it's not doing package-by-package upgrades.  This is using 
https://fedoraproject.org/wiki/Changes/OstreeNativeContainer

Because this is "backed" by rpm-ostree, the updated image is queued for the next
boot; you can however use `rpm-ostree apply-live` today (this still needs
a `dnf` frontend.)

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

Then either boot into it `reboot` or `rpm-ostree apply-live`.

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
