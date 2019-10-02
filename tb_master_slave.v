////////////////////////////////////////////////////////////////////////
//   Name File     : tb_master_slave.v
//   Autor         : Oleg Krivoruka
//   Company       : 
//
//   Description   : Test  
//   Start design  : 29.08.2019
//   Last revision :  
///////////////////////////////////////////////////////////////////////

`timescale 1ns / 10 ps

module tb_master_slave;

parameter CLK_HALF_PERIOD = 5;
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 16;

reg 				 clock, reset, req_1m, cmd_1m, req_2m, cmd_2m;
reg [DATA_WIDTH-1:0]  wdata_1m, wdata_2m;
reg [ADDR_WIDTH-1:0]  addr_1m, addr_2m;

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
					
					
					
					
initial // Clock generator
 
	begin
    clock = 0;
    # CLK_HALF_PERIOD forever # CLK_HALF_PERIOD clock = !clock;
  end
  
initial	// Test stimulus
	begin
	reset = 0;
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 0;
	wdata_1m = 0;
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 0;
	wdata_2m = 0;
	
	#5  reset   = 1;
	#20 reset   = 0;

//запись данных из 1-го мастера в 1-ый слэйва
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 1;
	addr_1m = 16'h0001;
	wdata_1m = 32'h12345678;
	end
	wait (ack_1m_1s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	#10
// чтение данный из 1-го слэйва в 1-ый мастер
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 0;
	addr_1m = 16'h0001;
	wdata_1m = 32'h12345678;
	end
	wait (ack_1m_1s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end

// запись данных из 2-го мастера в 1-ый слэйва
	#10
	@ (posedge clock)
	#0
	begin
	req_2m = 1;
	cmd_2m = 1;
	addr_2m = 16'h0002;
	wdata_2m = 32'ha5bd;
	end
	wait (ack_2m_1s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	#10
// чтение данных из 2-го мастера в 1-ый слэйв
	@ (posedge clock)
	#0
	begin
	req_2m = 1;
	cmd_2m = 0;
	addr_2m = 16'h0002;
	wdata_2m = 32'h12345678;
	end
	wait (ack_2m_1s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end

//одновременное обращение на запись в 1-ый слэйв от 1-го и 2-го мастеров
  #10
  @ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 1;
	addr_1m = 16'h0003;
	wdata_1m = 32'hedb3;
	req_2m = 1;
	cmd_2m = 1;
	addr_2m = 16'h0004;
	wdata_2m = 32'hcea3;
	end
	wait (ack_1m_1s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	wait (ack_2m_1s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	#10
//одновременное обращение на чтение данных  из 1-го слэйва в 1-ый и 2-ой мастеры
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 0;
	addr_1m = 16'h0003;
	wdata_1m = 32'hedb3;
	req_2m = 1;
	cmd_2m = 0;
	addr_2m = 16'h0004;
	wdata_2m = 32'hcea3;
	end
	wait (ack_1m_1s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	wait (ack_2m_1s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	#10
//обращение на запись в 1-ый слэйв сначала из 2-го мастера, потом из 1-го мастера
	@ (posedge clock)
	#0
	begin
	req_2m = 1;
	cmd_2m = 1;
	addr_2m = 16'h0005;
	wdata_2m = 32'heacd;
	#10
	req_1m = 1;
	cmd_1m = 1;
	addr_1m = 16'h0006;
	wdata_1m = 32'he453;
	end
	wait (ack_2m_1s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	wait (ack_1m_1s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	#10
//обращение на чтение в 1-ый слэйв сначала из 1-го мастера, потом из 2-го мастера
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 0;
	addr_1m = 16'h0006;
	wdata_1m = 32'hedb3;
	#10
	req_2m = 1;
	cmd_2m = 0;
	addr_2m = 16'h0005;
	wdata_2m = 32'hcea3;
	end
	wait (ack_1m_1s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	wait (ack_2m_1s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	
	#100
	
// прогон второго слэйва способом аналогичным верхнему, изменения только в четвертой тетраде адреса
// старший бит тетрады стал 1, то есть обращение идёт во второй слэйв
//запись данных из 1-го мастера во 2-ой слэйв
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 1;
	addr_1m = 16'h8001;
	wdata_1m = 32'h12345678;
	end
	wait (ack_1m_2s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	
	#10
// чтение данный из 2-го слэйва в 1-ый мастер
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 0;
	addr_1m = 16'h8001;
	wdata_1m = 32'h12345678;
	end
	wait (ack_1m_2s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	
	#10
// запись данных из 2-го мастера во 2-ой слэйв
	@ (posedge clock)
	#0
	begin
	req_2m = 1;
	cmd_2m = 1;
	addr_2m = 16'h8002;
	wdata_2m = 32'ha5bd;
	end
	wait (ack_2m_2s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	
	#10
// чтение данных из 2-го слэйва во 2-ой мастер
	@ (posedge clock)
	#0
	begin
	req_2m = 1;
	cmd_2m = 0;
	addr_2m = 16'h8002;
	wdata_2m = 32'h12345678;
	end
	wait (ack_2m_2s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end

//одновременное обращение на запись данных  во 2-ой слэйв из 1-го и 2-го мастеров 
	#10
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 1;
	addr_1m = 16'h8003;
	wdata_1m = 32'hedb3;
	req_2m = 1;
	cmd_2m = 1;
	addr_2m = 16'h8004;
	wdata_2m = 32'hcea3;
	end
	wait (ack_1m_2s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	wait (ack_2m_2s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	
	#10
//одновременное обращение на чтение данных  из 2-го слэйва в 1-ый и 2-ой мастеры
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 0;
	addr_1m = 16'h8003;
	wdata_1m = 32'hedb3;
	req_2m = 1;
	cmd_2m = 0;
	addr_2m = 16'h8004;
	wdata_2m = 32'hcea3;
	end
	wait (ack_1m_2s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	wait (ack_2m_2s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	
	#10
//обращение на запись во 2-ой слэйв сначала из 2-го мастера, потом из 1-го мастера
	@ (posedge clock)
	#0
	begin
	req_2m = 1;
	cmd_2m = 1;
	addr_2m = 16'h8005;
	wdata_2m = 32'heacd;
	#10
	req_1m = 1;
	cmd_1m = 1;
	addr_1m = 16'h8006;
	wdata_1m = 32'he453;
	end
	wait (ack_2m_2s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end
	wait (ack_1m_2s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	
	#10
//обращение на чтение во 2-ой слэйв сначала из 1-го мастера, потом из 2-го мастера
	@ (posedge clock)
	#0
	begin
	req_1m = 1;
	cmd_1m = 0;
	addr_1m = 16'h8006;
	wdata_1m = 32'hedb3;
	#10
	req_2m = 1;
	cmd_2m = 0;
	addr_2m = 16'h8005;
	wdata_2m = 32'hcea3;
	end
	wait (ack_1m_2s);
	@ (posedge clock)
	#0
	begin
	req_1m = 0;
	cmd_1m = 0;
	addr_1m = 16'h0;
	wdata_1m = 32'h0;
	end
	wait (ack_2m_2s);
	@ (posedge clock)
	#0
	begin
	req_2m = 0;
	cmd_2m = 0;
	addr_2m = 16'h0;
	wdata_2m = 32'h0;
	end


#100
$stop;

end // initial


   
endmodule

