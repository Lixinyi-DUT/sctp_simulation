
# connected via a router.

Trace set show_sctphdr_ 1

set ns [new Simulator]
set nf [open sctp.nam w]
set rnd [open rounter_rnd.tr w]
$ns namtrace-all $nf

set allchan [open sctp_router.tr w]
$ns trace-all $allchan

proc finish {} {
    global ns nf allchan

    $ns flush-trace
    close $nf
    close $allchan

    exec nam sctp.nam &

    exit 0
}

set host0_core [$ns node]
set host0_if0 [$ns node]
set host0_if1 [$ns node]
$host0_core color Red
$host0_if0 color Red
$host0_if1 color Red
$ns multihome-add-interface $host0_core $host0_if0
$ns multihome-add-interface $host0_core $host0_if1

set host1_core [$ns node]
set host1_if0 [$ns node]
set host1_if1 [$ns node]
$host1_core color Blue
$host1_if0 color Blue
$host1_if1 color Blue
$ns multihome-add-interface $host1_core $host1_if0
$ns multihome-add-interface $host1_core $host1_if1

set router [$ns node]

$ns duplex-link $host0_if0 $router .5Mb 200ms DropTail
$ns duplex-link $host0_if1 $router .5Mb 200ms DropTail

$ns duplex-link $host1_if0 $router .5Mb 200ms DropTail
$ns duplex-link $host1_if1 $router .5Mb 200ms DropTail

set sctp0 [new Agent/SCTP]
$ns multihome-attach-agent $host0_core $sctp0
$sctp0 set fid_ 0 
$sctp0 set debugMask_ -1
$sctp0 set debugFileIndex_ 0
$sctp0 set mtu_ 1500
$sctp0 set dataChunkSize_ 1468 
$sctp0 set numOutStreams_ 1
$sctp0 set oneHeartbeatTimer_ 0  # each dest has its own heartbeat timer

set trace_ch [open trace.sctp w]
$sctp0 set trace_all_ 1           # trace them all on oneline
$sctp0 trace cwnd_
$sctp0 trace rto_
$sctp0 trace errorCount_
$sctp0 attach $trace_ch

set sctp1 [new Agent/SCTP]
$ns multihome-attach-agent $host1_core $sctp1
$sctp1 set debugMask_ -1
$sctp1 set debugFileIndex_ 1
$sctp1 set mtu_ 1500
$sctp1 set initialRwnd_ 131072 
$sctp1 set useDelayedSacks_ 1

$ns color 0 Red
$ns color 1 Blue

$ns connect $sctp0 $sctp1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $sctp0

$sctp0 set-primary-destination $host1_if0

proc record {} {
  global ns sctp0 sctp1 rnd
  set now [$ns now]
  puts $rnd "$now [$sctp0 set cwnd_] 0"
  puts $rnd "$now [$sctp1 set cwnd_] 1"
  $ns at [expr $now+0.01] "record"
}

# change primary
$ns at 7.5 "$sctp0 set-primary-destination $host1_if1"
$ns at 7.5 "$sctp0 print cwnd_"

$ns at 0.5 "$ftp0 start"
$ns at 0.5 "record"
$ns at 12.0 "finish"

$ns run