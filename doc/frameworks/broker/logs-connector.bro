@load ./testlog

const broker_port: port = 9999/tcp &redef;
redef exit_only_after_terminate = T;
redef BrokerComm::endpoint_name = "connector";
redef Log::enable_local_logging = F;
redef Log::enable_remote_logging = F;
global n = 0;

event bro_init()
	{
	BrokerComm::enable();
	BrokerComm::enable_remote_logs(Test::LOG);
	BrokerComm::connect("127.0.0.1", broker_port, 1sec);
	}

event do_write()
	{
	if ( n == 6 )
		return;

	Log::write(Test::LOG, [$msg = "ping", $num = n]);
	++n;
	event do_write();
	}

event BrokerComm::outgoing_connection_established(peer_address: string,
                                            peer_port: port,
                                            peer_name: string)
	{
	print "BrokerComm::outgoing_connection_established",
	      peer_address, peer_port, peer_name;
	event do_write();
	}

event BrokerComm::outgoing_connection_broken(peer_address: string,
                                       peer_port: port)
	{
	terminate();
	}
