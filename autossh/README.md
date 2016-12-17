Need the appropriate .ssh/config, such as 

```
Host jh
       Hostname yxz.domain.com
       User autossh
       IdentityFile ~/.ssh/id_rsa
       ForwardAgent yes
       Port 2202
       ServerAliveInterval 60
```
