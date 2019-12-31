# `trombik.template_role`

[![Build Status](https://travis-ci.com/trombik/trombik.template_role.svg?branch=master)](https://travis-ci.com/trombik/trombik.template_role)

`ansible` role for `template_role`.

This is a template role to develop new `ansible` role. Not to be used as
`ansible` role. Please see [README.about.md](README.about.md) for more
details.

# Requirements

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `template_role_package` | Package name of `template_role` | `{{ __template_role_package }}` |
| `template_role_service` | Service name of `template_role` | `{{ __template_role_service }}` |
| `template_role_extra_packages` | A list of extra package to install | `[]` |
| `template_role_user` | User name of `template_role` | `{{ __template_role_user }}` |
| `template_role_group` | Group name of `template_role` | `{{ __template_role_group }}` |
| `template_role_extra_groups` | A list of extra groups for `template_role_user` | `[]` |
| `template_role_log_dir` | Path to log directory | `/var/log/template_role` |
| `template_role_config_dir` | Path to the configuration directory | `{{ __template_role_config_dir }}` |
| `template_role_config_file` | Path to `template_role.conf` | `{{ template_role_config_dir }}/sshd_config` |
| `template_role_config` | The content of `template_role.conf` | `""` |
| `template_role_flags` | See below | `""` |

## `template_role_flags`

This variable is used for overriding defaults for startup scripts. In Debian
variants, the value is the content of `/etc/default/template_role`. In RedHat
variants, it is the content of `/etc/sysconfig/template_role`. In FreeBSD, it
is the content of `/etc/rc.conf.d/template_role`. In OpenBSD, the value is
passed to `rcctl set template_role`.

## Debian

| Variable | Default |
|----------|---------|
| `__template_role_service` | `ssh` |
| `__template_role_package` | `openssh-server` |
| `__template_role_config_dir` | `/etc/ssh` |
| `__template_role_user` | `sshd` |
| `__template_role_group` | `nogroup` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__template_role_service` | `openssh` |
| `__template_role_package` | `security/openssh-portable` |
| `__template_role_config_dir` | `/usr/local/etc/ssh` |
| `__template_role_user` | `sshd` |
| `__template_role_group` | `sshd` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__template_role_service` | `sshd` |
| `__template_role_package` | `""` |
| `__template_role_config_dir` | `/etc/ssh` |
| `__template_role_user` | `sshd` |
| `__template_role_group` | `sshd` |

## RedHat

| Variable | Default |
|----------|---------|
| `__template_role_service` | `sshd` |
| `__template_role_package` | `openssh-server` |
| `__template_role_config_dir` | `/etc/ssh` |
| `__template_role_user` | `sshd` |
| `__template_role_group` | `sshd` |

# Dependencies

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - trombik.template_role
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
        # in docker, init is not systemd
        - ansible_virtualization_type != 'docker'
        - ansible_os_family == 'RedHat' or ansible_os_family == 'Debian'
    - name: list all services (FreeBSD service)
      # workaround ansible-lint: [303] service used in place of service module
      shell: "echo; service -l"
      changed_when: false
      when:
        - ansible_os_family == 'FreeBSD'
  vars:
    os_template_role_flags:
      OpenBSD: -4
      FreeBSD: ""
      Debian: ""
      RedHat: ""

    # on RedHat, non-default port is not allowed to listen on
    # on FreeBSD, sshd from the base and one from the package are both running
    os_ports:
      OpenBSD: [22, 10022]
      FreeBSD: [10022]
      Debian: [22, 10022]
      RedHat: [22]
    template_role_flags: "{{ os_template_role_flags[ansible_os_family] }}"
    template_role_extra_groups:
      - bin
    template_role_config: |
      UseDNS no
      {% for p in os_ports[ansible_os_family] %}
      Port {{ p }}
      {% endfor %}
```

# License

```
Copyright (c) 2016 Tomoyuki Sakurai <y@trombik.org>

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
