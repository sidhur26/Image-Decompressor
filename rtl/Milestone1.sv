`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module Milestone1 (
   input  logic            Clock,
   input  logic            resetn,
   input  logic [15:0]     SRAM_read_data,
	input logic             M1_start,
	

	output logic [17:0]   SRAM_address,
	output logic [15:0]	 SRAM_write_data,
	output logic		    SRAM_we_n,
	output logic          M1_end
	

);
M1_state_type M1_state;

parameter y_address = 18'd0;
parameter u_address = 18'd38400;
parameter v_address = 18'd57600;
parameter rgb_address = 18'd146944;

parameter signed a00 = 32'h129FC; // 76284
parameter signed a02 = 32'h19893; //104595
parameter signed a11 = 32'hFFFF9BE8; // -25624
parameter signed a12 = 32'hFFFF2FDF; // -53281
parameter signed a21 = 32'h2049B; //132251

parameter signed j_five = 32'h15; //21
parameter signed j_three = 32'hFFFFFFCC; //-52
parameter signed j_one = 32'h9F; //159


logic case_flag;
logic lead_out;


logic [17:0] y_counter, u_counter, v_counter, rgb_counter, pixel_counter, row_counter;

logic [15:0] y_buf, u_buf, v_buf;

logic [31:0] u_prime_odd, v_prime_odd;
logic [7:0] u_prime_even, v_prime_even;

logic [7:0] u_minus_five, u_minus_three, u_minus_one, u_plus_one, u_plus_three, u_plus_five; 
logic [7:0] v_minus_five, v_minus_three, v_minus_one, v_plus_one, v_plus_three, v_plus_five; 

logic [31:0] r_acc_even, g_acc_even, b_acc_even;
logic [31:0] r_acc_odd, g_acc_odd, b_acc_odd;

logic [7:0] r_clip_even, g_clip_even, b_clip_even;
logic [7:0] r_clip_odd, g_clip_odd, b_clip_odd;


logic signed [31:0] op1, op2, op3, op4,op5,op6,op7,op8, result1, result2, result3, result4;
logic signed [63:0] result_long1, result_long2, result_long3, result_long4;


assign result_long1 = $signed(op1)*$signed(op2);
assign result_long2 = $signed(op3)*$signed(op4);
assign result_long3 = $signed(op5)*$signed(op6);
assign result_long4 = $signed(op7)*$signed(op8);

assign result1 = result_long1[31:0];
assign result2 = result_long2[31:0];
assign result3 = result_long3[31:0];
assign result4 = result_long4[31:0];





always_comb begin //clipping function

//assign r_clip_even = (r_acc_even[31] == 1'b1) ? 8'd0 : ((r_acc_even[31:24] >= 8'd1) ? 8'd255 : r_acc_even[23:16]);
//assign g_clip_even = (g_acc_even[31] == 1'b1) ? 8'd0 : ((g_acc_even[31:24] >= 8'd1) ? 8'd255 : g_acc_even[23:16]);
//assign b_clip_even = (b_acc_even[31] == 1'b1) ? 8'd0 : ((b_acc_even[31:24] >= 8'd1) ? 8'd255 : b_acc_even[23:16]);
//
//assign r_clip_odd = (r_acc_odd[31] == 1'b1) ? 8'd0 : ((r_acc_odd[31:24] >= 8'd1) ? 8'd255 : r_acc_odd[23:16]);
//assign g_clip_odd = (g_acc_odd[31] == 1'b1) ? 8'd0 : ((g_acc_odd[31:24] >= 8'd1) ? 8'd255 : g_acc_odd[23:16]);
//assign b_clip_odd = (b_acc_odd[31] == 1'b1) ? 8'd0 : ((b_acc_odd[31:24] >= 8'd1) ? 8'd255 : b_acc_odd[23:16]);

	if (r_acc_even[31] == 1'b1) begin //negative number, force to 0
		r_clip_even <= 8'd0;
		
		end else if (r_acc_even[31:24] >= 8'd1) begin //number > 255, force to 255
			r_clip_even <= 8'd255;
			
			end else begin
			r_clip_even <= r_acc_even[23:16]; 
			
	end

	if (g_acc_even[31] == 1'b1) begin 
		g_clip_even <= 8'd0;
		
		end else if (g_acc_even[31:24] >= 8'd1) begin
			g_clip_even <= 8'd255;
			
			end else begin
			g_clip_even <= g_acc_even[23:16];
			
	end

	if (b_acc_even[31] == 1'b1) begin
		b_clip_even <= 8'd0;
		
		end else if (b_acc_even[31:24] >= 8'd1) begin
			b_clip_even <= 8'd255;
			
			end else begin
			b_clip_even <= b_acc_even[23:16];
			
	end

	if (r_acc_odd[31] == 1'b1) begin //negative number, force to 0
		r_clip_odd <= 8'd0;
		
		end else if (r_acc_odd[31:24] >= 8'd1) begin//number > 255, force to 255
			r_clip_odd <= 8'd255;
			
			end else begin
			r_clip_odd <= r_acc_odd[23:16]; //why?
			
	end

	if (g_acc_odd[31] == 1'b1) begin 
		g_clip_odd <= 8'd0;
		
		end else if (g_acc_odd[31:24] >= 8'd1) begin
			g_clip_odd <= 8'd255;
			
			end else begin
			g_clip_odd <= g_acc_odd[23:16];
			
	end

	if (b_acc_odd[31] == 1'b1) begin
		b_clip_odd <= 8'd0;
		
		end else if (b_acc_odd[31:24] >= 8'd1) begin
			b_clip_odd <= 8'd255;
			
			end else begin
			b_clip_odd <= b_acc_odd[23:16];
			
	end

end



always @(posedge Clock or negedge resetn) begin
	if (~resetn) begin
	
		SRAM_address <= 18'd0;
		SRAM_write_data <= 18'd0;
		SRAM_we_n <= 1'b1;
		
		M1_end <= 1'b0;
		
		y_counter <= 18'd0;
		u_counter <= 18'd0;
		v_counter <= 18'd0;
		rgb_counter <= 18'd0;
		pixel_counter <= 18'd0;
		row_counter <= 18'd0;
		
		y_buf <= 16'd0;
		u_buf <= 16'd0;
		v_buf <= 16'd0;
		
		u_prime_odd <= 32'd0;
		v_prime_odd <= 32'd0;
		
		u_prime_even <= 8'd0;
		v_prime_even <= 8'd0;
		
		u_minus_five <= 8'd0; 
		u_minus_three <= 8'd0; 
		u_minus_one <= 8'd0; 
		u_plus_one <= 8'd0; 
		u_plus_three <= 8'd0; 
		u_plus_five <= 8'd0; 
		
		v_minus_five <= 8'd0; 
		v_minus_three <= 8'd0; 
		v_minus_one <= 8'd0; 
		v_plus_one <= 8'd0; 
		v_plus_three <= 8'd0; 
		v_plus_five <= 8'd0; 
		
		r_acc_even <= 32'd0;
		g_acc_even <= 32'd0; 
		b_acc_even <= 32'd0;
		
		r_acc_odd <= 32'd0;
		g_acc_odd <= 32'd0; 
		b_acc_odd <= 32'd0;
		
		case_flag <= 1'b0;
		lead_out <= 1'b0;
	
		
		

	end else begin

		case (M1_state)
		S_M1_IDLE: begin
		
			if (M1_start == 1'b1) begin
			
				SRAM_address <= y_address;
				
				SRAM_write_data <= 18'd0;
				SRAM_we_n <= 1'b1;
			
				y_counter <= 18'd1;
				u_counter <= 18'd0;
				v_counter <= 18'd0;
				rgb_counter <= 18'd0;
				pixel_counter <= 18'd0;
				row_counter <= 18'd0;
			
				y_buf <= 16'd0;
				u_buf <= 16'd0;
				v_buf <= 16'd0;
			
				u_prime_odd <= 32'd0;
				v_prime_odd <= 32'd0;
			
				u_prime_even <= 8'd0;
				v_prime_even <= 8'd0;
				
				u_minus_five <= 8'd0; 
				u_minus_three <= 8'd0; 
				u_minus_one <= 8'd0; 
				u_plus_one <= 8'd0; 
				u_plus_three <= 8'd0; 
				u_plus_five <= 8'd0; 
				
				v_minus_five <= 8'd0; 
				v_minus_three <= 8'd0; 
				v_minus_one <= 8'd0; 
				v_plus_one <= 8'd0; 
				v_plus_three <= 8'd0; 
				v_plus_five <= 8'd0; 
				
				r_acc_even <= 32'd0;
				g_acc_even <= 32'd0; 
				b_acc_even <= 32'd0;
				
				r_acc_odd <= 32'd0;
				g_acc_odd <= 32'd0; 
				b_acc_odd <= 32'd0;
				
				case_flag <= 1'b0;
				lead_out <= 1'b0;

				
				M1_end <= 1'b0;
			
				M1_state <= S_M1_LEAD_IN_0;
				
			end	
		
		
		end

		S_M1_LEAD_IN_0: begin
		
		SRAM_address <= u_address + u_counter;  //u0u1
		u_counter <= u_counter + 1'd1;

		
		M1_state <= S_M1_LEAD_IN_1;
		
		end
		
		S_M1_LEAD_IN_1: begin
		
			SRAM_address <= v_address + v_counter;  //v0v1
			v_counter <= v_counter + 1'd1;

			
			M1_state <= S_M1_LEAD_IN_2;
		
		end
		
		S_M1_LEAD_IN_2: begin
		
			SRAM_address <= u_address + u_counter; //u2u3
			u_counter <= u_counter + 1'd1;
			
			y_buf <= SRAM_read_data; // store y0y1	
			
			M1_state <= S_M1_LEAD_IN_3;
		
		end
		
		S_M1_LEAD_IN_3: begin
		
			SRAM_address <= v_address + v_counter; //v2v3
			v_counter <= v_counter + 1'd1;
			
			u_buf <= SRAM_read_data;  // store u0u1
			
			u_minus_five <= SRAM_read_data[15:8]; 
			u_minus_three <= SRAM_read_data[15:8]; 
			u_minus_one <= SRAM_read_data[15:8]; 
			u_plus_one <= SRAM_read_data[7:0]; 
			
			M1_state <= S_M1_LEAD_IN_4;
		
		end
		
		S_M1_LEAD_IN_4: begin

			v_buf <= SRAM_read_data;   //store v0v1
			
			v_minus_five <= SRAM_read_data[15:8]; 
			v_minus_three <= SRAM_read_data[15:8]; 
			v_minus_one <= SRAM_read_data[15:8]; 
			v_plus_one <= SRAM_read_data[7:0];
			
			u_prime_even <= (u_minus_one - 8'd128);
			
			op1 <= {24'd0, u_buf[15:8]};
			op2 <= j_five;
			
			op3 <= {24'd0, u_buf[15:8]};
			op4 <= j_three;
			
			op5 <= {24'd0, u_buf[15:8]};
			op6 <= j_one;
			
			op7 <= {24'd0, u_buf[7:0]};
			op8 <= j_one;

		
		
			M1_state <= S_M1_LEAD_IN_5;
		
		end	
	
		S_M1_LEAD_IN_5: begin
		
			u_buf <= SRAM_read_data;  //store u2u3
			
			u_plus_three <= SRAM_read_data[15:8];
			u_plus_five <= SRAM_read_data[7:0];
		
			v_prime_even <= (v_minus_one - 8'd128);
	
			op1 <= {24'd0, v_buf[15:8]};
			op2 <= j_five;
			
			op3 <= {24'd0, v_buf[15:8]};
			op4 <= j_three;
			
			op5 <= {24'd0, v_buf[15:8]};
			op6 <= j_one;
			
			op7 <= {24'd0, v_buf[7:0]};
			op8 <= j_one;
			
			u_prime_odd <= result1 + result2 + result3 + result4; 
	
		
			M1_state <= S_M1_LEAD_IN_6;
		
		end	
		
		S_M1_LEAD_IN_6: begin
		
			v_buf <= SRAM_read_data;  //store v2v3
			
			v_plus_three <= SRAM_read_data[15:8];
			v_plus_five <= SRAM_read_data[7:0];
	
			op1 <= {24'd0, u_buf[15:8]};
			op2 <= j_three;
			
			op3 <= {24'd0, u_buf[7:0]};
			op4 <= j_five;
			
			
			v_prime_odd <= result1 + result2 + result3 + result4; 
	
		
			M1_state <= S_M1_LEAD_IN_7;
		
		end			
		
		S_M1_LEAD_IN_7: begin
		
			SRAM_address <= y_address + y_counter;
			y_counter <= y_counter + 1'd1;		
	
			op1 <= {24'd0, v_buf[15:8]};
			op2 <= j_three;
			
			op3 <= {24'd0, v_buf[7:0]};
			op4 <= j_five;
			
			u_prime_odd <= ($signed(u_prime_odd + result1 + result2 + 32'd128) >>> 8) - 32'd128; //from formula (>>>8 = 1/256 or 2^8)
	
	
			M1_state <= S_M1_LEAD_IN_8;
		
		end	
		
		S_M1_LEAD_IN_8: begin
		
			SRAM_address <= u_address + u_counter;
			u_counter <= u_counter + 1'd1;
	
			op1 <= {24'd0, y_buf[15:8]} - 32'd16;
			op2 <= a00;
			
			op3 <= {24'd0, v_minus_one} - 32'd128;
			op4 <= a02;
			
			op5 <= {24'd0, u_minus_one} - 32'd128;
			op6 <= a11;
			
			op7 <= {24'd0, v_minus_one} - 32'd128;
			op8 <= a12;
			
			v_prime_odd <= ($signed(v_prime_odd + result1 + result2 + 32'd128) >>> 8) - 32'd128; 
	
		
			M1_state <= S_M1_LEAD_IN_9;
		
		end
	
		S_M1_LEAD_IN_9: begin
		
		
			SRAM_address <= v_address + v_counter;
			v_counter <= v_counter + 1'd1;
			
			r_acc_even = result1 + result2;
			g_acc_even = result1 + result3 + result4;
			b_acc_even = result1;
	
			op1 <= {24'd0, y_buf[7:0]} - 32'd16;
			op2 <= a00;
			
			op3 <= v_prime_odd;
			op4 <= a02;
			
			op5 <= u_prime_odd;
			op6 <= a11;
			
			op7 <= {24'd0, u_minus_one} - 32'd128;
			op8 <= a21;
			
		
			M1_state <= S_M1_LEAD_IN_10;
		
		end
	
		S_M1_LEAD_IN_10: begin
		
		
			SRAM_we_n <= 1'b0;
			SRAM_address <= rgb_address + rgb_counter;
			rgb_counter <= rgb_counter + 1'd1;
			SRAM_write_data <= {r_clip_even, g_clip_even};
			
			y_buf <= SRAM_read_data; // store y2y3

			b_acc_even <= b_acc_even + result4;
			
			r_acc_odd <= result1 + result2;
			g_acc_odd <= result1 + result3;
			b_acc_odd <= result1;
	
			op1 <= v_prime_odd;
			op2 <= a12;
			
			op3 <= u_prime_odd;
			op4 <= a21;
	
		
			M1_state <= S_M1_LEAD_IN_11;
		
		end	
		
		S_M1_LEAD_IN_11: begin
		
			
			SRAM_we_n <= 1'b0;
			SRAM_address <= rgb_address + rgb_counter;
			rgb_counter <= rgb_counter + 1'd1;
			SRAM_write_data <= {b_clip_even, r_clip_odd};
			
			pixel_counter <= pixel_counter + 18'd1;
			
			u_buf <= SRAM_read_data;  // store u4u5

			g_acc_odd <= g_acc_odd + result1;
			b_acc_odd <= b_acc_odd + result2;
			
			u_minus_five <= u_minus_three; 
			u_minus_three <= u_minus_one; 
			u_minus_one <= u_plus_one; 
			u_plus_one <= u_plus_three; 
			u_plus_three <= u_plus_five;
		
		
			M1_state <= S_M1_COMMON_CASE_1;
		
		end
		
		S_M1_COMMON_CASE_1: begin
		
		
			SRAM_we_n <= 1'b0;
			SRAM_address <= rgb_address + rgb_counter;
			rgb_counter <= rgb_counter + 1'd1;
			SRAM_write_data <= {g_clip_odd, b_clip_odd};
			
			pixel_counter <= pixel_counter + 18'd1;
			
			if (case_flag == 1'b0 && lead_out == 1'b0) begin
			v_buf <= SRAM_read_data;  // store v
			end
			
			u_prime_even <= u_minus_one - 8'd128;
			
			if(lead_out == 1'b1) begin
				u_plus_five <= u_buf[7:0];  // 1st byte of buffer u399
			end else if (case_flag == 1'b0) begin
				u_plus_five <= u_buf[15:8];	// 1st byte of buffer 
			end else begin
				u_plus_five <= u_buf[7:0]; // 2nd byte of buffer
			end	
				
			v_minus_five <= v_minus_three; 
			v_minus_three <= v_minus_one; 
			v_minus_one <= v_plus_one; 
			v_plus_one <= v_plus_three; 
			v_plus_three <= v_plus_five;
			
			op1 <= {24'd0, u_minus_five};
			op2 <= j_five;
			
			op3 <= {24'd0, u_minus_three};
			op4 <= j_three;
			
			op5 <= {24'd0, u_minus_one};
			op6 <= j_one;
			
			op7 <= {24'd0, u_plus_one};
			op8 <= j_one;
			
		
			M1_state <= S_M1_COMMON_CASE_2;
		
		end
		
		S_M1_COMMON_CASE_2: begin
		
			SRAM_we_n <= 1'b1;
			
			v_prime_even <= v_minus_one - 8'd128;
			
			if(lead_out == 1'b1) begin
				v_plus_five <= v_buf[7:0];  // 1st byte of buffer v399
			end else if (case_flag == 1'b0) begin
				v_plus_five <= v_buf[15:8];	// 1st byte of buffer 
			end else begin
				v_plus_five <= v_buf[7:0];    // 2nd byte of buffer
			end
			
			op1 <= {24'd0, u_plus_three};
			op2 <= j_three;
			
			op3 <= {24'd0, u_plus_five};
			op4 <= j_five;
			
			op5 <= {24'd0, v_minus_five};
			op6 <= j_five;
			
			op7 <= {24'd0, v_minus_three};
			op8 <= j_three;
			
			u_prime_odd <= result1 + result2 + result3 + result4;
			
		
			M1_state <= S_M1_COMMON_CASE_3;
		
		end
		
		S_M1_COMMON_CASE_3: begin
		
		
			SRAM_address <= y_address + y_counter;
			y_counter <= y_counter + 1'd1;		
			
			op1 <= {24'd0, v_minus_one};
			op2 <= j_one;
			
			op3 <= {24'd0, v_plus_one};
			op4 <= j_one;
			
			op5 <= {24'd0, v_plus_three};
			op6 <= j_three;
			
			op7 <= {24'd0, v_plus_five};
			op8 <= j_five;
			
			u_prime_odd <= $signed(u_prime_odd + result1 + result2 + 32'd128) >>> 8;
			v_prime_odd <= result3 + result4;
			
		
			M1_state <= S_M1_COMMON_CASE_4;
		
		end
		
		S_M1_COMMON_CASE_4: begin
		
			if(case_flag == 1'b1) begin
				SRAM_address <= u_address + u_counter;
				u_counter <= u_counter + 1'd1;
			end		
			
			op1 <= {24'd0, y_buf[15:8]} - 32'd16;
			op2 <= a00;
			
			op3 <= {24'd0, v_minus_one} - 32'd128;
			op4 <= a02;
			
			op5 <= {24'd0, u_minus_one} - 32'd128;
			op6 <= a11;
			
			op7 <= {24'd0, v_minus_one} - 32'd128;
			op8 <= a12;
			
			v_prime_odd <= $signed(v_prime_odd + result1 + result2 + result3 + result4 + 32'd128) >>> 8;
			
		
			M1_state <= S_M1_COMMON_CASE_5;
		
		end
		
		S_M1_COMMON_CASE_5: begin
		
		
			if(case_flag == 1'b1) begin
				SRAM_address <= v_address + v_counter;
				v_counter <= v_counter + 1'd1;
			end	
	
			
			op1 <= {24'd0, y_buf[7:0]} - 32'd16;
			op2 <= a00;
			
			op3 <= v_prime_odd - 32'd128;
			op4 <= a02;
			
			op5 <= u_prime_odd - 32'd128;
			op6 <= a11;
			
			op7 <= {24'd0, u_minus_one} - 32'd128;
			op8 <= a21;
			
			r_acc_even <= result1 + result2;
			g_acc_even <= result1 + result3 + result4;
			b_acc_even <= result1;
			
		
			M1_state <= S_M1_COMMON_CASE_6;
		
		end

		S_M1_COMMON_CASE_6: begin
		

			SRAM_we_n <= 1'b0;
			SRAM_address <= rgb_address + rgb_counter;
			rgb_counter <= rgb_counter + 1'd1;
			SRAM_write_data <= {r_clip_even, g_clip_even};
			
		
			y_buf <= SRAM_read_data; // store y
		
			op1 <= v_prime_odd - 32'd128;
			op2 <= a12;
			
			op3 <= u_prime_odd - 32'd128;
			op4 <= a21;
			
			b_acc_even = b_acc_even + result4;
			
			r_acc_odd = result1 + result2;
			g_acc_odd = result1 + result3;
			b_acc_odd = result1;
			
		
			M1_state <= S_M1_COMMON_CASE_7;
		
		end

		S_M1_COMMON_CASE_7: begin
		
			SRAM_we_n <= 1'b0;
			SRAM_address <= rgb_address + rgb_counter;
			rgb_counter <= rgb_counter + 1'd1;
			SRAM_write_data <= {b_clip_even, r_clip_odd};
			
			pixel_counter <= pixel_counter + 18'd1;
		
		
			if(case_flag == 1'b1) begin
				u_buf <= SRAM_read_data; // store u
			end		
		

			u_minus_five <= u_minus_three; 
			u_minus_three <= u_minus_one; 
			u_minus_one <= u_plus_one; 
			u_plus_one <= u_plus_three; 
			u_plus_three <= u_plus_five;
			
	
			g_acc_odd <= g_acc_odd + result1;
			b_acc_odd <= b_acc_odd + result2;
			
			if(pixel_counter > 18'd308) begin
				case_flag <= 1'b0;
				lead_out <= 1'b1;
			end else begin	
				case_flag <= ~case_flag;
			end
		
			if (pixel_counter > 18'd317) begin
				M1_state <= S_M1_LEAD_OUT_1;	
				
			end else begin
			
			M1_state <= S_M1_COMMON_CASE_1;
			
			end
			
			
	end
			
		S_M1_LEAD_OUT_1: begin
		
			SRAM_we_n <= 1'b0;
			SRAM_address <= rgb_address + rgb_counter;
			rgb_counter <= rgb_counter + 1'd1;
			SRAM_write_data <= {g_clip_odd, b_clip_odd};
			
			pixel_counter <= pixel_counter + 18'd1;
			
			row_counter <= row_counter +  1'd1;
			
			M1_state <= S_M1_LEAD_OUT_2;
		
		end
		
		S_M1_LEAD_OUT_2: begin
		
			SRAM_we_n <= 1'b1;
			
			if (row_counter < 240) begin
			
			SRAM_address <= y_address + y_counter - 1'd1;
			lead_out <= 1'b0;
			
			pixel_counter <= 18'd0;
			
			M1_state <= S_M1_LEAD_IN_0;
			
			end else begin
			
			M1_end <= 1'b1;
			M1_state <= S_M1_IDLE;
	
			end

		
		end
		

		default: M1_state <= S_M1_IDLE;

		endcase
	end
end


endmodule
