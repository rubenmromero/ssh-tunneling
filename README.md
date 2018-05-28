# SSH Tunneling

Tutorial and script to use SSH tunneling like a ninja

## Starting point

Information security established as best practice, that accesses between different platform components or system must be implemented using the principle of least privilege. What has not happened, for instance, to have wanted to connect from a client installed on its computer to a remote database, which did not have a direct connection but does through another intermediate server (for example a bastion host)?

If you have ever seen yourself in this kind of trouble, then I encourage you to continue reading since you will find the weapons you need to become a true ninja of the tunneled connections in this post.

Below are the most frequent use cases we can deal with, presented from the least to the greatest complexity.

## The typical case…

Surely on more than one occasion you have seen it for yourself in some similar situation to the aforementioned,  or if you have wanted to request a web service protected by IP whitelist from the network where your computer is connected, whose public IP is not included in that list, knowing that you have SSH access to an intermediate server whose public IP is contained in the whitelist. Well, as simple as using the intermediate server as a hop machine via the following SSH tunnel:

    $ ssh -L <local_port>:<target_host>:<target_port> <user>@<hop_host>

Where:

* `<local_port>` => Port that we want to open on the loopback interface (`lo`) on our computer as a result of the SSH tunnel. If port number to be opened is less than 1024 (privileged ports, such as 80 or 443), the ssh command must be run with root privileges.
* `<target_host>` => Hostname or IP address associated to the target service against which we wish to establish a connection.
* `<target_port>` => Port associated to the target service against which we wish to establish a connection.
* `<user>` => User through who we have SSH accessto the hop machine (intermediate server).
* `<hop_host>` => Hostname or IP address associated to the hop machine (intermediate server).

Let’s look at couple of practical examples:

    # Connection from port 54321 of your computer to internal RDS instance with PostgreSQL, through a public EC2 instance with access to the RDS instance
    $ ssh -L 54321:<rds_endpoint>:5432 <user>@<ec2_host>
    
    # Connection from port 80 of your computer to a web service protected by IP whitelist, through a server with access to that service
    $ sudo ssh -L 80:<service_url>:80 <user>@<server_host>

After establishing the SSH tunnel, you can connect to the target service through the port that you have indicated in the `<local_port>` parameter opened on your computer (localhost). Since this port is associated to the loopback interface (127.0.0.1), it will only be accessible from your own computer in which the SSH tunnel has been run.

## Sharing is caring!

Let's consider your willing to contribute to others: you decide you want to share the connection you have created through the SSH tunnel with other computers connected to the network. This way, they can also connect to the target service through the `<local_port>` port opened in your computer – so what then? The solution is to use the gateway mode (`-g`) and your colleagues will be grateful:

    $ ssh -g -L <local_port>:<target_host>:<target_port> <user>@<hop_host>

Considering the examples used previously:

    # Connection from port 54321 of your computer to internal RDS instance with PostgreSQL, through a public EC2 instance with access to the RDS instance
    $ ssh -g -L 54321:<rds_endpoint>:5432 <user>@<ec2_host>
    
    # Connection from port 80 of your computer to a web service protected by IP whitelist, through a server with access to that service
    $ sudo ssh -g -L 80:<service_url>:80 <user>@<server_host>

When an SSH tunnel is performed in gateway mode, the `<local_port>` port is opened on the network interface (`eth0`) of the computer, and as a consequence, the said port will be accessible from any computer which has access to the host from which the SSH tunnel has been established.

## Tunnels as daemons!

Now that you have already shared the tunneled connection with your colleagues, it is very likely that you want to keep the SSH tunnel up for a long time. And so o it seems more comfortable to run it "daemonized" so that it does not depend on the terminal on which you have performed it. To achieve this, it is simply neccesary to add the `-fN` parameters to any of the ssh commands indicated above:

    $ ssh -fN [-g] -L <local_port>:<target_host>:<target_port> <user>@<hop_host>

## Publishing local services through reverse SSH tunnels in gateway mode

Now that you have already shared the tunneled connection with your colleagues, it is very likely that you want to keep the SSH tunnel up for a long time. And so o it seems more comfortable to run it "daemonized" so that it does not depend on the terminal on which you have performed it. To achieve this, it is simply neccesary to add the `-fN` parameters to any of the ssh commands indicated above:

    $ ssh [-fN] -g -R <source_port>:<target_host>:<target_port> <user>@<source_host>

Where:

* `<source_port>` => Port that we want to open on the network interface (`eth0`) of the source host (`<source_host>`) as a result of the SSH tunnel. If port number to be opened is less than 1024 (privileged ports, such as 80 or 443), the SSH connection to the source host must be performed through the root user (`root@<source_host>`).
* `<target_host>` => Hostname or IP address associated to the service which we want to publish. If this service is configured on our computer, the value of this parameter must be localhost.
* `<target_port>` => Port associated to the service that we want to publish.
* `<user>` => User through who we have SSH access to the source host (public server).
* `<source_host>` => Hostname or IP address associated to the source host (public server).

Let’s look at a couple of practical examples:

    # Publication of a MySQL service configured on port 3306 of a server belonging to your network to be accessible from port 3308 of a public EC2 instance
    $ ssh [-fN] -g -R 3308:<mysql_host>:3306 <user>@<ec2_host>
    
    # Publication of a web application deployed on port 80 of your computer to be accessible from port 80 of a public EC2 instance
    $ ssh [-fN] -g -R 80:localhost:80 root@<ec2_host>

Once establishing the SSH tunnel, the local service will be accessible from any source IP address which has access to the port to the one you have indicated in the `<source_port>` parameter opened on the network interface (`eth0`) of the source host (`<source_host>`).

**A word of warning**: To be able to perform these types of tunnels, it is necessary to enable the '`GatewayPorts yes`' parameter in the configuration of sshd service (`/etc/ssh/sshd_config`) of the source host (public server), since for security reasons, this option is disabled by default.

## Gilding the lily…

If all of this appeals to you and you're eager to try some of this, I propose a couple of further links to exploration:

* [Triple mortal tunnel](http://ufasoli.blogspot.com.es/2013/11/multi-hop-ssh-tunnel-howto-creating-ssh.html) (attention to bonus points)
* [SSH tunnel to multiple target services](http://www.linuxhorizon.ro/ssh-tunnel.html)
