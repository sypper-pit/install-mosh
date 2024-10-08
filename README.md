#Mosh Usage Instructions

**Donate**
USDT TRC20: `TTZGfnhurU62VRRGYUHMPJ8q6U8rn5xG5a`

***Server Setup:***

Run the installation script on the server:

```sudo ./setup_mosh.sh```

if you want set locale use

```sudo ./setup_mosh-set-locale.sh``` default use ru_RU.UTF8

The script will automatically install Mosh, create a user, and set up the service.
    Ensure that UDP ports 60000 to 61000 are open in your server's firewall.

***Client Usage:***

Install Mosh on the client machine:

Ubuntu/Debian: `sudo apt-get install mosh`

macOS: `brew install mosh`

Windows: Use Windows Subsystem for Linux (WSL) or MobaXterm

#Connect to the server:

```mosh username@server-address```

Replace username with the actual username and server-address with the server's IP address or domain name.

#If you need to use a specific SSH port:

```mosh --ssh="ssh -p PORT" username@server-address```

Replace PORT with the desired port number.

#Benefits of using Mosh:
1) Robust connection in unstable network conditions
2) Works when client IP address changes
3) Instant response when typing commands
