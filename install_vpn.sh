#!/bin/bash

apt-get update && apt-get install pptp-linux -y

cat <<'EOF' > /etc/ppp/peers/test-vpn
pty "pptp 103.04.123.69 --nolaunchpppd"
name vpn
remotename TESTOWL
require-mppe-128
nodefaultroute
unit 12
persist
maxfail 10
holdoff 15
file /etc/ppp/options.pptp
ipparam $TUNNEL
EOF

POST_UP_SCRIPT=/etc/ppp/ip-up.d/01configure-route

cat <<'EOF' > "${POST_UP_SCRIPT}"
#!/bin/bash

IP=$4
INTERFACE=$1
ip route add $(echo $4 | cut -d'.' -f '1 2 3').0/24 via ${IP} dev ${INTERFACE}
EOF

chmod +x "${POST_UP_SCRIPT}"

cat <<EOF > /etc/ppp/chap-secrets
vpn TESTOWL testpassword
EOF

sleep 5

pon test-vpn debug nodetach
