set ns [new Simulator]                              
set tracefd [open TCP.tr w] 
$ns trace-all $tracefd 
set namtracefd [open TCP.nam w] 
$ns namtrace-all $namtracefd 
proc finish {} {                                  
  global ns tracefd namtracefd 
      $ns flush-trace 
      close $tracefd 
      close $namtracefd 
      exec nam TCP.nam & 
      exit 0 
       } 
set A1 [$ns node]                             
set A2 [$ns node] 
$ns duplex-link $A1 $A2 1Mb 25ms DropTail         
$ns duplex-link-op $A1 $A2 orient right 
set lrate1 "0.1"                                
set loss_module [new ErrorModel]                    
$loss_module set rate 0.1
$loss_module ranvar [new RandomVariable/Uniform] 
$ns lossmodel $loss_module $A1 $A2 
set tcp0 [new Agent/TCP]                       
$ns attach-agent $A1 $tcp0
$tcp0 set mtu_ 1500 
$tcp0 set dataChunkSize_ 1468 
set tcp1 [new Agent/TCP] 
$ns attach-agent $A2 $tcp1
$ns connect $tcp0 $tcp1
set ftp [new Application/FTP]              
$ftp attach-agent $tcp0 
$ns at 0.0 "$ftp start" 
$ns at 50.0 "finish" 
$ns run 
