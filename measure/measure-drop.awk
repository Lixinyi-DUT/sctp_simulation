BEGIN{
	fsDrops=0;
	numFs=0;
}
{
	action=$1;
	time=$2;
	node_1=$3;
	node_2=$4;
	src=$5;
	flow_id=$8;
	node_1_address=$9;
	node_2_address=$10;
	seq_no=$11;
	packet_id=$12;
    if(node_1==0 && node_2==1 && action="+")
    	numFs++;
    if(action == "d")
    	fsDrops++;
}
END{
	printf("number of packet sent:%d lost:%d\n",numFs,fsDrops);
	printf("the loss rate of packet is:%f \n",fsDrops/numFs)
}