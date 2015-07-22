setwd("C:\\Users\\_lxy\\Desktop\\cygwin\\sctp_simulation")
library(ggplot2)
data_1_4<-read.table("output/cmt_1_4")
data_2_5<-read.table("output/cmt_2_5")
data_4_1<-read.table("output/cmt_4_1")
data_5_2<-read.table("output/cmt_5_2")

g<-ggplot(data=data_1_4,aes(x=V1,y=V2))
graph_1<-g+geom_point(color="darkblue",alpha=0.1)+labs(title="结点1-结点4平均吞吐量变化",x="simulation time(s)",y="throughput(kb/s)")

g<-ggplot(data=data_2_5,aes(x=V1,y=V2))
graph_2<-g+geom_point(color="darkred",alpha=0.1)+labs(title="结点2-结点5平均吞吐量变化",x="simulation time(s)",y="throughput(kb/s)")

g<-ggplot(data=data_4_1,aes(x=V1,y=V2))
graph_3<-g+geom_point(color="darkgreen",alpha=0.1)+labs(title="结点4-结点1平均吞吐量变化",x="simulation time(s)",y="throughput(kb/s)")

g<-ggplot(data=data_5_2,aes(x=V1,y=V2))
graph_4<-g+geom_point(color="purple",alpha=0.1)+labs(title="结点5-结点2平均吞吐量变化",x="simulation time(s)",y="throughput(kb/s)")

direction<-"1-4"
data_all<-data.frame(data_1_4,direction)
direction<-"2-5"
data_all<-rbind(data_all,data.frame(data_2_5,direction))
direction<-"4-1"
data_all<-rbind(data_all,data.frame(data_4_1,direction))
direction<-"5-2"
data_all<-rbind(data_all,data.frame(data_5_2,direction))
g<-ggplot(data=data_all,aes(x=V1,y=V2))
graph_all<-g+geom_point(aes(color=direction),alpha=0.1)+labs(title="Average throughput during simulation",x="simulation time(s)",y="throughput(kb/s)")
graph_sub<-g+geom_point(aes(color=direction),alpha=0.1,size=0.5)+facet_wrap(~direction,scales = "free")+labs(title="Average throughput during simulation",x="simulation time(s)",y="throughput(kb/s)")+theme(legend.position="none")