////////////////////////////////////////////////////////////////////////
//   Name File     : top_level_crossbar.v
//   Autor         : Oleg Krivoruka
//   Company       : 
//
//   Description   : Test  
//   Start design  : 30.09.2019
//   Last revision :  
///////////////////////////////////////////////////////////////////////

`timescale 1ns / 10 ps

module top_level_crossbar (clock, reset, req_1m, cmd_1m, req_2m, cmd_2m, wdata_1m, wdata_2m, addr_1m, addr_2m);

parameter CLK_HALF_PERIOD = 5;
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 16;

input wire 				 clock, reset, req_1m, cmd_1m, req_2m, cmd_2m;
input wire [DATA_WIDTH-1:0]  wdata_1m, wdata_2m;
input wire [ADDR_WIDTH-1:0]  addr_1m, addr_2m;

// линии соединения автоматов
wire 					req_1m_1s, ack_1m_1s, cmd_1m_1s,
						req_2m_1s, ack_2m_1s, cmd_2m_1s,
						req_1m_2s, ack_1m_2s, cmd_1m_2s,
						req_2m_2s, ack_2m_2s, cmd_2m_2s;
						
wire [DATA_WIDTH-1:0]   wdata_1m_1s, rdata_1m_1s,
						wdata_2m_1s, rdata_2m_1s,
						wdata_1m_2s, rdata_1m_2s,
						wdata_2m_2s, rdata_2m_2s;
						
wire [ADDR_WIDTH-1:0]   addr_1m_1s, addr_2m_1s, addr_1m_2s, addr_2m_2s;


 fsm_master_1 #(DATA_WIDTH, ADDR_WIDTH) dut1master
					(
					.clock (clock),
					.reset (reset),
					.req_m (req_1m),
					.cmd_m (cmd_1m), // признак операции Мастера 1: 0 - чтение, 1 - запись
					.addr_m (addr_1m), // адрес запроса от Мастера 1
					.wdata_m (wdata_1m), // данные на запись от Мастера 1
					.ack_1s (ack_1m_1s), // сигнал - подтрверждение операции от Слэйва 1
					.ack_2s (ack_1m_2s), // сигнал - подтрверждение операции от Слэйва 2
					.rdata_1s (rdata_1m_1s) , // данные, выдаваемые в Мастер 1
					.rdata_2s (rdata_1m_2s), // данные, выдаваемые в Мастер 2
					// выходы
					.cmd_1s (cmd_1m_1s), 
					.cmd_2s (cmd_1m_2s),
					.req_1s (req_1m_1s), // запрос транзакции в Слэйв 1
					.req_2s (req_1m_2s), // запрос транзакции от Слэйв 2
					.addr_1s (addr_1m_1s),
					.addr_2s (addr_1m_2s),
					.wdata_1s (wdata_1m_1s),
					.wdata_2s (wdata_1m_2s)
					);

 fsm_master_1 #(DATA_WIDTH, ADDR_WIDTH) dut2master
					(
					.clock (clock),
					.reset (reset),
					.req_m (req_2m),
					.cmd_m (cmd_2m), // признак операции Мастера 1: 0 - чтение, 1 - запись
					.addr_m (addr_2m), // адрес запроса от Мастера 1
					.wdata_m (wdata_2m), // данные на запись от Мастера 1
					.ack_1s (ack_2m_1s), // сигнал - подтрверждение операции от Слэйва 1
					.ack_2s (ack_2m_2s), // сигнал - подтрверждение операции от Слэйва 2
					.rdata_1s (rdata_2m_1s) , // данные, выдаваемые в Мастер 1
					.rdata_2s (rdata_2m_2s), // данные, выдаваемые в Мастер 2
					// выходы
					.cmd_1s (cmd_2m_1s), 
					.cmd_2s (cmd_2m_2s),
					.req_1s (req_2m_1s), // запрос транзакции в Слэйв 1
					.req_2s (req_2m_2s), // запрос транзакции от Слэйв 2
					.addr_1s (addr_2m_1s),
					.addr_2s (addr_2m_2s),
					.wdata_1s (wdata_2m_1s),
					.wdata_2s (wdata_2m_2s)
					);


 
 fsm_slave_1 #(DATA_WIDTH, ADDR_WIDTH) dut1slave
					(
					.clock (clock),
					.reset (reset),
					.req_1m (req_1m_1s),
					.req_2m (req_2m_1s),
					.addr_1m (addr_1m_1s),
					.addr_2m (addr_2m_1s),
					.wdata_1m (wdata_1m_1s),
					.wdata_2m (wdata_2m_1s),
					.cmd_1m (cmd_1m_1s), 
					.cmd_2m (cmd_2m_1s),
					.ack_1m (ack_1m_1s),
					.ack_2m (ack_2m_1s),
					.rdata_1m (rdata_1m_1s),
					.rdata_2m (rdata_2m_1s)
					);	


fsm_slave_1 #(DATA_WIDTH, ADDR_WIDTH) dut2slave
					(
					.clock (clock),
					.reset (reset),
					.req_1m (req_1m_2s),
					.req_2m (req_2m_2s),
					.addr_1m (addr_1m_2s),
					.addr_2m (addr_2m_2s),
					.wdata_1m (wdata_1m_2s),
					.wdata_2m (wdata_2m_2s),
					.cmd_1m (cmd_1m_2s), 
					.cmd_2m (cmd_2m_2s),
					.ack_1m (ack_1m_2s),
					.ack_2m (ack_2m_2s),
					.rdata_1m (rdata_1m_2s),
					.rdata_2m (rdata_2m_2s)
					);					
					
					
   
endmodule

