setwd("C:\\Users\\_lxy\\Desktop\\cygwin\\sctp_simulation")
library(ggplot2)
single_link_throughput_1_2_0<-read.table("out1_0")
time_1<-single_link_throughput_1_2_0$V1
data_1<-single_link_throughput_1_2_0$V2
g1<-ggplot(data=NULL,aes(x=time_1,y=data_1))
graph_1_2_0<-g1+geom_point(color="darkred",alpha=0.1)+labs(title="结点1-结点0的平均吞吐量变化",x="time(s)",y="throughput(kb/s)")

single_link_throughput_0_2_1<-read.table("out0_1")
time_2<-single_link_throughput_0_2_1$V1
data_2<-single_link_throughput_0_2_1$V2
g2<-ggplot(data=NULL,aes(x=time_2,y=data_2))
graph_0_2_1<-g2+geom_point(color="darkblue",alpha=0.1,aes(color="blue"))+labs(title="结点0-结点1的平均吞吐量变化",x="time(s)",y="throughput(kb/s)")

direction<-"0-1"
data_all1<-data.frame(single_link_throughput_0_2_1,direction)
direction<-"1-0"
data_all2<-data.frame(single_link_throughput_1_2_0,direction)
data_all=rbind(data_all1,data_all2);
g3<-ggplot(data=data_all,aes(x=V1,y=V2))
graph_all<-g3+geom_point(aes(color=direction),alpha=0.1)+labs(title="平均吞吐量变化",x="time(s)",y="throughput(kb/s)")