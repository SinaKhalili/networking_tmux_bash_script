#!/bin/bash
startPacketCapture(){
  #arg 1: username, arg 2: destination
  ssh $1@$2 "
      tmux new-session -d -s \"$2\";
      tmux send-key -t \"$2\" \"tshark -i eth1 -w capture-of-$2.pcap\" ENTER;
      echo $2 has started to record;
    "
}

joinNetwork(){
  #arg 1: username, arg 2: destination, arg 3: mgenJoinScriptL1, arg4 mgenJoinScriptL2
  ssh $1@$2 "
    echo $3 > genInput.mgn;
    echo $4 >> genInput.mgn;
    tmux new-session -d -s \"$2\";
    tmux send-key -t \"$2\" \"mgen input genInput.mgn\" ENTER;
    echo $2 has joined the multicast network;
    "
}

sendTraffic(){
#arg 1: username, arg 2: destination, arg 3: mgenSendMultiScript
  ssh $1@$2 "
    echo $3 > genSend.mgn;
    tmux new-session -d -s \"$2\";
    tmux send-key -t \"$2\" \"mgen input genInput.mgn\" ENTER;
    echo $2 has started multicasting;
    "
}

removeCapFiles(){
  if test $3 = $2
    then
    ssh $1@$2 "
      rm capture-of-$2.pcap;
    "
  fi
}

stopTmux(){
  #arg 1: username, arg 2: destination
  ssh $1@$2 "
    tmux kill-session -t \"$2\";
    "
}

if test $# -le 1
then
        echo "Please provide the multicast address and "
        echo "the port to use for your group"
        echo "as command line arguments - in that order"
        exit 1
fi

mgenSendMultiScript = "0.0 ON 1 UDP DST $1/$2 PERIODIC [1.0 1024]"
mgenJoinScriptL1 = "0.0 JOIN $1 PORT $2"
mgenJoinScriptL2 = "0.0 LISTEN UDP $2"

echo "Welcome to the bash script for capturing multicast packets!"
echo "You have chosen $1 as your multicast address and $2 as your port"
echo "Now, I need your username"
echo "It should be at the prompt such as username@cs-vnl-02"
echo "Please type in your username here:"
read username
echo "Thanks, $username"
echo "And what machine are you running this script on? This is so we don't delete your packet capture"
read userHost
echo "You will also be prompted for your password later, so please pay attention"

echo "Alright, now we will choose hosts to record packets on"

echo "Pick a host from network 16 to record on:"
echo "Hosts on network: Summer, Fall, Equinox, April, June, and September"
read pcnet16
echo "Ok. $pcnet16 will record. "

echo "Pick a host from network 17 to record on:"
echo "Hosts on network: Autumn, November, Spring, August"
read pcnet17
echo "Ok. $pcnet17 will record. "

echo "Pick a host from network 18 to record on:"
echo "Hosts on network: May, July, Winter"
read pcnet18
echo "Ok. $pcnet18 will record. "

echo "Pick a host from network 19 to record on:"
echo "Hosts on network: October, Solstice, Year"
read pcnet19
echo "Ok. $pcnet19 will record. "

echo "Alright, nice!"
echo "Now, we will pick which of the hosts will join our multicast groups"

echo "Pick a host from network 16 to join the group:"
echo "Hosts on network: Summer, Fall, Equinox, April, June, and September"
echo "Do NOT pick $pcnet16 since it is recording"
read mcrnet16
echo "Ok. $mcrnet16 added to the group. "

echo "Pick two hosts from network 17 to join the group:"
echo "Hosts on network: Autumn, November, Spring, August"
echo "Do NOT pick $pcnet17 since it is recording"
read mcr1net17
echo "Ok. $mcr1net17 added to the group. "
echo "Now pick the next one:"
echo "Hint: Don't pick $pcnet17 or $mcr1net17"
read mcr2net17
echo "Ok. $mcr2net17 added to the group. "

echo "Pick a host from network 18 to join the group:"
echo "Hosts on network: May, July, Winter"
echo "Do NOT pick $pcnet18 since it is recording"
read mcrnet18
echo "Ok. $mcrnet18 added to the group. "

echo "Pick a host from network 19 to join the group:"
echo "Hosts on network: October, Solstice, Year"
echo "Do NOT pick $pcnet19 since it is recording"
read mcrnet19
echo "Ok. $mcrnet19 added to the group. "

echo "Alright! Almost done with the inputs!"
echo "Now we're going to pick which hosts to send packets"

