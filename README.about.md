## `trombik.template_role`

A template for `ansible` role. The template is written for `sshd` server. You
can simply replace `template_role_*` variables and tasks with new role name
and what the new role does.

Without any modifications, the role can be tested on local machine, and in
`travis CI`. You do not have to write tests from scratch. Adjust the role and
the tests as you develop the role.

### Features

* A ready-to-test role. Tests includes: `yamlint`for YAML files, `rubocop` for
  `ruby` files, `serverspec` for unit tests, and `molecule` for integration tests.
* Supports CI in `travis CI` for linting and integration tests using `docker`
* Supported Virtualisations: `virtualbox` for `serverspec` and `molecule`,
  `virtualbox` and `docker` for `molecule`
* Supported OS platforms include: FreeBSD, OpenBSD, Ubuntu, and CentOS
* Tests scenarios in `travis CI` run in parallel

### Implementations

#### Unit tests and integration tests

A unit test is defined here as "a test that examines every task in the role".
In a unit test, the test will see every details of converged states in VMs.
Files, services, and other resources are tested in unit tests. Unit tests are
expected not to change the state of VMs, i.e. repeated tests produce same
results.

Unit tests are located under [`tests/serverspec`](tests/serverspec).

An integration test is defined as "a test that expects certain results after
conversion and, optionally, side effects. Unlike unit tests, expected
outcomes are tested in integration tests. Examples are: fail-over in a
cluster, and message delivery from a client to a server.

In this role template, `test-kitchen`, `kitchen-vagrant`, and `serverspec` are
used for unit tests.

`molecule`, `vagrant`, and `testinfra` are used for integration tests.

Integration tests are located under [`tests/molecule`](tests/molecule).

## Requirements

TBW

## Usage

### Unit tests

#### List all `test-kitchen` suites

```
> bundle exec kitchen list
Instance                   Driver   Provisioner      Verifier  Transport  Last Action    Last Error
default-freebsd-120-amd64  Vagrant  AnsiblePlaybook  Shell     Rsync      <Not Created>  <None>
default-openbsd-65-amd64   Vagrant  AnsiblePlaybook  Shell     Rsync      <Not Created>  <None>
default-ubuntu-1804-amd64  Vagrant  AnsiblePlaybook  Shell     Rsync      <Not Created>  <None>
default-centos-74-x86-64   Vagrant  AnsiblePlaybook  Shell     Rsync      <Not Created>  <None>
```

#### Run all test suites or a test suite


Run all tests:

```
bundle exec kitchen test
```

Run `default-freebsd-120-amd64` only

```
> bundle exec kitchen test default-freebsd-120-amd64
```

### Integration tests

#### List all available scenarios

```
> molecule list

Instance Name    Driver Name    Provisioner Name    Scenario Name        Created    Converged
---------------  -------------  ------------------  -------------------  ---------  -----------
server1          vagrant        ansible             default              false      false
client1          vagrant        ansible             default              false      false
server1          docker         ansible             travisci_centos7     false      false
client1          docker         ansible             travisci_centos7     false      false
server1          docker         ansible             travisci_ubuntu1804  false      false
client1          docker         ansible             travisci_ubuntu1804  false      false
```

#### Run `default` integration test

```
> molecule test
```

If you want to inspect VMs after failure, run with `--destroy never`.

```
> molecule test --destroy never
```

## Limitations

### No integration tests for FreeBSD and OpenBSD in Travis CI

The implementation uses `docker` as virtualisation in Travis CI. As such, it
does not support FreeBSD and OpenBSD.

### No unit tests in Travis CI

Unit tests are not tested in `travis CI`.

### HTTP proxy is not supported in integration tests

HTTP proxy is supported in unit tests. Set `ANSIBLE_PROXY`.
`.kitchen.local.yml` (see below) implements automatic HTTP proxy detection: if it finds
port 8080 on local machine is listening, it sets the `ANSIBLE_PROXY`. However,
HTTP proxy is not supported in integration tests. `molecule` recommends
`vagrant-proxyconf`, but it does not support FreeBSD or OpenBSD.

## Examples

### An example of `.kitchen.local.yml`

This is an optional file that detects a listening port on local machine, and,
if the port (8080) is open, use the port as HTTP proxy service.

```ruby
<%
require 'socket'
# @return [String] public IP address of workstation used for egress traffic
def local_ip
  @local_ip ||= begin
    # turn off reverse DNS resolution temporarily
    orig, Socket.do_not_reverse_lookup = Socket.do_not_reverse_lookup, true

    # open UDP socket so that it never send anything over the network
    UDPSocket.open do |s|
      s.connect '8.8.8.8', 1 # any global IP address works here
      s.addr.last
    end
  ensure
    Socket.do_not_reverse_lookup = orig
  end
end
# @return [Integer] default listening port
def local_port
  ENV['KITCHEN_PROXY_PORT'] ? ENV['KITCHEN_PROXY_PORT'] : 8080
end
# @return [String] the proxy URL
def http_proxy_url ; "http://#{local_ip}:#{local_port}" ; end
# @return [TrueClass,FalseClass] whether or not the port is listening
def proxy_running?
  socket = TCPSocket.new(local_ip, local_port)
  true
rescue SocketError, Errno::ECONNREFUSED,
  Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
  false
rescue Errno::EPERM, Errno::ETIMEDOUT
  false
ensure
  socket && socket.close
end
%>
---
<% if proxy_running? %>
provisioner:
  http_proxy: <%= http_proxy_url %>
  https_proxy: <%= http_proxy_url %>
<% end %>
```

## LICENSE

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
