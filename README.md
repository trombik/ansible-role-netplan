# `trombik.netplan`

`ansible` role for `netplan`.

# Requirements

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `netplan_package` | Package name of `netplan` | `{{ __netplan_package }}` |
| `netplan_extra_packages` | A list of packages to install | `[]` |
| `netplan_config_dir` | Path to configuration directory | `{{ __netplan_config_dir }}` |
| `netplan_config` | See below | `[]` |
| `netplan_force_flush_handlers` | If true, flush all handlers at the end of role tasks | `false` |

## Debian

| Variable | Default |
|----------|---------|
| `__netplan_package` | `netplan.io` |
| `__netplan_config_dir` | `/etc/netplan` |

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - ansible-role-netplan
  pre_tasks:
    - name: Dump all hostvars
      debug:
        var: hostvars[inventory_hostname]
  post_tasks:
    - name: List all services (systemd)
      # workaround ansible-lint: [303] service used in place of service module
      shell: "echo; systemctl list-units --type service"
      changed_when: false
      when:
        - ansible_os_family == 'RedHat' or ansible_os_family == 'Debian'
    - name: list all services (FreeBSD service)
      # workaround ansible-lint: [303] service used in place of service module
      shell: "echo; service -l"
      changed_when: false
      when:
        - ansible_os_family == 'FreeBSD'
  vars:
    netplan_clean_config: no
    netplan_force_flush_handlers: yes
    netplan_extra_packages:
      - bridge-utils
    netplan_config:
      - name: 60-bridge.yaml
        state: present
        content:
          network:
            version: 2
            renderer: networkd
            ethernets:
              eth1:
                dhcp4: "no"
                dhcp6: "no"
              eth2:
                dhcp4: "no"
                dhcp6: "no"
            bridges:
              br0:
                interfaces:
                  - eth1
                  - eth2
                parameters:
                  stp: "no"
                dhcp4: "no"
                dhcp6: "no"
```

# License

```
Copyright (c) 2019 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>