echo "Pick a host from network 16 to send packets:"
echo "Hosts on network: Summer, Fall, Equinox, April, June, and September"
echo "Do NOT pick $pcnet16 nor $mcrnet16 "
read mcsnet16
echo "Ok. $mcsnet16 will send packets. "

echo "Pick a host from network 17 to send packets:"
echo "Hosts on network: Autumn, November, Spring, August"
echo "Do NOT pick $pcnet17 nor $mcr1net17 nor $mcr2net17"
read mcsnet17
echo "Ok. $mcsnet16 will send packets. "

echo "Pick a host from network 18 to send packets:"
echo "Hosts on network: May, July, Winter"
echo "Do NOT pick $pcnet18 nor $mcrnet18 "
read mcsnet18
echo "Ok. $mcsnet18 will send packets. "

echo "Pick a host from network 19 to send packets:"
echo "Hosts on network: October, Solstice, Year"
echo "Do NOT pick $pcnet19 nor $mcrnet19 "
read mcsnet19
echo "Ok. $mcsnet19 will send packets. "

echo "Great! You've entered all the required information."
echo "A quick recap: "
echo "Our hosts capturing packets are : "
echo "$pcnet16, $pcnet17, $pcnet18, and $pcnet19"
echo "Joining in their respective networks' multicast groups we have: "
echo " $mcrnet16, $mcr1netls17, $mcr2net17, $mcrnet18, and $mcrnet19"
echo "And finally, our packet senders are: "
echo " $mcsnet16, $mcsnet17, $mcsnet18, and $mcsnet19"

echo "FIRST WE WILL BEGIN CAPTURING PACKAGES"

startPacketCapture $username $pcnet16
startPacketCapture $username $pcnet17
startPacketCapture $username $pcnet18
startPacketCapture $username $pcnet19

echo "======================================================"
echo "-------------------- STEP ONE ------------------------"
echo "======================================================"

joinNetwork $username $mcrnet16 $mgenJoinScriptL1 $mgenJoinScriptL2
joinNetwork $username $mcr1net17 $mgenJoinScriptL1 $mgenJoinScriptL2
joinNetwork $username $mcr2net17 $mgenJoinScriptL1 $mgenJoinScriptL2
joinNetwork $username $mcrnet18 $mgenJoinScriptL1 $mgenJoinScriptL2
joinNetwork $username $mcrnet19 $mgenJoinScriptL1 $mgenJoinScriptL2

echo "================ Step One complete. Waiting 60 seconds"
sleep 60

echo "======================================================"
echo "-------------------- STEP TWO ------------------------"
echo "======================================================"

sendTraffic $username $mcsnet16 $mgenSendMultiScript
sendTraffic $username $mcsnet17 $mgenSendMultiScript
sendTraffic $username $mcsnet18 $mgenSendMultiScript
sendTraffic $username $mcsnet19 $mgenSendMultiScript

echo "================ Step Two complete. Waiting 60 seconds"
sleep 60

echo "======================================================"
echo "-------------------- STEP THREE ----------------------"
echo "======================================================"

stopTmux $username $mcsnet16
stopTmux $username $mcsnet17
stopTmux $username $mcsnet18
stopTmux $username $mcsnet19

echo "================ Step Three complete. Waiting 60 seconds"
sleep 60

echo "======================================================"
echo "-------------------- STEP FOUR ----------------------"
echo "======================================================"

stopTmux $username $mcrnet16
stopTmux $username $mcrnet18
stopTmux $username $mcrnet19
stopTmux $username $mcr1net17
stopTmux $username $mcr2net17

echo "================ Step Four complete. =============="

echo "Now we will stop the packet captures"

stopTmux $username $pcnet16
stopTmux $username $pcnet17
stopTmux $username $pcnet18
stopTmux $username $pcnet19

echo "Now we will move the files to this host"

scp $username@$pcnet16:~/capture-of-$pcnet16.pcap ~/capture-of-$pcnet16.pcap
scp $username@$pcnet17:~/capture-of-$pcnet17.pcap ~/capture-of-$pcnet17.pcap
scp $username@$pcnet18:~/capture-of-$pcnet18.pcap ~/capture-of-$pcnet18.pcap
scp $username@$pcnet19:~/capture-of-$pcnet19.pcap ~/capture-of-$pcnet19.pcap

echo "Finally we will remove the files on the other hosts"

removeCapFiles $username $pcnet16 $userHost
removeCapFiles $username $pcnet17 $userHost
removeCapFiles $username $pcnet18 $userHost
removeCapFiles $username $pcnet19 $userHost

echo "Script is finished."
