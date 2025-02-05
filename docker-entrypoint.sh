#!/bin/sh

# if command is sshd, set it up correctly
if [ "${1}" = 'sshd' ]; then
  set -- /usr/sbin/sshd -D

  # Setup SSH HostKeys if needed
  for algorithm in rsa dsa ecdsa ed25519
  do
    keyfile=/etc/ssh/keys/ssh_host_${algorithm}_key
    [ -f $keyfile ] || ssh-keygen -q -N '' -f $keyfile -t $algorithm
    grep -q "HostKey $keyfile" /etc/ssh/sshd_config || echo "HostKey $keyfile" >> /etc/ssh/sshd_config
  done
  # Disable unwanted authentications
  perl -i -pe 's/^#?((?!Kerberos|GSSAPI)\w*Authentication)\s.*/\1 no/; s/^(PubkeyAuthentication) no/\1 yes/' /etc/ssh/sshd_config
  # Disable sftp subsystem
  perl -i -pe 's/^(Subsystem\ssftp\s)/#\1/' /etc/ssh/sshd_config

  # https://jasonhzy.github.io/2016/02/03/ssh-alive/
  # Enable keep alive
  perl -i -pe 's/^#(ClientAliveInterval) 0/$1 300/' /etc/ssh/sshd_config
  perl -i -pe 's/^#(ClientAliveCountMax) 0/$3 2/' /etc/ssh/sshd_config

  perl -i -pe 's/^#(UseDNS) no/\1 no/' /etc/ssh/sshd_config

  # echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes128-cbc,aes192-cbc,aes256-cbc,chacha20-poly1305@openssh.com,3des-cbc" >> /etc/ssh/sshd_config

  # https://man7.org/linux/man-pages/man5/sshd_config.5.html
  # maximize connections
  perl -i -pe 's/^#(MaxSessions) 10/\1 1024/' /etc/ssh/sshd_config
  perl -i -pe 's/^#(MaxStartups) 10:30:100/\1 1024/' /etc/ssh/sshd_config
fi

# Fix permissions at every startup
chown -R git:git ~git

# Setup gitolite admin  
if [ ! -f ~git/.ssh/authorized_keys ]; then
  if [ -n "$SSH_KEY" ]; then
    [ -n "$SSH_KEY_NAME" ] || SSH_KEY_NAME=admin
    echo "$SSH_KEY" > "/tmp/$SSH_KEY_NAME.pub"
    su - git -c "gitolite setup -pk \"/tmp/$SSH_KEY_NAME.pub\""
    rm "/tmp/$SSH_KEY_NAME.pub"
  else
    echo "You need to specify SSH_KEY on first run to setup gitolite"
    echo "You can also use SSH_KEY_NAME to specify the key name (optional)"
    echo 'Example: docker run -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" jgiannuzzi/gitolite'
    exit 1
  fi
# Check setup at every startup
else
  su - git -c "gitolite setup"
fi

exec "$@"
