`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module Milestone2 (
   input  logic            Clock,
   input  logic            resetn,
   input  logic [15:0]     SRAM_read_data,
	input logic             M2_start,
	

	output logic [17:0]   SRAM_address,
	output logic [15:0]	 SRAM_write_data,
	output logic		    SRAM_we_n,
	output logic          M2_end
	

);
M2_state_type M2_state;

logic [8:0] address1, address2, address3, address4, address5, address6;
logic [31:0] write_data_a [2:0];
logic [31:0] write_data_b [2:0];
logic write_enable_a [2:0];
logic write_enable_b [2:0];
logic [31:0] read_data_a [2:0];
logic [31:0] read_data_b [2:0];

// instantiate RAM0
// from address 0 - 31: S'
dual_port_RAM0 RAM_inst0 (
	.address_a ( address1 ),
	.address_b ( address2 ),
	.clock ( Clock ),
	.data_a ( write_data_a[0] ),
	.data_b ( write_data_b[0] ),
	.wren_a ( 1'b0 ),
	.wren_b ( write_enable_b[0] ),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);

// instantiate RAM1
// from address 0-63: T
dual_port_RAM1 RAM_inst1 (
	.address_a ( address3 ),
	.address_b ( address4 ),
	.clock ( Clock ),
	.data_a ( write_data_a[1] ),
	.data_b ( write_data_b[1] ),
	.wren_a ( 1'b0 ),
	.wren_b ( write_enable_b[1] ),
	.q_a ( read_data_a[1] ),
	.q_b ( read_data_b[1] )
	);
	
// instantiate RAM2
// from address 0-31: S
dual_port_RAM2 RAM_inst2 (
	.address_a ( address5 ),
	.address_b ( address6 ),
	.clock ( Clock ),
	.data_a ( write_data_a[2] ),
	.data_b ( write_data_b[2] ),
	.wren_a ( write_enable_a[2]  ),
	.wren_b ( write_enable_b[2] ),
	.q_a ( read_data_a[2] ),
	.q_b ( read_data_b[2] )
	);
	
parameter y_address = 18'd0;
parameter u_address = 18'd38400;
parameter v_address = 18'd57600;

parameter s_prime_address = 18'd76800;
parameter s_prime_u_address = 18'd153600;
parameter s_prime_v_address = 18'd192000;

parameter row_offset = 9'd320;

logic [2:0] row_index, col_index;
logic [6:0] row_block, col_block;
logic [8:0] row_address, col_address, col_address_ws;


assign row_address = (row_block * 4'd8) + row_index;
assign col_address = (col_block * 4'd8) + col_index;

assign col_address_ws = (col_block * 4'd4) + col_index;


logic [6:0]  fs_counter;
logic signed [15:0] fs_buf;

logic signed [31:0] t_acc;
logic [6:0] t_counter;
logic [2:0] c_column_count;

logic  [31:0] s0, s1, s2, s3;
logic  [7:0] s0_clip, s1_clip, s2_clip, s3_clip;

logic [2:0] t_offset;
logic [7:0] s_counter;
logic  [15:0] s_buf;
logic s_flag;

logic [2:0] s_offset;

logic fs_flag;


logic signed [5:0] c0, c1, c2, c3;
logic signed [31:0] C0, C1, C2, C3;


logic signed [31:0] op0, op1, op2, op3, result1, result2, result3, result4;
logic signed [63:0] result_long1, result_long2, result_long3, result_long4;

assign result_long1 = $signed(op0)*$signed(C0);
assign result_long2 = $signed(op1)*$signed(C1);
assign result_long3 = $signed(op2)*$signed(C2);
assign result_long4 = $signed(op3)*$signed(C3);

assign result1 = result_long1[31:0];
assign result2 = result_long2[31:0];
assign result3 = result_long3[31:0];
assign result4 = result_long4[31:0];

//clipping function
assign s0_clip = (s0[31] == 1'b1) ? 8'd0 : ((s0[31:24] >= 8'd1) ? 8'd255 : s0[23:16]);
assign s1_clip = (s1[31] == 1'b1) ? 8'd0 : ((s1[31:24] >= 8'd1) ? 8'd255 : s1[23:16]);
assign s2_clip = (s2[31] == 1'b1) ? 8'd0 : ((s2[31:24] >= 8'd1) ? 8'd255 : s2[23:16]);
assign s3_clip = (s3[31] == 1'b1) ? 8'd0 : ((s3[31:24] >= 8'd1) ? 8'd255 : s3[23:16]);



always @(posedge Clock or negedge resetn) begin
	if (~resetn) begin
	
		SRAM_address <= 18'd0;
		SRAM_write_data <= 18'd0;
		SRAM_we_n <= 1'b1;
		
		address1 <= 1'd0;
		address2 <= 1'd0;	
		address3 <= 1'd0;	
		address4 <= 1'd0;	
		address5 <= 1'd0;	
		address6 <= 1'd0;	
		
		write_data_a[0] <= 32'd0;  
      write_data_b[0] <= 32'd0;
      write_enable_a[0] <= 1'b0;
      write_enable_b[0] <= 1'b0;
		
		write_data_a[1] <= 32'd0;  
      write_data_b[1] <= 32'd0;
      write_enable_a[1] <= 1'b0;
      write_enable_b[1] <= 1'b0;
		
		write_data_a[2] <= 32'd0;  
      write_data_b[2] <= 32'd0;
      write_enable_a[2] <= 1'b0;
      write_enable_b[2] <= 1'b0;
	
		M2_end <= 1'b0;
		
		row_index <= 1'd0;
		col_index <= 1'd0;
		row_block <= 1'd0;
		col_block <= 1'd0;

		fs_buf <= 1'd0;
		fs_counter  <= 7'd0;
		
		t_acc <= 32'd0;
		t_counter <= 8'd0;
		c_column_count <= 1'd0;
		
		s0 <= 8'd0;
		s1 <= 8'd0; 
		s2 <= 8'd0; 
		s3 <= 8'd0;
		s_buf  <= 16'd0;
		t_offset <= 3'd0;
		s_flag <= 1'd0;
		s_counter <= 8'd0;
		
		fs_flag <= 1'd1;



	end else begin
	
		case (M2_state)
		S_M2_IDLE: begin
		
			if (M2_start == 1'b1) begin
			
				SRAM_write_data <= 18'd0;
				SRAM_we_n <= 1'b1;
				
				address1 <= 1'd0;
				address2 <= 1'd0;	
				address3 <= 1'd0;	
				address4 <= 1'd0;	
				address5 <= 1'd0;	
				address6 <= 1'd0;	
			
				write_data_a[0] <= 32'd0;  
				write_data_b[0] <= 32'd0;
				write_enable_a[0] <= 1'b0;
				write_enable_b[0] <= 1'b0;	
				
				write_data_a[1] <= 32'd0;  
				write_data_b[1] <= 32'd0;
				write_enable_a[1] <= 1'b0;
				write_enable_b[1] <= 1'b0;
		
				write_data_a[2] <= 32'd0;  
				write_data_b[2] <= 32'd0;
				write_enable_a[2] <= 1'b0;
				write_enable_b[2] <= 1'b0;
				

				M2_end <= 1'b0;
				
	
				row_index <= 1'd0;
				col_index <= 1'd1;
				row_block <= 1'd0;
				col_block <= 1'd0;

				fs_buf <= 1'd0;
				fs_counter  <= 7'd0;
				
				t_acc <= 32'd0;
				t_counter <= 7'd0;
				c_column_count <= 1'd0;
				
				s_buf  <= 16'd0;
				s0 <= 8'd0;
				s1 <= 8'd0; 
				s2 <= 8'd0; 
				s3 <= 8'd0;
				t_offset <= 3'd0;
				s_flag <= 1'd0;
				s_counter <= 7'd0;
				
				fs_flag <= 1'd1;
				
				SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
			
				M2_state <= S_M2_FS_0;
				
			end	
		end

//LEAD IN FS		

		S_M2_FS_0: begin
		
				SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
				col_index <= col_index + 1'd1;
				
				address2 <= 1'd0;	
				
				M2_state <= S_M2_FS_1;
				
		end
		
		S_M2_FS_1: begin
		
				SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
				col_index <= col_index + 1'd1;
				
				M2_state <= S_M2_FS_2;
		
		end	
	
//COMMON CASE FS	
				
		S_M2_FS_2: begin
		
				SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
				
				write_enable_b[0] <= 1'b0;
				fs_buf <= $signed(SRAM_read_data);
				
				if(fs_counter != 7'd0) begin
				
					address2 <= address2 + 1'd1;
					
				end
				
				if (col_index == 3'd7) begin
				
					row_index <= row_index + 1'd1;
					col_index <= 3'd0;

				
				end else begin
				
					col_index <= col_index + 1'd1;			
				end
				
				M2_state <= S_M2_FS_3;
				M2_state <= (row_index == 3'd7 && col_index == 3'd7) ? S_M2_FS_4 : S_M2_FS_3;
				
				
		end
		
		S_M2_FS_3: begin
		
		SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
							
				write_enable_b[0] <= 1'b1;
				write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
				fs_counter <= fs_counter + 7'd2;
				
				
				if (col_index == 3'd7) begin
				
					row_index <= row_index + 1'd1;
					col_index <= 3'd0;
					
				end else begin
				
				col_index <= col_index + 1'd1;							
				end
			
			
				M2_state <= S_M2_FS_2;	
	
	
				
		end
		
//LEAD OUT FS

		S_M2_FS_4: begin
					
				write_enable_b[0] <= 1'b1;
				write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
				fs_counter <= fs_counter + 7'd2;
				
				
				M2_state <= S_M2_FS_5;									
				
		end
		
		S_M2_FS_5: begin
		
				write_enable_b[0] <= 1'b0;
				
				fs_buf <= $signed(SRAM_read_data);
				
				address2 <= address2 + 1'd1;
	
				M2_state <= S_M2_FS_6;					
				
		end
		
		S_M2_FS_6: begin
					
				write_enable_b[0] <= 1'b1;
				write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
				fs_counter <= fs_counter + 7'd2;
				
				
				
				M2_state <= S_M2_CT_0;									
				
		end		

//LEAD IN CT	

		S_M2_CT_0: begin
		
				address1 <= 1'd0;			
				address2 <= 1'd1;
				
				address3 <= 1'd0;	
				address4 <= 1'd0;
				
				write_enable_b[0] <= 1'b0;
				
				write_enable_a[1] <= 1'b0;
				write_enable_b[1] <= 1'b0;
				
				fs_counter <= 1'd0;
				col_index <= 1'd0;
				row_index <= 1'd0;

	
				M2_state <= S_M2_CT_1;					
				
		end	

		S_M2_CT_1: begin
		
				address1 <= address1 + 8'd2;			
				address2 <= address2 + 8'd2;
	
				M2_state <= S_M2_CT_2;				
				
		end
		
		S_M2_CT_2: begin
		
				address1 <= address1 - 8'd2;			
				address2 <= address2 - 8'd2;
		

		
				op0 <= $signed(read_data_a[0][31:16]);
				c0 <= 6'd0;
				
				op1 <= $signed(read_data_a[0][15:0]);
				c1 <= 6'd8;
				
				op2 <= $signed(read_data_b[0][31:16]);
				c2 <= 6'd16;
				
				op3 <= $signed(read_data_b[0][15:0]);
				c3 <= 6'd24;
	
				M2_state <= S_M2_CT_3;				
				
		end		
		

		S_M2_CT_3: begin
		
				address1 <= address1 + 8'd2;			
				address2 <= address2 + 8'd2;
		

		
				op0 <= $signed(read_data_a[0][31:16]);
				c0 <= 6'd32;
				
				op1 <= $signed(read_data_a[0][15:0]);
				c1 <= 6'd40;
				
				op2 <= $signed(read_data_b[0][31:16]);
				c2 <= 6'd48;
				
				op3 <= $signed(read_data_b[0][15:0]);
				c3 <= 6'd56;
				
				t_acc <= result1 + result2 + result3 + result4;
				
				c_column_count <= c_column_count + 1'd1;
				
	
				M2_state <= S_M2_CT_4;					
				
		end
		
//COMMON CASE CT
		
		S_M2_CT_4: begin
		
				address1 <= address1 - 8'd2;			
				address2 <= address2 - 8'd2;
		

		
				op0 <= $signed(read_data_a[0][31:16]);
				c0 <= 6'd0 + c_column_count;	
				
				op1 <= $signed(read_data_a[0][15:0]);
				c1 <= 6'd8 + c_column_count;
				
				op2 <= $signed(read_data_b[0][31:16]);
				c2 <= 6'd16 + c_column_count;	
				
				op3 <= $signed(read_data_b[0][15:0]);
				c3 <= 6'd24 + c_column_count;	
				
				t_acc <= (t_acc + result1 + result2 + result3 + result4) >>> 8;
				
				write_enable_b[1] <= 1'b0;
				
				if(t_counter != 7'd0) begin
				
					address4 <= address4 + 1'd1;
					
				end
				
				if (address4 == 8'd5 || address4 == 8'd13 || address4 == 8'd21 || address4 == 8'd29 || address4 == 8'd37 || address4 == 8'd47 || address4 == 8'd55) begin
				
				address1 <= address1 + 4'd2;	
				address2 <= address2 + 4'd2;
								
				end 
				

				M2_state <= (t_counter == 7'd63) ? S_M2_CT_6 : S_M2_CT_5;			
				
		end
		
		S_M2_CT_5: begin
		
				address1 <= address1 + 8'd2;			
				address2 <= address2 + 8'd2;
		

		
				op0 <= $signed(read_data_a[0][31:16]);
				c0 <= 6'd32 + c_column_count;
				
				op1 <= $signed(read_data_a[0][15:0]);
				c1 <= 6'd40 + c_column_count;	
				
				op2 <= $signed(read_data_b[0][31:16]);
				c2 <= 6'd48 + c_column_count;		
				
				op3 <= $signed(read_data_b[0][15:0]);
				c3 <= 6'd56 + c_column_count;
				
				t_acc <= result1 + result2 + result3 + result4;
				
				c_column_count <= c_column_count + 1'd1;
				t_counter <= t_counter + 7'd1;
				
				write_enable_b[1] <= 1'b1;
				write_data_b[1] <= $signed(t_acc);
				
				if(c_column_count == 3'd7) begin
					c_column_count <= 1'd0;
				end	

	
				M2_state <= S_M2_CT_4;
	
//LEAD OUT CT
	
		end
		
		S_M2_CT_6: begin
				
				
				write_enable_b[1] <= 1'b1;
				write_data_b[1] <= $signed(t_acc);
				t_counter <= t_counter + 7'd1;
				
				col_block <= 1'd1;
				


						
	
				M2_state <= S_M2_MEGA_CS_FS_0;
				
		end
		
		
		
//LEAD IN MEGA S FS

		S_M2_MEGA_CS_FS_0: begin
		
				address1 <= 9'd0;			
				address2 <= 9'd0;
				
				address3 <= 9'd0;	// for reading t
				address4 <= 9'd8; // for reading t
				
				address5 <= 9'd0;  
				address6 <= 9'd1;
				
				write_enable_b[0] <= 1'b0;
				write_enable_b[1] <= 1'b0;
				write_enable_b[2] <= 1'b0;
				
				SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
				col_index <= col_index + 1'd1;
				
				address2 <= 1'd0;	
				
				fs_flag <= 1'd1;
				t_counter <= 1'd0;
				t_acc <= 1'd0;
				


	
				M2_state <= S_M2_MEGA_CS_FS_1;
				
		end	

		S_M2_MEGA_CS_FS_1: begin
		
				SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
				col_index <= col_index + 1'd1;
		
	
				M2_state <= S_M2_MEGA_CS_FS_2;				
				
		end
		
		S_M2_MEGA_CS_FS_2: begin
		
		
				address3 <= address3 + 8'd16; //+ t_offset;			
				address4 <= address4 + 8'd16; //+ t_offset;
				
				
				op0 <= (read_data_a[1]);	// First T value	
				op1 <= (read_data_a[1]);			
				op2 <= (read_data_a[1]);			
				op3 <= (read_data_a[1]);
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd0;
					c1 <= 6'd1;
					c2 <= 6'd2;
					c3 <= 6'd3;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd4;
					c1 <= 6'd5;
					c2 <= 6'd6;
					c3 <= 6'd7;
					
				end

				if (t_offset != 1'd0 || s_flag == 1'd1) begin
				
					s0 <= s0 + result1;
					s1 <= s1 + result2;
					s2 <= s2 + result3;
					s3 <= s3 + result4;
					
				end
				
				if (fs_flag == 1'd1) begin
				
					SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
					
					write_enable_b[0] <= 1'b0;
					fs_buf <= $signed(SRAM_read_data);
					
					if (fs_counter != 7'd0) begin
					
						address2 <= address2 + 1'd1;
						
					end
					
					if (col_index == 3'd7) begin
					
						row_index <= row_index + 1'd1;
						col_index <= 3'd0;
					
					end else begin
					
						col_index <= col_index + 1'd1;	
						
					end
					
					if (row_index == 3'd7 && col_index == 3'd7) begin
						
						fs_flag <= 1'd0;
						
					end
				
				end
	
				M2_state <= S_M2_MEGA_CS_FS_3;				
				
		end		
		

		S_M2_MEGA_CS_FS_3: begin
		
		
				op0 <= (read_data_b[1]);  // Second T value	
				op1 <= (read_data_b[1]);	
				op2 <= (read_data_b[1]);
				op3 <= (read_data_b[1]);
				
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd8;
					c1 <= 6'd9;
					c2 <= 6'd10;
					c3 <= 6'd11;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd12;
					c1 <= 6'd13;
					c2 <= 6'd14;
					c3 <= 6'd15;
					
				end
		
				
				s0 <= result1;
				s1 <= result2;
				s2 <= result3;
				s3 <= result4;
				
				if (t_offset != 1'd0 || s_flag == 1'd1 ) begin
				
				write_enable_a[2] <= 1'b1;
				write_data_a[2] <= (s0_clip);
			
				
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= (s1_clip);

				
				s_counter <= s_counter + 2'd2;
				
				s_buf <= ({s2_clip, s3_clip});
				
				end
				
				if (fs_flag == 1'd1) begin
				
					SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
								
					write_enable_b[0] <= 1'b1;
					write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
					fs_counter <= fs_counter + 7'd2;
					
					
					if (col_index == 3'd7) begin
					
						row_index <= row_index + 1'd1;
						col_index <= 3'd0;
						
					end else begin
					
					col_index <= col_index + 1'd1;	
					
					end
				end
				
	
				M2_state <= S_M2_MEGA_CS_FS_4;					
				
		end
		
		
		S_M2_MEGA_CS_FS_4: begin
		
				address3 <= address3 + 8'd16; 		
				address4 <= address4 + 8'd16; 
		
		
				op0 <= (read_data_a[1]);		
				op1 <= (read_data_a[1]);			
				op2 <= (read_data_a[1]);			
				op3 <= (read_data_a[1]);
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd16;
					c1 <= 6'd17;
					c2 <= 6'd18;
					c3 <= 6'd19;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd20;
					c1 <= 6'd21;
					c2 <= 6'd22;
					c3 <= 6'd23;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				
				if (t_offset != 1'd0 || s_flag == 1'd1) begin
				
				write_enable_a[2] <= 1'b1;
				write_data_a[2] <= (s_buf[15:8]);
				
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= (s_buf[7:0]);
				
				address5 <= address5 + 2'd2;  
				address6 <= address6 + 2'd2;
				
				s_counter <= s_counter + 2'd2;
				
				end
				
				if (fs_flag == 1'd1) begin
				
					SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
					
					write_enable_b[0] <= 1'b0;
					fs_buf <= $signed(SRAM_read_data);
					
					if (fs_counter != 7'd0) begin
					
						address2 <= address2 + 1'd1;
						
					end
					
					if (col_index == 3'd7) begin
					
						row_index <= row_index + 1'd1;
						col_index <= 3'd0;
					
					end else begin
					
						col_index <= col_index + 1'd1;	
						
					end
					
					if (row_index == 3'd7 && col_index == 3'd7) begin
						
						fs_flag <= 1'd0;
						
					end
				
				end

				M2_state <= S_M2_MEGA_CS_FS_5;			
				
		end
		
		S_M2_MEGA_CS_FS_5: begin
		
				if (t_offset != 1'd0 || s_flag == 1'd1) begin
		
				address5 <= address5 + 2'd2;  
				address6 <= address6 + 2'd2;
				
				end
		
				write_enable_a[2] <= 1'b0;
				write_enable_b[2] <= 1'b0;
			

		
				op0 <= (read_data_b[1]);			
				op1 <= (read_data_b[1]);	
				op2 <= (read_data_b[1]);		
				op3 <= (read_data_b[1]);
		
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd24;
					c1 <= 6'd25;
					c2 <= 6'd26;
					c3 <= 6'd27;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd28;
					c1 <= 6'd29;
					c2 <= 6'd30;
					c3 <= 6'd31;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				if (fs_flag == 1'd1) begin
				
					SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
								
					write_enable_b[0] <= 1'b1;
					write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
					fs_counter <= fs_counter + 7'd2;
					
					
					if (col_index == 3'd7) begin
					
						row_index <= row_index + 1'd1;
						col_index <= 3'd0;
						
					end else begin
					
					col_index <= col_index + 1'd1;	
					
					end
				end
				
				
				M2_state <= S_M2_MEGA_CS_FS_6;
				
		end		
	
		S_M2_MEGA_CS_FS_6: begin
		
		
				address3 <= address3 + 8'd16;		
				address4 <= address4 + 8'd16; 
	
		
				op0 <= (read_data_a[1]);			
				op1 <= (read_data_a[1]);			
				op2 <= (read_data_a[1]);			
				op3 <= (read_data_a[1]);
		
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd32;
					c1 <= 6'd33;
					c2 <= 6'd34;
					c3 <= 6'd35;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd36;
					c1 <= 6'd37;
					c2 <= 6'd38;
					c3 <= 6'd39;
					
				end				
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				
				if (fs_flag == 1'd1) begin
				
					SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
					
					write_enable_b[0] <= 1'b0;
					fs_buf <= $signed(SRAM_read_data);
					
					if (fs_counter != 7'd0) begin
					
						address2 <= address2 + 1'd1;
						
					end
					
					if (col_index == 3'd7) begin
					
						row_index <= row_index + 1'd1;
						col_index <= 3'd0;
					
					end else begin
					
						col_index <= col_index + 1'd1;	
						
					end
					
				if (row_index == 3'd7 && col_index == 3'd7) begin
						
						fs_flag <= 1'd0;
						write_enable_b[0] <= 1'b0;
						
					end
				
				end
	
				M2_state <= S_M2_MEGA_CS_FS_7;				
				
		end		
		

		S_M2_MEGA_CS_FS_7: begin
		
				if(s_flag == 1'd1) begin
					t_offset <= t_offset + 1'd1;
				end	
		
				op0 <= (read_data_b[1]);			
				op1 <= (read_data_b[1]);
				op2 <= (read_data_b[1]);
				op3 <= (read_data_b[1]);
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd40;
					c1 <= 6'd41;
					c2 <= 6'd42;
					c3 <= 6'd43;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd44;
					c1 <= 6'd45;
					c2 <= 6'd46;
					c3 <= 6'd47;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				if (fs_flag == 1'd1) begin
				
					SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
								
					write_enable_b[0] <= 1'b1;
					write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
					fs_counter <= fs_counter + 7'd2;
					
					
					if (col_index == 3'd7) begin
					
						row_index <= row_index + 1'd1;
						col_index <= 3'd0;
						
					end else begin
					
					col_index <= col_index + 1'd1;	
					
					end
				end
				
				if (row_index == 3'd7 && col_index == 3'd7) begin
						
					fs_flag <= 1'd0;
						
				end
				
	
				M2_state <= S_M2_MEGA_CS_FS_8;					
				
		end
		
		S_M2_MEGA_CS_FS_8: begin
		
		
				address3 <= 8'd0 + t_offset;			
				address4 <= 8'd8 + t_offset;
	
		
				op0 <= (read_data_a[1]);		
				op1 <= (read_data_a[1]);	
				op2 <= (read_data_a[1]);		
				op3 <= (read_data_a[1]);
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd48;
					c1 <= 6'd49;
					c2 <= 6'd50;
					c3 <= 6'd51;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd52;
					c1 <= 6'd53;
					c2 <= 6'd54;
					c3 <= 6'd55;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				if (fs_flag == 1'd1) begin
				
					SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
					
					write_enable_b[0] <= 1'b0;
					fs_buf <= $signed(SRAM_read_data);
					
					if (fs_counter != 7'd0) begin
					
						address2 <= address2 + 1'd1;
						
					end
					
					if (col_index == 3'd7) begin
					
						row_index <= row_index + 1'd1;
						col_index <= 3'd0;
					
					end else begin
					
						col_index <= col_index + 1'd1;	
						
					end
					
					if (row_index == 3'd7 && col_index == 3'd7) begin
						
						fs_flag <= 1'd0;
						
					end
				
				end
	
				M2_state <= S_M2_MEGA_CS_FS_9;				
				
		end		
		

		S_M2_MEGA_CS_FS_9: begin
		
		
				op0 <= (read_data_b[1]);			
				op1 <= (read_data_b[1]);			
				op2 <= (read_data_b[1]);		
				op3 <= (read_data_b[1]);
				
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd56;
					c1 <= 6'd57;
					c2 <= 6'd58;
					c3 <= 6'd59;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd60;
					c1 <= 6'd61;
					c2 <= 6'd62;
					c3 <= 6'd63;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				s_flag <= ~s_flag;
				
				//FS
				
				if (fs_flag == 1'd1) begin
				
					SRAM_address <= s_prime_address + (row_offset * row_address) + col_address;
								
					write_enable_b[0] <= 1'b1;
					write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
					fs_counter <= fs_counter + 7'd2;
					
					
					if (col_index == 3'd7) begin
					
						row_index <= row_index + 1'd1;
						col_index <= 3'd0;
						
					end else begin
					
					col_index <= col_index + 1'd1;	
					
					end
					
				end
				
	
				M2_state <= (s_counter == 7'd60) ? S_M2_MEGA_CS_FS_10 : S_M2_MEGA_CS_FS_2;
				
		end
		
//LEAD OUT
		
		S_M2_MEGA_CS_FS_10: begin
		
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				
				//FS
				write_enable_b[0] <= 1'b1;
				write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
				fs_counter <= fs_counter + 7'd2;
				
				
				M2_state <= S_M2_MEGA_CS_FS_11;
		
		end
		
		S_M2_MEGA_CS_FS_11: begin
		
				write_enable_a[2] <= 1'b1;
				write_data_a[2] <= (s0_clip);
				
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= (s1_clip);
				
				s_counter <= s_counter + 2'd2;
				
				s_buf <= ({s2_clip, s3_clip});			
				
				//FS
				write_enable_b[0] <= 1'b0;
				fs_buf <= $signed(SRAM_read_data);
				address2 <= address2 + 1'd1;
				
				
				M2_state <= S_M2_MEGA_CS_FS_12;
				
		
		end
		
		S_M2_MEGA_CS_FS_12: begin
		
				address5 <= address5 + 2'd2;  
				address6 <= address6 + 2'd2;
		
				write_enable_a[2] <= 1'b1;
				write_data_a[2] <= (s_buf[15:8]);
				
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= (s_buf[7:0]);
				
				s_counter <= s_counter + 2'd2;
				
				//FS
				write_enable_b[0] <= 1'b1;
				write_data_b[0] <= {fs_buf, $signed(SRAM_read_data)};
				fs_counter <= fs_counter + 7'd2;
				
				//SETUP CT WS
				address1 <= 1'd0;			
				address2 <= 1'd1;
				
				address3 <= 1'd0;	
				address4 <= 1'd0;
				
				s_offset <= 1'd0;
				
				write_enable_a[1] <= 1'b0;
				write_enable_b[1] <= 1'b0;
				
				col_block <= col_block - 1'd1;
				
				
				M2_state <= S_M2_MEGA_WS_CT_0;
		
		end
		
		S_M2_MEGA_WS_CT_0: begin
		
		
				fs_counter <= 1'd0;
				row_index <= 1'd0;
				col_index <= 1'd0;

				write_enable_b[0] <= 1'b0;
							
				s_counter <= 1'd0;
				s_offset <= 1'd1;
				
				
				//CT
				address1 <= address1 + 8'd2;			
				address2 <= address2 + 8'd2;
				
				t_counter <= 1'd0;
				

		
				
				M2_state <= S_M2_MEGA_WS_CT_1;
		
		end
		
		S_M2_MEGA_WS_CT_1: begin
		
				write_enable_a[2] <= 1'b0;		
				write_enable_b[2] <= 1'b0;
				
				
				address5 <= 1'd0;
				address6 <= 8'd8;
				
				SRAM_address <= y_address + (row_offset/2 * row_address) + col_address_ws;
		
		
				//CT
				address1 <= address1 - 8'd2;			
				address2 <= address2 - 8'd2;

		
				op0 <= $signed(read_data_a[0][31:16]);
				c0 <= 6'd0;
				
				op1 <= $signed(read_data_a[0][15:0]);
				c1 <= 6'd8;
				
				op2 <= $signed(read_data_b[0][31:16]);
				c2 <= 6'd16;
				
				op3 <= $signed(read_data_b[0][15:0]);
				c3 <= 6'd24;
				
				
				M2_state <= S_M2_MEGA_WS_CT_2;
				
		
		end
		
		S_M2_MEGA_WS_CT_2: begin
		
				address1 <= address1 + 8'd2;			
				address2 <= address2 + 8'd2;
				
				address5 <= address5 + 8'd16;
				address6 <= address6 + 8'd16;

		
				op0 <= $signed(read_data_a[0][31:16]);
				c0 <= 6'd32;
				
				op1 <= $signed(read_data_a[0][15:0]);
				c1 <= 6'd40;
				
				op2 <= $signed(read_data_b[0][31:16]);
				c2 <= 6'd48;
				
				op3 <= $signed(read_data_b[0][15:0]);
				c3 <= 6'd56;
				
				t_acc <= result1 + result2 + result3 + result4;
				
				c_column_count <= c_column_count + 1'd1;
				
				M2_state <= S_M2_MEGA_WS_CT_3;
				
		
		end
		

		
		S_M2_MEGA_WS_CT_3: begin
		
				SRAM_we_n <= (s_counter >= 7'd64) ? 1'b1 : 1'b0;
				SRAM_write_data <= {read_data_a[2][7:0], read_data_b[2][7:0]};
				
				s_counter <= s_counter + 2'd2;
				
				SRAM_address <= y_address + (row_offset/2 * row_address) + col_address_ws;
				col_index <= col_index + 1'd1;
				
				if (s_counter == 7'd4 || s_counter == 7'd12  || s_counter == 7'd20 || s_counter == 7'd28 || s_counter == 7'd36 || s_counter == 7'd44 || s_counter == 7'd52 ) begin
				
				address5 <= 8'd0 + s_offset;			
				address6 <= 8'd8 + s_offset;
				
				s_offset <= s_offset + 1'd1; 
				
				end else begin
				
				address5 <= address5 + 8'd16;
				address6 <= address6 + 8'd16;
				
				end
				
				//CT
				address1 <= address1 - 8'd2;			
				address2 <= address2 - 8'd2;
		

		
				op0 <= $signed(read_data_a[0][31:16]);
				c0 <= 6'd0 + c_column_count;	
				
				op1 <= $signed(read_data_a[0][15:0]);
				c1 <= 6'd8 + c_column_count;
				
				op2 <= $signed(read_data_b[0][31:16]);
				c2 <= 6'd16 + c_column_count;	
				
				op3 <= $signed(read_data_b[0][15:0]);
				c3 <= 6'd24 + c_column_count;	
				
				t_acc <= (t_acc + result1 + result2 + result3 + result4) >>> 8;
				
				write_enable_b[1] <= 1'b0;
			
				
				if(t_counter != 7'd0) begin
				
					address4 <= address4 + 1'd1;
					
				end
				
				if (address4 == 8'd5 || address4 == 8'd13 || address4 == 8'd21 || address4 == 8'd29 || address4 == 8'd37 || address4 == 8'd47 || address4 == 8'd55) begin
				
				address1 <= address1 + 4'd2;	
				address2 <= address2 + 4'd2;
								
				end 
				

				M2_state <= (t_counter == 7'd63) ? S_M2_MEGA_WS_CT_5 : S_M2_MEGA_WS_CT_4;	
				
		
		end
		
		S_M2_MEGA_WS_CT_4: begin
		
				SRAM_we_n <= (s_counter >= 7'd64) ? 1'b1 : 1'b0;
				SRAM_write_data <= {read_data_a[2][7:0], read_data_b[2][7:0]};
				
				s_counter <= s_counter + 2'd2;
				
				if (col_index == 8'd3) begin
				
				col_index <= 1'd0;
				row_index <= row_index + 1'd1;
				
				end else begin
				
				col_index <= col_index + 2'd1;
				
				end
				
				SRAM_address <= y_address + (row_offset/2 * row_address) + col_address_ws;
				
				address5 <= address5 + 8'd16;
				address6 <= address6 + 8'd16;
				
				
				//CT
				address1 <= address1 + 8'd2;			
				address2 <= address2 + 8'd2;
		
				op0 <= $signed(read_data_a[0][31:16]);
				c0 <= 6'd32 + c_column_count;
				
				op1 <= $signed(read_data_a[0][15:0]);
				c1 <= 6'd40 + c_column_count;	
				
				op2 <= $signed(read_data_b[0][31:16]);
				c2 <= 6'd48 + c_column_count;		
				
				op3 <= $signed(read_data_b[0][15:0]);
				c3 <= 6'd56 + c_column_count;
				
				t_acc <= result1 + result2 + result3 + result4;
				
				c_column_count <= c_column_count + 1'd1;
				t_counter <= t_counter + 7'd1;
				
				write_enable_b[1] <= 1'b1;
				write_data_b[1] <= $signed(t_acc);
				
				if(c_column_count == 3'd7) begin
				
					c_column_count <= 1'd0;
					
				end	
				
				
				M2_state <= S_M2_MEGA_WS_CT_3;
		
		end
		
		S_M2_MEGA_WS_CT_5: begin
		
				col_block <= col_block + 2'd2;
				
				address1 <= 1'd0;
				address2 <= 1'd0;
				address3 <= 1'd0;
				address4 <= 1'd0;
				address5 <= 1'd0;
				address6 <= 1'd0;
				
		
				write_data_a[0] <= 32'd0;  
				write_data_b[0] <= 32'd0;
				write_enable_a[0] <= 1'b0;
				write_enable_b[0] <= 1'b0;
		
				write_data_a[1] <= 32'd0;  
				write_data_b[1] <= 32'd0;
				write_enable_a[1] <= 1'b0;
				write_enable_b[1] <= 1'b0;
		
				write_data_a[2] <= 32'd0;  
				write_data_b[2] <= 32'd0;
				write_enable_a[2] <= 1'b0;
				write_enable_b[2] <= 1'b0;
				
				row_index <= 1'd0;
				col_index <= 1'd0;
		

				fs_buf <= 1'd0;
				fs_counter  <= 7'd0;
		
				t_acc <= 32'd0;
				t_counter <= 8'd0;
				c_column_count <= 1'd0;
		
				s0 <= 8'd0;
				s1 <= 8'd0; 
				s2 <= 8'd0; 
				s3 <= 8'd0;
				
				s_buf  <= 16'd0;
				t_offset <= 3'd0;
				s_flag <= 1'd0;
				s_counter <= 8'd0;
		
				fs_flag <= 1'd1;
				
				if (col_block == 7'd39) begin
				
					col_block <= 1'd0;
					row_block <= row_block + 1'd1;
					
				end

				M2_state <= (row_block == 7'd29 && col_block == 7'd39) ? S_M2_CS_0 : S_M2_MEGA_CS_FS_0;

		end
		
		
		
		
		S_M2_CS_0: begin
		
				address1 <= 9'd0;			
				address2 <= 9'd0;
				
				address3 <= 9'd0;	// for reading t
				address4 <= 9'd8; // for reading t
				
				address5 <= 9'd0;  
				address6 <= 9'd1;
				
				write_enable_b[0] <= 1'b0;
				write_enable_b[1] <= 1'b0;
				write_enable_b[2] <= 1'b0;

	
				M2_state <= S_M2_CS_1;
				
		end	

		S_M2_CS_1: begin
		

		
	
				M2_state <= S_M2_CS_2;				
				
		end
		
		S_M2_CS_2: begin
		
		
				address3 <= address3 + 8'd16; 			
				address4 <= address4 + 8'd16; 
				
				
				op0 <= (read_data_a[1]);	// First T value	
				op1 <= (read_data_a[1]);			
				op2 <= (read_data_a[1]);			
				op3 <= (read_data_a[1]);
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd0;
					c1 <= 6'd1;
					c2 <= 6'd2;
					c3 <= 6'd3;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd4;
					c1 <= 6'd5;
					c2 <= 6'd6;
					c3 <= 6'd7;
					
				end

				if(t_offset != 1'd0 || s_flag == 1'd1) begin
					s0 <= s0 + result1;
					s1 <= s1 + result2;
					s2 <= s2 + result3;
					s3 <= s3 + result4;
				end 	
	
				M2_state <= S_M2_CS_3;				
				
		end		
		

		S_M2_CS_3: begin
		
		
				op0 <= (read_data_b[1]);  // Second T value	
				op1 <= (read_data_b[1]);	
				op2 <= (read_data_b[1]);
				op3 <= (read_data_b[1]);
				
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd8;
					c1 <= 6'd9;
					c2 <= 6'd10;
					c3 <= 6'd11;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd12;
					c1 <= 6'd13;
					c2 <= 6'd14;
					c3 <= 6'd15;
					
				end
		
				
				s0 <= result1;
				s1 <= result2;
				s2 <= result3;
				s3 <= result4;
				
				if (t_offset != 1'd0 || s_flag == 1'd1 ) begin
				
				write_enable_a[2] <= 1'b1;
				write_data_a[2] <= (s0_clip);
			
				
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= (s1_clip);

				
				s_counter <= s_counter + 2'd2;
				
				s_buf <= ({s2_clip, s3_clip});
				
				end
				
	
				M2_state <= S_M2_CS_4;					
				
		end
		
		
		S_M2_CS_4: begin
		
				address3 <= address3 + 8'd16; 		
				address4 <= address4 + 8'd16; 
		
		
				op0 <= (read_data_a[1]);		
				op1 <= (read_data_a[1]);			
				op2 <= (read_data_a[1]);			
				op3 <= (read_data_a[1]);
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd16;
					c1 <= 6'd17;
					c2 <= 6'd18;
					c3 <= 6'd19;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd20;
					c1 <= 6'd21;
					c2 <= 6'd22;
					c3 <= 6'd23;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				
				if (t_offset != 1'd0 || s_flag == 1'd1) begin
				
				write_enable_a[2] <= 1'b1;
				write_data_a[2] <= (s_buf[15:8]);
				
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= (s_buf[7:0]);
				
				address5 <= address5 + 2'd2;  
				address6 <= address6 + 2'd2;
				
				s_counter <= s_counter + 2'd2;
				
				end
				

				M2_state <= S_M2_CS_5;			
				
		end
		
		S_M2_CS_5: begin
		
				if (t_offset != 1'd0 || s_flag == 1'd1) begin
		
				address5 <= address5 + 2'd2;  
				address6 <= address6 + 2'd2;
				
				end
		
				write_enable_a[2] <= 1'b0;
				write_enable_b[2] <= 1'b0;
			

		
				op0 <= (read_data_b[1]);			
				op1 <= (read_data_b[1]);	
				op2 <= (read_data_b[1]);		
				op3 <= (read_data_b[1]);
		
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd24;
					c1 <= 6'd25;
					c2 <= 6'd26;
					c3 <= 6'd27;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd28;
					c1 <= 6'd29;
					c2 <= 6'd30;
					c3 <= 6'd31;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				
				M2_state <= S_M2_CS_6;
				
		end		
	
		S_M2_CS_6: begin
		
		
				address3 <= address3 + 8'd16;		
				address4 <= address4 + 8'd16; 
	
		
				op0 <= (read_data_a[1]);			
				op1 <= (read_data_a[1]);			
				op2 <= (read_data_a[1]);			
				op3 <= (read_data_a[1]);
		
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd32;
					c1 <= 6'd33;
					c2 <= 6'd34;
					c3 <= 6'd35;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd36;
					c1 <= 6'd37;
					c2 <= 6'd38;
					c3 <= 6'd39;
					
				end				
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
	
				M2_state <= S_M2_CS_7;				
				
		end		
		

		S_M2_CS_7: begin
		
				if(s_flag == 1'd1) begin
					t_offset <= t_offset + 1'd1;
				end	
		
				op0 <= (read_data_b[1]);			
				op1 <= (read_data_b[1]);
				op2 <= (read_data_b[1]);
				op3 <= (read_data_b[1]);
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd40;
					c1 <= 6'd41;
					c2 <= 6'd42;
					c3 <= 6'd43;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd44;
					c1 <= 6'd45;
					c2 <= 6'd46;
					c3 <= 6'd47;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
	
				M2_state <= S_M2_CS_8;					
				
		end
		
		S_M2_CS_8: begin
		
		
				address3 <= 8'd0 + t_offset;			
				address4 <= 8'd8 + t_offset;
	
		
				op0 <= (read_data_a[1]);		
				op1 <= (read_data_a[1]);	
				op2 <= (read_data_a[1]);		
				op3 <= (read_data_a[1]);
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd48;
					c1 <= 6'd49;
					c2 <= 6'd50;
					c3 <= 6'd51;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd52;
					c1 <= 6'd53;
					c2 <= 6'd54;
					c3 <= 6'd55;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
	
				M2_state <= S_M2_CS_9;				
				
		end		
		

		S_M2_CS_9: begin
		
		
				op0 <= (read_data_b[1]);			
				op1 <= (read_data_b[1]);			
				op2 <= (read_data_b[1]);		
				op3 <= (read_data_b[1]);
				
				
				if (s_flag == 1'd0) begin
				
					c0 <= 6'd56;
					c1 <= 6'd57;
					c2 <= 6'd58;
					c3 <= 6'd59;
					
				end
				
				if (s_flag == 1'd1) begin
				
					c0 <= 6'd60;
					c1 <= 6'd61;
					c2 <= 6'd62;
					c3 <= 6'd63;
					
				end
				
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				s_flag <= ~s_flag;
				
	
				M2_state <= (s_counter == 7'd60) ? S_M2_CS_10 : S_M2_CS_2;
				
		end
		
		S_M2_CS_10: begin
		
				s0 <= s0 + result1;
				s1 <= s1 + result2;
				s2 <= s2 + result3;
				s3 <= s3 + result4;
				
				M2_state <= S_M2_CS_11;
		
		end
		
		S_M2_CS_11: begin
		
				write_enable_a[2] <= 1'b1;
				write_data_a[2] <= (s0_clip);
				
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= (s1_clip);
				
				s_counter <= s_counter + 2'd2;
				
				s_buf <= ({s2_clip, s3_clip});			
				
				M2_state <= S_M2_CS_12;
		
		end
		
		S_M2_CS_12: begin
		
				address5 <= address5 + 2'd2;  
				address6 <= address6 + 2'd2;
		
				write_enable_a[2] <= 1'b1;
				write_data_a[2] <= (s_buf[15:8]);
				
				write_enable_b[2] <= 1'b1;
				write_data_b[2] <= (s_buf[7:0]);
				
				s_counter <= s_counter + 2'd2;
				
				M2_state <= S_M2_WS_0;
		
		end
		
		S_M2_WS_0: begin
		
				write_enable_a[2] <= 1'b0;		
				write_enable_b[2] <= 1'b0;
				
				address5 <= 1'd0;
				address6 <= 8'd8;
				
				SRAM_address <= y_address + (row_offset/2 * row_address) + col_address_ws;
				
				s_counter <= 1'd0;
				s_offset <= 1'd1;
		
				
				M2_state <= S_M2_WS_1;
		
		end
		
		S_M2_WS_1: begin
		
		address5 <= address5 + 8'd16;
		address6 <= address6 + 8'd16;
				
				M2_state <= S_M2_WS_2;
		
		end
		
		S_M2_WS_2: begin
		
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= {read_data_a[2][7:0], read_data_b[2][7:0]};
				
				s_counter <= s_counter + 2'd2;
				
				SRAM_address <= y_address + (row_offset/2 * row_address) + col_address_ws;
				col_index <= col_index + 1'd1;
				
				if (s_counter == 7'd4 || s_counter == 7'd12  || s_counter == 7'd20 || s_counter == 7'd28 || s_counter == 7'd36 || s_counter == 7'd44 || s_counter == 7'd52 ) begin
				
				address5 <= 8'd0 + s_offset;			
				address6 <= 8'd8 + s_offset;
				
				s_offset <= s_offset + 1'd1; 
				
				end else begin
				
				address5 <= address5 + 8'd16;
				address6 <= address6 + 8'd16;
				
				end
				
				M2_state <= S_M2_WS_3;
		
		end
		
		S_M2_WS_3: begin
		
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= {read_data_a[2][7:0], read_data_b[2][7:0]};
				
				s_counter <= s_counter + 2'd2;
				
				if (col_index == 8'd3) begin
				
				col_index <= 1'd0;
				row_index <= row_index + 1'd1;
				
				end else begin
				
				col_index <= col_index + 2'd1;
				
				end
				
				SRAM_address <= y_address + (row_offset/2 * row_address) + col_address_ws;
				
				address5 <= address5 + 8'd16;
				address6 <= address6 + 8'd16;
				
				
				M2_state <= (s_counter == 7'd62) ? S_M2_WS_4 : S_M2_WS_2;
		
		end
		
		S_M2_WS_4: begin
		
				SRAM_we_n <= 1'b1;
				M2_end <= 1'b1;		

				M2_state <= S_M2_IDLE;
		end
		


		default: M2_state <= S_M2_IDLE;

		endcase
	end
end


always_comb begin

	case(c0)
		0:   C0 = 32'sd1448;   //C00
		1:   C0 = 32'sd1448;   //C01
		2:   C0 = 32'sd1448;   //C02
		3:   C0 = 32'sd1448;   //C03
		4:   C0 = 32'sd1448;   //C04
		5:   C0 = 32'sd1448;   //C05
		6:   C0 = 32'sd1448;   //C06
		7:   C0 = 32'sd1448;   //C07
		8:   C0 = 32'sd2008;   //C10
		9:   C0 = 32'sd1702;   //C11
		10:  C0 = 32'sd1137;   //C12
		11:  C0 = 32'sd399;    //C13
		12:  C0 = -32'sd399;   //C14
		13:  C0 = -32'sd1137;  //C15
		14:  C0 = -32'sd1702;  //C16
		15:  C0 = -32'sd2008;  //C17
		16:  C0 = 32'sd1892;   //C20
		17:  C0 = 32'sd783;    //C21
		18:  C0 = -32'sd783;   //C22
		19:  C0 = -32'sd1892;  //C23
		20:  C0 = -32'sd1892;  //C24
		21:  C0 = -32'sd783;   //C25
		22:  C0 = 32'sd783;    //C26
		23:  C0 = 32'sd1892;   //C27
		24:  C0 = 32'sd1702;   //C30
		25:  C0 = -32'sd399;   //C31
		26:  C0 = -32'sd2008;  //C32
		27:  C0 = -32'sd1137;  //C33
		28:  C0 = 32'sd1137;   //C34
		29:  C0 = 32'sd2008;   //C35
		30:  C0 = 32'sd399;    //C36
		31:  C0 = -32'sd1702;  //C37
		32:  C0 = 32'sd1448;   //C40
		33:  C0 = -32'sd1448;  //C41
		34:  C0 = -32'sd1448;  //C42
		35:  C0 = 32'sd1448;   //C43
		36:  C0 = 32'sd1448;   //C44
		37:  C0 = -32'sd1448;  //C45
		38:  C0 = -32'sd1448;  //C46
		39:  C0 = 32'sd1448;   //C47
		40:  C0 = 32'sd1137;   //C50
		41:  C0 = -32'sd2008;  //C51
		42:  C0 = 32'sd399;    //C52
		43:  C0 = 32'sd1702;   //C53
		44:  C0 = -32'sd1702;  //C54
		45:  C0 = -32'sd399;   //C55
		46:  C0 = 32'sd2008;   //C56
		47:  C0 = -32'sd1137;  //C57
		48:  C0 = 32'sd783;    //C60
		49:  C0 = -32'sd1892;  //C61
		50:  C0 = 32'sd1892;   //C62
		51:  C0 = -32'sd783;   //C63
		52:  C0 = -32'sd783;   //C64
		53:  C0 = 32'sd1892;   //C65
		54:  C0 = -32'sd1892;  //C66
		55:  C0 = 32'sd783;    //C67
		56:  C0 = 32'sd399;    //C70
		57:  C0 = -32'sd1137;  //C71
		58:  C0 = 32'sd1702;   //C72
		59:  C0 = -32'sd2008;  //C73
		60:  C0 = 32'sd2008;   //C74
		61:  C0 = -32'sd1702;  //C75
		62:  C0 = 32'sd1137;   //C76
		63:  C0 = -32'sd399;   //C77
		
	endcase

end

always_comb begin

	case(c1)
		0:   C1 = 32'sd1448;   //C00
		1:   C1 = 32'sd1448;   //C01
		2:   C1 = 32'sd1448;   //C02
		3:   C1 = 32'sd1448;   //C03
		4:   C1 = 32'sd1448;   //C04
		5:   C1 = 32'sd1448;   //C05
		6:   C1 = 32'sd1448;   //C06
		7:   C1 = 32'sd1448;   //C07
		8:   C1 = 32'sd2008;   //C10
		9:   C1 = 32'sd1702;   //C11
		10:  C1 = 32'sd1137;   //C12
		11:  C1 = 32'sd399;    //C13
		12:  C1 = -32'sd399;   //C14
		13:  C1 = -32'sd1137;  //C15
		14:  C1 = -32'sd1702;  //C16
		15:  C1 = -32'sd2008;  //C17
		16:  C1 = 32'sd1892;   //C20
		17:  C1 = 32'sd783;    //C21
		18:  C1 = -32'sd783;   //C22
		19:  C1 = -32'sd1892;  //C23
		20:  C1 = -32'sd1892;  //C24
		21:  C1 = -32'sd783;   //C25
		22:  C1 = 32'sd783;    //C26
		23:  C1 = 32'sd1892;   //C27
		24:  C1 = 32'sd1702;   //C30
		25:  C1 = -32'sd399;   //C31
		26:  C1 = -32'sd2008;  //C32
		27:  C1 = -32'sd1137;  //C33
		28:  C1 = 32'sd1137;   //C34
		29:  C1 = 32'sd2008;   //C35
		30:  C1 = 32'sd399;    //C36
		31:  C1 = -32'sd1702;  //C37
		32:  C1 = 32'sd1448;   //C40
		33:  C1 = -32'sd1448;  //C41
		34:  C1 = -32'sd1448;  //C42
		35:  C1 = 32'sd1448;   //C43
		36:  C1 = 32'sd1448;   //C44
		37:  C1 = -32'sd1448;  //C45
		38:  C1 = -32'sd1448;  //C46
		39:  C1 = 32'sd1448;   //C47
		40:  C1 = 32'sd1137;   //C50
		41:  C1 = -32'sd2008;  //C51
		42:  C1 = 32'sd399;    //C52
		43:  C1 = 32'sd1702;   //C53
		44:  C1 = -32'sd1702;  //C54
		45:  C1 = -32'sd399;   //C55
		46:  C1 = 32'sd2008;   //C56
		47:  C1 = -32'sd1137;  //C57
		48:  C1 = 32'sd783;    //C60
		49:  C1 = -32'sd1892;  //C61
		50:  C1 = 32'sd1892;   //C62
		51:  C1 = -32'sd783;   //C63
		52:  C1 = -32'sd783;   //C64
		53:  C1 = 32'sd1892;   //C65
		54:  C1 = -32'sd1892;  //C66
		55:  C1 = 32'sd783;    //C67
		56:  C1 = 32'sd399;    //C70
		57:  C1 = -32'sd1137;  //C71
		58:  C1 = 32'sd1702;   //C72
		59:  C1 = -32'sd2008;  //C73
		60:  C1 = 32'sd2008;   //C74
		61:  C1 = -32'sd1702;  //C75
		62:  C1 = 32'sd1137;   //C76
		63:  C1 = -32'sd399;   //C77
		
	endcase

end



always_comb begin

	case(c2)
		0:   C2 = 32'sd1448;   //C00
		1:   C2 = 32'sd1448;   //C01
		2:   C2 = 32'sd1448;   //C02
		3:   C2 = 32'sd1448;   //C03
		4:   C2 = 32'sd1448;   //C04
		5:   C2 = 32'sd1448;   //C05
		6:   C2 = 32'sd1448;   //C06
		7:   C2 = 32'sd1448;   //C07
		8:   C2 = 32'sd2008;   //C10
		9:   C2 = 32'sd1702;   //C11
		10:  C2 = 32'sd1137;   //C12
		11:  C2 = 32'sd399;    //C13
		12:  C2 = -32'sd399;   //C14
		13:  C2 = -32'sd1137;  //C15
		14:  C2 = -32'sd1702;  //C16
		15:  C2 = -32'sd2008;  //C17
		16:  C2 = 32'sd1892;   //C20
		17:  C2 = 32'sd783;    //C21
		18:  C2 = -32'sd783;   //C22
		19:  C2 = -32'sd1892;  //C23
		20:  C2 = -32'sd1892;  //C24
		21:  C2 = -32'sd783;   //C25
		22:  C2 = 32'sd783;    //C26
		23:  C2 = 32'sd1892;   //C27
		24:  C2 = 32'sd1702;   //C30
		25:  C2 = -32'sd399;   //C31
		26:  C2 = -32'sd2008;  //C32
		27:  C2 = -32'sd1137;  //C33
		28:  C2 = 32'sd1137;   //C34
		29:  C2 = 32'sd2008;   //C35
		30:  C2 = 32'sd399;    //C36
		31:  C2 = -32'sd1702;  //C37
		32:  C2 = 32'sd1448;   //C40
		33:  C2 = -32'sd1448;  //C41
		34:  C2 = -32'sd1448;  //C42
		35:  C2 = 32'sd1448;   //C43
		36:  C2 = 32'sd1448;   //C44
		37:  C2 = -32'sd1448;  //C45
		38:  C2 = -32'sd1448;  //C46
		39:  C2 = 32'sd1448;   //C47
		40:  C2 = 32'sd1137;   //C50
		41:  C2 = -32'sd2008;  //C51
		42:  C2 = 32'sd399;    //C52
		43:  C2 = 32'sd1702;   //C53
		44:  C2 = -32'sd1702;  //C54
		45:  C2 = -32'sd399;   //C55
		46:  C2 = 32'sd2008;   //C56
		47:  C2 = -32'sd1137;  //C57
		48:  C2 = 32'sd783;    //C60
		49:  C2 = -32'sd1892;  //C61
		50:  C2 = 32'sd1892;   //C62
		51:  C2 = -32'sd783;   //C63
		52:  C2 = -32'sd783;   //C64
		53:  C2 = 32'sd1892;   //C65
		54:  C2 = -32'sd1892;  //C66
		55:  C2 = 32'sd783;    //C67
		56:  C2 = 32'sd399;    //C70
		57:  C2 = -32'sd1137;  //C71
		58:  C2 = 32'sd1702;   //C72
		59:  C2 = -32'sd2008;  //C73
		60:  C2 = 32'sd2008;   //C74
		61:  C2 = -32'sd1702;  //C75
		62:  C2 = 32'sd1137;   //C76
		63:  C2 = -32'sd399;   //C77
		
	endcase

end

always_comb begin

	case(c3)
		0:   C3 = 32'sd1448;   //C00
		1:   C3 = 32'sd1448;   //C01
		2:   C3 = 32'sd1448;   //C02
		3:   C3 = 32'sd1448;   //C03
		4:   C3 = 32'sd1448;   //C04
		5:   C3 = 32'sd1448;   //C05
		6:   C3 = 32'sd1448;   //C06
		7:   C3 = 32'sd1448;   //C07
		8:   C3 = 32'sd2008;   //C10
		9:   C3 = 32'sd1702;   //C11
		10:  C3 = 32'sd1137;   //C12
		11:  C3 = 32'sd399;    //C13
		12:  C3 = -32'sd399;   //C14
		13:  C3 = -32'sd1137;  //C15
		14:  C3 = -32'sd1702;  //C16
		15:  C3 = -32'sd2008;  //C17
		16:  C3 = 32'sd1892;   //C20
		17:  C3 = 32'sd783;    //C21
		18:  C3 = -32'sd783;   //C22
		19:  C3 = -32'sd1892;  //C23
		20:  C3 = -32'sd1892;  //C24
		21:  C3 = -32'sd783;   //C25
		22:  C3 = 32'sd783;    //C26
		23:  C3 = 32'sd1892;   //C27
		24:  C3 = 32'sd1702;   //C30
		25:  C3 = -32'sd399;   //C31
		26:  C3 = -32'sd2008;  //C32
		27:  C3 = -32'sd1137;  //C33
		28:  C3 = 32'sd1137;   //C34
		29:  C3 = 32'sd2008;   //C35
		30:  C3 = 32'sd399;    //C36
		31:  C3 = -32'sd1702;  //C37
		32:  C3 = 32'sd1448;   //C40
		33:  C3 = -32'sd1448;  //C41
		34:  C3 = -32'sd1448;  //C42
		35:  C3 = 32'sd1448;   //C43
		36:  C3 = 32'sd1448;   //C44
		37:  C3 = -32'sd1448;  //C45
		38:  C3 = -32'sd1448;  //C46
		39:  C3 = 32'sd1448;   //C47
		40:  C3 = 32'sd1137;   //C50
		41:  C3 = -32'sd2008;  //C51
		42:  C3= 32'sd399;    //C52
		43:  C3 = 32'sd1702;   //C53
		44:  C3 = -32'sd1702;  //C54
		45:  C3 = -32'sd399;   //C55
		46:  C3 = 32'sd2008;   //C56
		47:  C3 = -32'sd1137;  //C57
		48:  C3 = 32'sd783;    //C60
		49:  C3 = -32'sd1892;  //C61
		50:  C3 = 32'sd1892;   //C62
		51:  C3 = -32'sd783;   //C63
		52:  C3 = -32'sd783;   //C64
		53:  C3 = 32'sd1892;   //C65
		54:  C3 = -32'sd1892;  //C66
		55:  C3 = 32'sd783;    //C67
		56:  C3 = 32'sd399;    //C70
		57:  C3 = -32'sd1137;  //C71
		58:  C3 = 32'sd1702;   //C72
		59:  C3 = -32'sd2008;  //C73
		60:  C3 = 32'sd2008;   //C74
		61:  C3 = -32'sd1702;  //C75
		62:  C3 = 32'sd1137;   //C76
		63:  C3 = -32'sd399;   //C77
		
	endcase

end

endmodule