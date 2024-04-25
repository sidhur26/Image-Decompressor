`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	M1,
	M2
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic [4:0] {
	S_M1_IDLE,
	S_M1_LEAD_IN_0,
	S_M1_LEAD_IN_1,
	S_M1_LEAD_IN_2,
	S_M1_LEAD_IN_3,
	S_M1_LEAD_IN_4,
	S_M1_LEAD_IN_5,
	S_M1_LEAD_IN_6,
	S_M1_LEAD_IN_7,
	S_M1_LEAD_IN_8,
	S_M1_LEAD_IN_9,
	S_M1_LEAD_IN_10,
	S_M1_LEAD_IN_11,
	
	S_M1_COMMON_CASE_1,
	S_M1_COMMON_CASE_2,
	S_M1_COMMON_CASE_3,
	S_M1_COMMON_CASE_4,
	S_M1_COMMON_CASE_5,
	S_M1_COMMON_CASE_6,
	S_M1_COMMON_CASE_7,

	S_M1_LEAD_OUT_1,
	S_M1_LEAD_OUT_2
} M1_state_type;

typedef enum logic [6:0] {
	S_M2_IDLE,
	S_M2_FS_0,
	S_M2_FS_1,
	S_M2_FS_2,
	S_M2_FS_3,
	S_M2_FS_4,
	S_M2_FS_5,
	S_M2_FS_6,
	S_M2_CT_0,
	S_M2_CT_1,
	S_M2_CT_2,
	S_M2_CT_3,
	S_M2_CT_4,
	S_M2_CT_5,
	S_M2_CT_6,
	S_M2_MEGA_CS_FS_0,
	S_M2_MEGA_CS_FS_1,
	S_M2_MEGA_CS_FS_2,
	S_M2_MEGA_CS_FS_3,
	S_M2_MEGA_CS_FS_4,
	S_M2_MEGA_CS_FS_5,
	S_M2_MEGA_CS_FS_6,
	S_M2_MEGA_CS_FS_7,
	S_M2_MEGA_CS_FS_8,
	S_M2_MEGA_CS_FS_9,
	S_M2_MEGA_CS_FS_10,
	S_M2_MEGA_CS_FS_11,
	S_M2_MEGA_CS_FS_12,
	S_M2_MEGA_WS_CT_0,
	S_M2_MEGA_WS_CT_1,
	S_M2_MEGA_WS_CT_2,
	S_M2_MEGA_WS_CT_3,
	S_M2_MEGA_WS_CT_4,
	S_M2_MEGA_WS_CT_5,
	S_M2_CS_0,
	S_M2_CS_1,
	S_M2_CS_2,
	S_M2_CS_3,
	S_M2_CS_4,
	S_M2_CS_5,
	S_M2_CS_6,
	S_M2_CS_7,
	S_M2_CS_8,
	S_M2_CS_9,
	S_M2_CS_10,
	S_M2_CS_11,
	S_M2_CS_12,
	S_M2_WS_0,
	S_M2_WS_1,
	S_M2_WS_2,
	S_M2_WS_3,
	S_M2_WS_4
	
	
	
} M2_state_type;

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
