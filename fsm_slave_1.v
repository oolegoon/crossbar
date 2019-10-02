////////////////////////////////////////////////////////////////////////
//   Name File     : fsm_slave_1.v
//   Autor         : Oleg Krivoruka
//   Company       : 
//
//   Description   : Test  
//   Start design  : 29.08.2019
//   Last revision :  
///////////////////////////////////////////////////////////////////////

`timescale 1ns / 10 ps

//with ram
module fsm_slave_1 (
					clock,
					reset,
					req_1m, // запрос транзакции от Мастера 1
					req_2m, // запрос транзакции от Мастера 2
					addr_1m, // адрес запроса от Мастера 1
					addr_2m, // адрес запроса от Мастера 2
					wdata_1m, // данные на запись от Мастера 1
					wdata_2m, // данные на запись от Мастера 2
					cmd_1m, // признак операции Мастера 1: 0 - чтение, 1 - запись
					cmd_2m, // признак операции Мастера 2: 0 - чтение, 1 - запись
					ack_1m, // сигнал - подтрверждение операции Мастеру 1
					ack_2m, // сигнал - подтрверждение операции Мастеру 2
					rdata_1m, // данные, выдаваемые в Мастер 1
					rdata_2m // данные, выдаваемые в Мастер 2
				  );

parameter DATA_WIDTH = 32;  // сколько битов в параллельных шинах
parameter ADDR_WIDTH = 4;  // сколько битов в параллельных шинах
 
input wire 					clock, reset, req_1m, req_2m, cmd_1m, cmd_2m;
input wire [ADDR_WIDTH-1:0] addr_1m, addr_2m;
input wire [DATA_WIDTH-1:0] wdata_1m, wdata_2m;
output reg 					ack_1m, ack_2m;
output reg [DATA_WIDTH-1:0] rdata_1m, rdata_2m;
wire 	   [DATA_WIDTH-1:0] ram_data;
wire 						cmd, scmd;
wire [ADDR_WIDTH-2:0] addr, saddr, addr_reg_ram;
wire [DATA_WIDTH-1:0] wdata, sdata;
 
reg we = 1'b0;
reg cm = 1'b0; //выбор линии для записи данных
reg we_ram = 1'b0;

assign cmd = cm ? cmd_1m : cmd_2m;
assign addr = cm ? addr_1m [ADDR_WIDTH-2:0] :  addr_2m [ADDR_WIDTH-2:0];
assign wdata = cm ? wdata_1m : wdata_2m;

//****************************************************************
// 9-state Moore FSM
//****************************************************************

reg [4:0] pres_state, next_state;

parameter st0=5'd0, st1=5'd1, st2=5'd2, st3=5'd3, st4=5'd4, st5=5'd5, st6=5'd6, st7=5'd7, st8=5'd8, st9=5'd9, st10=5'd10;


//FSM register
always @(posedge clock or posedge reset)
begin: statereg
	if(reset)
		pres_state <= st0;
	else
		pres_state <= next_state;
  end // statereg

// FSM combinational block

always @(pres_state or req_1m or req_2m or cmd_1m or cmd_2m)
begin: fsm
	case (pres_state)
		st0:
		begin
			case ({req_1m, req_2m, cmd_1m, cmd_2m})
			4'b0000: next_state = st0; 
			4'b1000: next_state = st1;
			4'b1010: next_state = st2;
			4'b0100: next_state = st3;
			4'b0101: next_state = st4;
			4'b1100: next_state = st1;
			4'b1101: next_state = st1;
			4'b1110: next_state = st2;
			4'b1111: next_state = st2;
			default: next_state = st0;
			endcase
		end

		st1:
			begin //чтение данных в Мастер 1, строб записи данных с линий
			if (req_1m == 1'b1)
			next_state = st5;
			else
			next_state = st0;
			end

		st2:
			begin //запись данных из Мастера 1, строб записи данных с линий
			if (req_1m == 1'b1)
			next_state = st6;
			else
			next_state = st0;
			end

		st3:
			begin //чтение данных в Мастер 2, строб записи данных с линий
			if (req_2m == 1'b1)
			next_state = st7;
			else
			next_state = st0;
			end

		st4:
			begin //запись данных из Мастера 2, строб записи данных с линий
			if (req_2m == 1'b1)
			next_state = st8;
			else
			next_state = st0;
			end
			
		st5: //чтение мастер 1, выдача сигнала подтверждения
			begin
			next_state = st9;
			end

		st6: begin //запись мастер 1, запись данных в память
			case ({req_2m, cmd_2m})
			2'b10: next_state = st3;
			2'b11: next_state = st4;
			default: next_state = st0;
			endcase
			end
			
		st7: //чтение мастер 2, выдача сигнала подтверждения
			begin
			next_state = st10;
			end
			
		st8: //запись мастер 2, запись данных в память
			begin
			case ({req_1m, cmd_1m})
			2'b10: next_state = st1;
			2'b11: next_state = st2;
			default: next_state = st0;
			endcase
			end
			
		st9: //чтение мастер 1, выдача данных в мастер 1
			begin
			case ({req_2m, cmd_2m})
			2'b10: next_state = st3;
			2'b11: next_state = st4;
			default: next_state = st0;
			endcase
			end
			
		st10: //чтение мастер 2, выдача данных в мастер 2
			begin
			case ({req_1m, cmd_1m})
			2'b10: next_state = st1;
			2'b11: next_state = st2;
			default: next_state = st0;
			endcase
			end
				
		default: next_state = st0;

   endcase

end // fsm

 

// Moore output definition using pres_state only
always @(pres_state)
begin: outputs
	case(pres_state)
		st0:
			begin // исходное состояние ожидания запроса
			//строб записи данных с линий
			we = 1'b0;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
		st1:
			begin // чтение данных в Мастер 1
			//строб записи данных с линий
			we = 1'b1;
			cm = 1'b1;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
		st2:
			begin // запись данных из Мастера 1
			//строб записи данных с линий
			we = 1'b1;
			cm = 1'b1;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
		st3:
			begin // чтение данных в Мастер 2
			//строб записи данных с линий
			we = 1'b1;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
		st4: // запись данных из Мастера 2
			begin
			//строб записи данных с линий
			we = 1'b1;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
		st5:
			begin
			//строб записи данных с линий
			we = 1'b0;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b1;
			//rdata_1m = ram_data;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
		st6:
			begin
			//строб записи данных с линий
			we = 1'b0;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b1;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			//rdata_2m = ram_data;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b1;
			end
		st7:
			begin
			//строб записи данных с линий
			we = 1'b0;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b1;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
		st8:
			begin
			//строб записи данных с линий
			we = 1'b0;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b1;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b1;
			end
		st9:
			begin
			//строб записи данных с линий
			we = 1'b0;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = ram_data;
			ack_2m = 1'b0;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
		st10:
			begin
			//строб записи данных с линий
			we = 1'b0;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			rdata_2m = ram_data;
			//строб записи в память
			we_ram = 1'b0;
			end
		default:
			begin
			//строб записи данных с линий
			we = 1'b0;
			cm = 1'b0;
			//подтверждение и данные в Мастеры
			ack_1m = 1'b0;
			rdata_1m = {DATA_WIDTH{1'b0}};
			ack_2m = 1'b0;
			rdata_2m = {DATA_WIDTH{1'b0}};
			//строб записи в память
			we_ram = 1'b0;
			end
	endcase

end // outputs
// Moore
// cm = 1 -> M1, cm = 0 -> M2


//фиксируем данные с линий cmd, addr, wdata от Мастеров
reg_ena #(1) cmd_reg (.clock (clock), .reset (reset), .ena (we), .data (cmd), .out (scmd));
reg_ena #(ADDR_WIDTH-1) addr_reg (.clock (clock), .reset (reset), .ena (we), .data (addr), .out (saddr));
reg_ena #(DATA_WIDTH) wdata_reg (.clock (clock), .reset (reset), .ena (we), .data (wdata), .out (sdata));


single_port_ram #(DATA_WIDTH, ADDR_WIDTH-1) slave_1_ram
						(
						.clock (clock),
						.we (we_ram),
						.addr (saddr),
						.data (sdata),
						.q (ram_data),
						.addr_reg (addr_reg_ram)
						);
						


endmodule



