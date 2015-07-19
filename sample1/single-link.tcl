set ns [new Simulator]                              
set tracefd [open SCTP.tr w] 
$ns trace-all $tracefd 
set namtracefd [open SCTP.nam w] 
$ns namtrace-all $namtracefd 
proc finish {} {                                  
  global ns tracefd namtracefd 
      $ns flush-trace 
      close $tracefd 
      close $namtracefd 
      exec nam SCTP_1．nam & 
      exit 0 
       } 
   set A1 [$ns node]                             
set A2 [$ns node] 
$ns duplex-link $A1 $A2 1Mb 25ms DropTail         
$ns duplex-link-op $A1 $A2 orient right 
set lrate1 "0.0100"                                
set loss_module [new ErrorModel]                    
$loss_module set rate_$lrate1 
$loss_module ranvar [new RandomVariable/Uniform] 
$ns lossmodel $loss_module $A1 $A2 
set SCTP0 [new Agent/SCTP]                       
$ns attach-agent $A1 $SCTP0 
$sctp0 set mtu_ 1500 
$sctp0 set dataChunkSize_ 1468 
set SCTP1 [new Agent/SCTP] $ns attach-agent $A2 $SCTP1 
$ns connect $SCTP0 $SCTP1 
set ftp [new Application/FTP]              
$ftp attach-agent $SCTP0 
$ns at 0.0 "$ftp start" 
$ns at 50.0 "finish" 
$ns run 
