# Local forward:
# forwarding 4000 to remote:22
ssh -NL 0.0.0.0:4000:192.110.1.1:22 192.110.1.1


# Proxy forward:
ssh -CNg -R 4000:192.110.1.1:22 c1
