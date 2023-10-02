module LCD_CTRL(clk, reset, cmd, cmd_valid, IROM_Q, IROM_rd, IROM_A, IRAM_valid, IRAM_D, IRAM_A, busy, done);
input clk;
input reset;
input [3:0] cmd;
input cmd_valid;
input [7:0] IROM_Q;
output IROM_rd;
output reg [5:0] IROM_A;
output IRAM_valid;
output [7:0] IRAM_D;
output [5:0] IRAM_A;
output reg busy;
output reg done;

// ----------------------------------------------------
// cao 
// ----------------------------------------------------

//parameter S_IDLE  = 3'b000;
parameter S_IMAGE = 3'b001
parameter S_INPUT = 3'b011;
parameter S_INST  = 3'b010;
parameter S_WRITE = 3'b100;
parameter S_OUTPUT= 3'b101;
reg [1:0]c_state, n_state;

parameter Write    	  = 4'b0000;
parameter Shift_Up    = 4'b0001;
parameter Shift_Down  = 4'b0010;
parameter Shift_Left  = 4'b0011;
parameter Shift_Right = 4'b0100;
parameter Max 		  = 4'b0101;
parameter Min 		  = 4'b0110;
parameter Average 	  = 4'b0111;
parameter Counterclockwise_Rotation = 4'b1000;
parameter Clockwise_Rotation 	    = 4'b1001;
parameter Mirror_X 	  = 4'b1010;
parameter Mirror_Y 	  = 4'b1011;

//========================================
//	wire  reg
//========================================
reg [3:0] cmd_r;

reg [5:0] cnt_addr;
reg [2:0] op_x, op_y;
reg [2:0] op_x_w, op_y_w;
reg next;
wire [5:0] temp_INA;
reg  [5:0] temp_minus;

//========================================
// ----------------------------------------------------
// cao 
// ----------------------------------------------------
//========================================
//	FSM
//========================================
always@(posedge clk, posedge reset)begin
	if(reset)
		c_state <= S_IMAGE;
	else
		c_state <= n_state;
end

always@(*)begin
	case(c_state)
	S_IMAGE: if(cnt_addr == 6'd63) n_state = S_INPUT; 
			 else  		   		   n_state = S_IMAGE;
	S_INPUT: if(cmd_valid)begin
				if(cmd == Write)
					n_state = S_OUTPUT; 
				else					
					n_state = S_INST;
			 end
			 else		   n_state = S_INPUT; 
	S_INST:  if(cmd_r > Shift_Right)
				n_state = S_WRITE;
			 else
				n_state = S_INPUT;
	S_WRITE: n_state = S_INPUT;
	S_OUTPUT:if(cnt_addr == 6'd63) n_state = S_INPUT; 
			 else  		   		   n_state = S_OUTPUT;
	default: n_state = S_IMAGE;
	endcase
end


always @(*) begin
    case (cnt_addr) 
        2'd0 : temp_minus = 4'd9;
        2'd1 : temp_minus = 4'd8;
        2'd2 : temp_minus = 4'd1;
        2'd3 : temp_minus = 4'd0;
    endcase
end

//========================================
//	INPUT
//========================================
always@(posedge clk, posedge reset)begin
	if(reset) begin
		cmd_r <= 4'd0;
	end else begin
		if(c_state == S_IDLE && cmd_valid)
			cmd_r <= cmd;
	end
end

always@(posedge clk, posedge reset)begin
	if(reset) begin
		op_x <= 3'd4;
	end else begin
		if(c_state == S_INST)
			op_x <= op_x_w;
	end
end

always@(posedge clk, posedge reset)begin
	if(reset) begin
		op_y <= 3'd4;
	end else begin
		if(c_state == S_INST)
			op_y <= op_y_w;
	end
end

always@(*)begin
	case(cmd_r)
	Shift_Up:begin
        op_y_w = (op_y == 3'd1) ? op_y : op_y - 3'd1;
	end
	Shift_Down:begin
	    op_y_w = (op_y == 3'd7) ? op_y : op_y + 3'd1;
	end
	default: op_y_w = op_y;
	endcase
end

always@(*)begin
	case(cmd_r)
	Shift_Left:begin
        op_x_w = (op_x == 3'd1) ? op_x : op_x - 3'd1;
	end
	Shift_Right:begin
	    op_x_w = (op_ == 3'd7) ? op_x : op_x + 3'd1;
	end
	default: op_x_w = op_x;
	endcase
end





always@(posedge clk, posedge reset)begin
	if(reset) begin
		cnt_addr<= 6'd0;
	end else begin
		if(c_state == S_IMAGE || c_state == S_OUTPUT) begin
			cnt_addr <= cnt_addr + 6'd1;
		end	
		else begin
			cnt_addr <= 6'd0;
		end
	end
end


//========================================
//	output
//========================================
always@(posedge clk, posedge reset)begin
	if(reset) begin
		busy <= 1'd1;
	end else begin
		if(cnt_addr == 6'd63)begin
			busy <= 1'd0;
		end else if(cmd_valid)
			busy <= 1'b1;
		else if(n_state == S_INPUT)begin
			busy <= 1'b0;
		end
	end
end

always@(posedge clk, posedge reset)begin
	if(reset) begin
		done <= 1'd0;
	end else begin
		if(c_state == S_OUTPUT && cnt_addr == 6'd63)
			done <= 1'd1;
		else
			done <= 1'b0;
	end
end
//========================================
//	READ ROM
//========================================

assign IROM_rd = (c_state == S_IMAGE)? 1'b1: 1'b0;
assign temp_INA = {op_y,op_x};

always@(*) begin
	if(c_state == S_IMAGE)
		IROM_A = 6'd63 - cnt_addr;
	else
		IROM_A = 6'd0;
end

//========================================
//	Write RAM
//========================================
assign IRAM_valid = (c_state == S_OUTPUT )? 1'b1: 1'b0;

always @(posedge clk or posedge reset) begin
    if (reset) cnt_write <= 2'd0;
    else cnt_write <= (c_state == S_WRITE) ? cnt_write + 2'd1 : 2'd0;
end


always@(*) begin
	if(c_state == S_OUTPUT)
		IRAM_D = IMAGE[0];
	else
		IRAM_D = 6'd0;
end

always@(*) begin
	if(c_state == S_OUTPUT)
		IRAM_A = cnt_addr;
	else
		IRAM_D = 6'd0;
end

endmodule



