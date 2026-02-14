# 🛡 Dockerized OpenConnect VPN Tunnel for Containers

A production-ready example of tunneling a Docker application container
through an OpenConnect VPN container using shared network namespaces.

This setup allows you to:

-   Run an app container fully behind VPN
-   Use split tunneling
-   Control DNS resolution
-   Isolate VPN networking from host
-   Avoid modifying host routing

------------------------------------------------------------------------

## 📦 Architecture

                ┌───────────────────┐
                │    openconnect     │
                │  (VPN container)   │
                └─────────┬─────────┘
                          │ (shared network namespace)
                ┌─────────▼─────────┐
                │        app         │
                │  (uses VPN stack)  │
                └────────────────────┘

The `app` container shares the network namespace of the `openconnect`
container:

``` yaml
network_mode: "service:openconnect"
```

This ensures **all outbound traffic from the app goes through the VPN**.

------------------------------------------------------------------------

## 🚀 Features

-   ✔ Dockerized OpenConnect client
-   ✔ Split tunneling support
-   ✔ Internal DNS configuration
-   ✔ Secure server certificate pinning
-   ✔ Environment-based configuration
-   ✔ Fail-fast validation
-   ✔ Production-friendly structure

------------------------------------------------------------------------

## 🛠 Requirements

-   Docker
-   Docker Compose
-   VPN server compatible with OpenConnect

------------------------------------------------------------------------

## ⚙️ Configuration

Create an `.env` file:

``` env
PASSWORD="your_password"
USERNAME="your_username"
GROUP="vpn_group"
HOST="vpn.company.com"
SERVER_PIN_CERT="sha256:xxxxxxxxxxxxxxxx"
PROTOCOL="anyconnect"
SPLIT_ROUTES="10.0.0.0/8 192.168.0.0/16"
DNS="1.1.1.1 8.8.8.8 192.168.1.2" # for global dns / or local dns
NO_DTLS=true
```

------------------------------------------------------------------------

## ▶ Run

``` bash
docker compose up -d
```

Check logs:

``` bash
docker logs -f openconnect
```

------------------------------------------------------------------------

## 🔀 Split Tunnel Example

If you define:

``` env
SPLIT_ROUTES="10.10.0.0/16 172.16.5.0/24"
```

Only those routes will go through the VPN.

All other traffic will use the default route.

------------------------------------------------------------------------

## 🌐 DNS Handling

If `DNS` is defined, `/etc/resolv.conf` inside the VPN container
will be overridden.
for communicating between services those aren't accessible through vpn, it is required to declare DNS.

------------------------------------------------------------------------

## 🔐 Security Notes

-   `SERVER_PIN_CERT` prevents MITM attacks
-   VPN credentials are injected via environment variables
-   Container runs with `NET_ADMIN` and `/dev/net/tun`

⚠️ This container requires privileged capabilities for VPN tunneling.

------------------------------------------------------------------------

## 📁 Project Structure

    .
    ├── Dockerfile
    ├── docker-compose.yml
    ├── entrypoint.sh
    ├── openconnect.env.sample
    ├── .env
    └── README.md

------------------------------------------------------------------------

## 💡 Use Cases
- Connect internal services through openconnect protocols specially anyconnect

------------------------------------------------------------------------

## 📜 License

MIT License
