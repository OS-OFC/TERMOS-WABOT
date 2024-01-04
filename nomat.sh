function goto
{
    label=$1
    cd 
    cmd=$(sed -n "/^:[[:blank:]][[:blank:]]*${label}/{:a;n;p;ba};" $0 | 
          grep -v ':$')
    eval "$cmd"
    exit
}

: serveo
clear
echo "Repo: https://github.com/kmille36/Docker-Ubuntu-Desktop-NoMachine"
ssh -R 80:localhost:4000 serveo.net -o ServerAliveInterval=60 &>/dev/null &
sleep 1
if curl --silent --show-error http://serveo.net  > /dev/null 2>&1; then echo OK; else echo "Serveo Error! Please try again!" && sleep 1 && goto serveo; fi
docker run --rm -d --network host --privileged --name nomachine-mate -e PASSWORD=123456 -e USER=user --cap-add=SYS_PTRACE --shm-size=1g thuonghai2711/nomachine-ubuntu-desktop:mate
clear
echo "NoMachine: https://www.nomachine.com/download"
echo Done! NoMachine Information:
echo IP Address:
curl --silent --show-error http://serveo.net/us | sed -nE 's/.*<p>([^<]*).*/\1/p'
echo User: user
echo Passwd: 123456
echo "VM can't connect? Restart Cloud Shell then Re-run script."
while true; do sleep 1; done
