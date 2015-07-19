# EXAMPLE SCRIPT 6
#
# Demonstrates Concurrent Multipath Transfer with Potentially Failed
# (CMT-PF).  Two endpoints with 2 interfaces with direct connections
# between each pair.  A link failure is introduced at 10.0 sec to one
# of the paths. Data transfer continues with the other path.
#
#       host0_if0      O===========O    host1_if0
#                     /             \
#       host0_core   O               O  host1_core
#                     \             /
#       host0_if1      O===========O    host1_if1

Trace set show_sctphdr_ 1

set ns [new Simulator]
set nf [open sctp.nam w]
$ns namtrace-all $nf

set allchan [open all.tr w]
$ns trace-all $allchan

proc finish {} {
    global ns nf allchan

    set PERL "/usr/bin/perl"
    set NSHOME "C:/Users/_lxy/Desktop/cygwin/ns-allinone-2.34"
    set XGRAPH "$NSHOME/bin/xgraph"
    set SETFID "$NSHOME/ns-2.34/bin/set_flow_id"
    set RAW2XG_SCTP "$NSHOME/ns-2.34/bin/raw2xg-sctp"
    set GETRC "$NSHOME/ns-2.34/bin/getrc"

    $ns flush-trace
    close $nf
    close $allchan

    # Graph the host0_if0 <-> host1_if0
    exec $PERL $GETRC -s 1 -d 4 all.tr > all.tr.if0 
    exec $PERL $GETRC -s 4 -d 1 all.tr >> all.tr.if0 
    exec $PERL $SETFID -s all.tr.if0 | \
        $PERL $RAW2XG_SCTP -A -q -t if0 > temp.rands.if0
    exec $XGRAPH -bb -tk -nl -m -x time -y packets temp.rands.if0 &
    
    # Graph the host0_if1 <-> host1_if1
    exec $PERL $GETRC -s 2 -d 5 all.tr > all.tr.if1 
    exec $PERL $GETRC -s 5 -d 2 all.tr >> all.tr.if1
    exec $PERL $SETFID -s all.tr.if1 | \
        $PERL $RAW2XG_SCTP -A -q -t if1 > temp.rands.if1
    exec $XGRAPH -bb -tk -nl -m -x time -y packets temp.rands.if1 &
    
    # Graph the entire association on one graph
    exec $PERL $SETFID -s all.tr | \
        $PERL $RAW2XG_SCTP -A -q -t all > temp.rands
    exec $XGRAPH -bb -tk -nl -m -x time -y packets temp.rands &
    
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

$ns duplex-link $host0_if0 $host1_if0 10Mb 45ms DropTail
[[$ns link $host0_if0 $host1_if0] queue] set limit_ 50
$ns duplex-link $host0_if1 $host1_if1 10Mb 45ms DropTail
[[$ns link $host0_if1 $host1_if1] queue] set limit_ 50

set sctp0 [new Agent/SCTP/CMT]
$ns multihome-attach-agent $host0_core $sctp0
$sctp0 set fid_ 0 
$sctp0 set debugMask_ -1
$sctp0 set debugFileIndex_ 0
$sctp0 set mtu_ 1500
$sctp0 set dataChunkSize_ 1468
$sctp0 set numOutStreams_ 1
$sctp0 set useCmtReordering_ 1    # turn on Reordering algo.
$sctp0 set useCmtCwnd_ 1          # turn on CUC algo.
$sctp0 set useCmtDelAck_ 1        # turn on DAC algo.
$sctp0 set eCmtRtxPolicy_ 4       # rtx. policy : RTX_CWND
$sctp0 set useCmtPF_ 1            # turn on CMT-PF
$sctp0 set cmtPFCwnd_ 2           # cwnd=2*MTU after HB-ACK

set trace_ch [open trace.sctp w]
$sctp0 set trace_all_ 1           # trace them all on one line
$sctp0 trace cwnd_
$sctp0 trace rto_
$sctp0 trace errorCount_
$sctp0 attach $trace_ch

set sctp1 [new Agent/SCTP/CMT]
$ns multihome-attach-agent $host1_core $sctp1
$sctp1 set debugMask_ -1
$sctp1 set debugFileIndex_ 1
$sctp1 set mtu_ 1500
$sctp1 set initialRwnd_ 65536 
$sctp1 set useDelayedSacks_ 1
$sctp1 set useCmtDelAck_ 1

$ns color 0 Red
$ns color 1 Blue

$ns connect $sctp0 $sctp1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $sctp0

# set primary before association starts
$sctp0 set-primary-destination $host1_if0

$ns rtmodel-at 10.0 down $host0_if1 $host1_if1

$ns at 0.5 "$ftp0 start"
$ns at 75.0 "finish"

$ns run