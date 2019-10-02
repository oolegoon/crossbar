////////////////////////////////////////////////////////////////////////
//   Name File     : fsm_master_1.v
//   Autor         : Oleg Krivoruka
//   Company       : 
//
//   Description   : Test  
//   Start design  : 28.08.2019
//   Last revision :  
///////////////////////////////////////////////////////////////////////

`timescale 1ns / 10 ps


module fsm_master_1 (
					//входы
					clock,
					reset,
					req_m,
					cmd_m, // признак операции Мастера 1: 0 - чтение, 1 - запись
					addr_m, // адрес запроса от Мастера 1
					wdata_m, // данные на запись от Мастера 1
					ack_1s, // сигнал - подтрверждение операции от Слэйва 1
					ack_2s, // сигнал - подтрверждение операции от Слэйва 2
					rdata_1s, // данные, выдаваемые в Мастер 1
					rdata_2s, // данные, выдаваемые в Мастер 2
					// выходы
					cmd_1s,
					cmd_2s,
					req_1s, // запрос транзакции в Слэйв 1
					req_2s, // запрос транзакции от Слэйв 2
					addr_1s,
					addr_2s,
					wdata_1s,
					wdata_2s					
				   );

 parameter DATA_WIDTH = 32;  // сколько битов в параллельных шинах данных
 parameter ADDR_WIDTH = 4;  // сколько битов в параллельных шинах адреса
 
 input wire 				clock, reset, req_m, cmd_m, ack_1s, ack_2s;
 input wire [DATA_WIDTH-1:0] wdata_m, rdata_1s, rdata_2s;
 input wire [ADDR_WIDTH-1:0] addr_m;
 output reg 				req_1s, req_2s, cmd_1s, cmd_2s;
 output reg [DATA_WIDTH-1:0] wdata_1s, wdata_2s;
 output reg [ADDR_WIDTH-1:0] addr_1s, addr_2s;

 reg 						we_1s = 1'b0;
 reg 						we_2s = 1'b0;
 wire       				slave_num;
 wire 		[DATA_WIDTH-1:0] rdata_1s_reg, rdata_2s_reg;
 
 assign slave_num = addr_m[ADDR_WIDTH-1];

//****************************************************************
// 7-state Moore FSM
//****************************************************************

reg [3:0] pres_state, next_state;

parameter st0=4'd0, st1=4'd1, st2=4'd2, st3=4'd3, st4=4'd4, st5=4'd5, st6=4'd6, st7=4'd7, st8=4'd8;


//FSM register
always @(posedge clock or posedge reset)
begin: statereg
   if(reset)
      pres_state <= st0;
   else
      pres_state <= next_state;
  end // statereg

// FSM combinational block

always @(pres_state or req_m or slave_num or ack_1s or ack_2s or cmd_m)
begin: fsm
   case (pres_state)
      st0: begin
            if (req_m == 1'b0)
			next_state = st0;
			else
			case ({slave_num, cmd_m}) // если slave_num = 1, то читаем слэйв 2, если 0, то слэйв 1
            2'b00: next_state = st1; // read slave 1
            2'b01: next_state = st2; // write slave 1
            2'b10: next_state = st3; // read slave 2
            2'b11: next_state = st4; // write slave 2
            endcase         
           end

      st1: begin // read slave 1
            if (ack_1s == 1'b0)
			next_state = st1;
			else
			next_state = st5;
           end

      st2: begin // write slave 1
			if (ack_1s == 1'b0)
			next_state = st2;
			else
			next_state = st0;
           end     

      st3: begin // read slave 2
            if (ack_2s == 1'b0)
			next_state = st3;
			else
			next_state = st6;
           end

      st4: begin // write slave 2
            if (ack_2s == 1'b0)
			next_state = st4;
			else
			next_state = st0;
           end

      st5: begin // получение данных от slave 1, генерация строба записи данных
            next_state = st0;
           end

      st6: begin // получение данных от slave 2, генерация строба записи данных
            next_state = st0;
           end
 
     default: next_state = st0;

   endcase

end // fsm

 

// Moore output definition using pres_state only
always @(pres_state)
begin: outputs
   case(pres_state)
      st0: begin // исходное состояние ожидания запроса
			req_1s = 1'b0;
			req_2s = 1'b0;
			cmd_1s = 1'b0;
			cmd_2s = 1'b0;
			addr_1s = {ADDR_WIDTH{1'b0}};
			addr_2s = {ADDR_WIDTH{1'b0}};
			wdata_1s = {DATA_WIDTH{1'b0}};
			wdata_2s = {DATA_WIDTH{1'b0}};
			we_1s = 1'b0;
			we_2s = 1'b0;
           end                             
      st1: begin // read slave 1
            req_1s = 1'b1;
			req_2s = 1'b0;
			cmd_1s = 1'b0;
			cmd_2s = 1'b0;
			addr_1s = addr_m;
			addr_2s = {ADDR_WIDTH{1'b0}};
			wdata_1s = wdata_m;
			wdata_2s = {DATA_WIDTH{1'b0}};
			we_1s = 1'b0;
			we_2s = 1'b0;
           end
      st2: begin // write slave 1
            req_1s = 1'b1;
			req_2s = 1'b0;
			cmd_1s = 1'b1;
			cmd_2s = 1'b0;
			addr_1s = addr_m;
			addr_2s = {ADDR_WIDTH{1'b0}};
			wdata_1s = wdata_m;
			wdata_2s = {DATA_WIDTH{1'b0}};
			we_1s = 1'b0;
			we_2s = 1'b0;
           end
      st3: begin // read slave 2
			req_1s = 1'b0;
			req_2s = 1'b1;
			cmd_1s = 1'b0;
			cmd_2s = 1'b0;
			addr_1s = {ADDR_WIDTH{1'b0}};
			addr_2s = addr_m;
			wdata_1s = {DATA_WIDTH{1'b0}};
			wdata_2s = wdata_m;
			we_1s = 1'b0;
			we_2s = 1'b0;
           end
      st4: begin // write slave 1
            req_1s = 1'b0;
			req_2s = 1'b1;
			cmd_1s = 1'b0;
			cmd_2s = 1'b1;
			addr_1s = {ADDR_WIDTH{1'b0}};
			addr_2s = addr_m;
			wdata_1s = {DATA_WIDTH{1'b0}};
			wdata_2s = wdata_m;
			we_1s = 1'b0;
			we_2s = 1'b0;
           end
      st5: begin // запись данных из слэйв 1
            req_1s = 1'b0;
			req_2s = 1'b0;
			cmd_1s = 1'b0;
			cmd_2s = 1'b0;
			addr_1s = {ADDR_WIDTH{1'b0}};
			addr_2s = {ADDR_WIDTH{1'b0}};
			wdata_1s = {DATA_WIDTH{1'b0}};
			wdata_2s = {DATA_WIDTH{1'b0}};
			we_1s = 1'b1;
			we_2s = 1'b0;
           end
      st6: begin // запись данных из слэйв 2
            req_1s = 1'b0;
			req_2s = 1'b0;
			cmd_1s = 1'b0;
			cmd_2s = 1'b0;
			addr_1s = {ADDR_WIDTH{1'b0}};
			addr_2s = {ADDR_WIDTH{1'b0}};
			wdata_1s = {DATA_WIDTH{1'b0}};
			wdata_2s = {DATA_WIDTH{1'b0}};
			we_1s = 1'b0;
			we_2s = 1'b1;
           end
		   
     default: begin
			req_1s = 1'b0;
			req_2s = 1'b0;
			cmd_1s = 1'b0;
			cmd_2s = 1'b0;
			addr_1s = {ADDR_WIDTH{1'b0}};
			addr_2s = {ADDR_WIDTH{1'b0}};
			wdata_1s = {DATA_WIDTH{1'b0}};
			wdata_2s = {DATA_WIDTH{1'b0}};
			we_1s = 1'b0;
			we_2s = 1'b0;
              end
   endcase

end // outputs
// Moore


reg_ena #(DATA_WIDTH) data_1s_reg (.clock (clock), .reset (reset), .ena (we_1s), .data (rdata_1s), .out (rdata_1s_reg));
reg_ena #(DATA_WIDTH) data_2s_reg (.clock (clock), .reset (reset), .ena (we_2s), .data (rdata_2s), .out (rdata_2s_reg));


endmodule

