# This example uses Ansible to configure firewalld to set up a node-local firewall suitable as recommended for use as an OpenShift 4 worker.
# However, this is intended to generalize to using Ansible as well as firewalld for generic tasks.
FROM ghcr.io/cgwalters/dnfimage-cloud

ADD firewall.yml .

# Install firewalld; also install ansible, use it to run a playbook, then remove it
# so it doesn't take up space persistently.
# TODO: Need to also remove ansible-installed dependencies
# TODO: drop the cliwrap skip after we have https://github.com/coreos/rpm-ostree/pull/3995
RUN dnf install -y firewalld ansible && \
    ansible-playbook firewall.yml && \
    env RPMOSTREE_CLIWRAP_SKIP=1 rpm -e ansible && \
    dnf clean all && \
    ostree container commit