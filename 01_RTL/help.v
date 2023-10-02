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
