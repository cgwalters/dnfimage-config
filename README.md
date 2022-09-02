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
https://pagure.io/fedora-kickstarts/blob/main/f/fedora-cloud-base-gcp.ks

# Using

Boot `$image` in GCP, and log in however you prefer; for example
using the GUI console's "SSH" tab.
