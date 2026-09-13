"""Python sitecustomize hook for ESPHome container.

Why this file exists:
1. The Talos cluster nodes and Cilium pod network operate with Jumbo Frames (MTU 9000).
2. Pods inherit this 9000 MTU, which causes outgoing TCP sockets to negotiate an MSS of ~8948.
3. When PlatformIO downloads packages (e.g. toolchain-xtensa from usc1.contabostorage.com
   or other PlatformIO registry mirrors), the remote servers send large TLS certificate/data
   packets (~3000+ bytes).
4. Because the WAN/internet gateway has a standard MTU of 1500 (or 1492/1280 depending on VPN/PPPoE)
   and Path MTU Discovery (PMTUD) is black-holed, these oversized packets get silently dropped,
   causing package downloads to hang and fail with ReadTimeout errors.
5. This hook is automatically loaded by Python on startup (via PYTHONPATH=/etc/python-sitecustomize:...).
   It monkey-patches socket creation to clamp TCP_MAXSEG to 1400 on all outbound connections,
   ensuring WAN downloads work reliably without timing out.
"""

import socket

_orig_socket = socket.socket


class PatchedSocket(_orig_socket):
    def connect(self, address):
        try:
            self.setsockopt(socket.IPPROTO_TCP, socket.TCP_MAXSEG, 1400)
        except Exception:
            pass
        return super().connect(address)


socket.socket = PatchedSocket
