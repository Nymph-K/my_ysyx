`timescale 1 ns / 1 ps

module myip_axi4_Full_master_v1_0_M00_AXI #(
    parameter           C_M_TARGET_SLAVE_BASE_ADDR	    = 32'h40000000,
    parameter integer   C_M_AXI_BURST_LEN	            = 16,
    parameter integer   C_M_AXI_ID_WIDTH	            = 1,
    parameter integer   C_M_AXI_ADDR_WIDTH	            = 32,
    parameter integer   C_M_AXI_DATA_WIDTH	            = 32,
    parameter integer   C_M_AXI_AWUSER_WIDTH	        = 0,
    parameter integer   C_M_AXI_ARUSER_WIDTH	        = 0,
    parameter integer   C_M_AXI_WUSER_WIDTH	            = 0,
    parameter integer   C_M_AXI_RUSER_WIDTH	            = 0,
    parameter integer   C_M_AXI_BUSER_WIDTH	            = 0) (
    input   wire                                INIT_AXI_TXN,
    output  wire                                TXN_DONE,
    output  reg                                 ERROR,
    input   wire                                M_AXI_ACLK,
    input   wire                                M_AXI_ARESETN,
    output  wire [C_M_AXI_ID_WIDTH-1 : 0]       M_AXI_AWID,
    output  wire [C_M_AXI_ADDR_WIDTH-1 : 0]     M_AXI_AWADDR,
    output  wire [7 : 0]                        M_AXI_AWLEN,
    output  wire [2 : 0]                        M_AXI_AWSIZE,
    output  wire [1 : 0]                        M_AXI_AWBURST,
    output  wire                                M_AXI_AWLOCK,
    output  wire [3 : 0]                        M_AXI_AWCACHE,
    output  wire [2 : 0]                        M_AXI_AWPROT,
    output  wire [3 : 0]                        M_AXI_AWQOS,
    output  wire [C_M_AXI_AWUSER_WIDTH-1 : 0]   M_AXI_AWUSER,
    output  wire                                M_AXI_AWVALID,
    input   wire                                M_AXI_AWREADY,
    output  wire [C_M_AXI_DATA_WIDTH-1 : 0]     M_AXI_WDATA,
    output  wire [C_M_AXI_DATA_WIDTH/8-1 : 0]   M_AXI_WSTRB,
    output  wire                                M_AXI_WLAST,
    output  wire [C_M_AXI_WUSER_WIDTH-1 : 0]    M_AXI_WUSER,
    output  wire                                M_AXI_WVALID,
    input   wire                                M_AXI_WREADY,
    input   wire [C_M_AXI_ID_WIDTH-1 : 0]       M_AXI_BID,
    input   wire [1 : 0]                        M_AXI_BRESP,
    input   wire [C_M_AXI_BUSER_WIDTH-1 : 0]    M_AXI_BUSER,
    input   wire                                M_AXI_BVALID,
    output  wire                                M_AXI_BREADY,
    output  wire [C_M_AXI_ID_WIDTH-1 : 0]       M_AXI_ARID,
    output  wire [C_M_AXI_ADDR_WIDTH-1 : 0]     M_AXI_ARADDR,
    output  wire [7 : 0]                        M_AXI_ARLEN,
    output  wire [2 : 0]                        M_AXI_ARSIZE,
    output  wire [1 : 0]                        M_AXI_ARBURST,
    output  wire                                M_AXI_ARLOCK,
    output  wire [3 : 0]                        M_AXI_ARCACHE,
    output  wire [2 : 0]                        M_AXI_ARPROT,
    output  wire [3 : 0]                        M_AXI_ARQOS,
    output  wire [C_M_AXI_ARUSER_WIDTH-1 : 0]   M_AXI_ARUSER,
    output  wire                                M_AXI_ARVALID,
    input   wire                                M_AXI_ARREADY,
    input   wire [C_M_AXI_ID_WIDTH-1 : 0]       M_AXI_RID,
    input   wire [C_M_AXI_DATA_WIDTH-1 : 0]     M_AXI_RDATA,
    input   wire [1 : 0]                        M_AXI_RRESP,
    input   wire                                M_AXI_RLAST,
    input   wire [C_M_AXI_RUSER_WIDTH-1 : 0]    M_AXI_RUSER,
    input   wire                                M_AXI_RVALID,
    output  wire                                M_AXI_RREADY
    );


// function called clogb2 that returns an integer which has the
//value of the ceiling of the log base 2

// function called clogb2 that returns an integer which has the
// value of the ceiling of the log base 2.
function integer clogb2 (input integer bit_depth); begin
    for(clogb2 = 0; bit_depth>0; clogb2 = clogb2+1)
        bit_depth = bit_depth >> 1;
end
endfunction

// C_TRANSACTIONS_NUM is the width of the index counter for
// number of write or read transaction.
localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);

// Burst length for transactions, in C_M_AXI_DATA_WIDTHs.
// Non-2^n lengths will eventually cause bursts across 4K address boundaries.
localparam integer C_MASTER_LENGTH	 = 12;
// total number of burst transfers is master length divided by burst length and burst size
localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8)-1);
// Example State machine to initialize counter, initialize write transactions,
// initialize read transactions and comparison of read data with the
// written data words.
parameter [1:0] IDLE = 2'b00, // This state initiates AXI4Lite transaction
// after the state machine changes state to INIT_WRITE
// when there is 0 to 1 transition on INIT_AXI_TXN
INIT_WRITE = 2'b01, // This state initializes write transaction,
// once writes are done, the state machine
// changes state to INIT_READ
INIT_READ = 2'b10, // This state initializes read transaction
// once reads are done, the state machine
// changes state to INIT_COMPARE
INIT_COMPARE = 2'b11; // This state issues the status of comparison
// of the written data with the read data

reg [1:0] mst_exec_state;

// AXI4LITE signals
//AXI4 internal temp signals
reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
reg  	axi_awvalid;
reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
reg  	axi_wlast;
reg  	axi_wvalid;
reg  	axi_bready;
reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
reg  	axi_arvalid;
reg  	axi_rready;
//write beat count in a burst
reg [C_TRANSACTIONS_NUM : 0] 	write_index;
//read beat count in a burst
reg [C_TRANSACTIONS_NUM : 0] 	read_index;
//size of C_M_AXI_BURST_LEN length burst in bytes
wire [C_TRANSACTIONS_NUM+2 : 0] 	burst_size_bytes;
//The burst counters are used to track the number of burst transfers of C_M_AXI_BURST_LEN burst length needed to transfer 2^C_MASTER_LENGTH bytes of data.
reg [C_NO_BURSTS_REQ : 0] 	write_burst_counter;
reg [C_NO_BURSTS_REQ : 0] 	read_burst_counter;
reg  	start_single_burst_write;
reg  	start_single_burst_read;
reg  	writes_done;
reg  	reads_done;
reg  	error_reg;
reg  	compare_done;
reg  	read_mismatch;
reg  	burst_write_active;
reg  	burst_read_active;
reg [C_M_AXI_DATA_WIDTH-1 : 0] 	expected_rdata;
//Interface response error flags
wire  	write_resp_error;
wire  	read_resp_error;
wire  	wnext;
wire  	rnext;
reg  	init_txn_ff;
reg  	init_txn_ff2;
reg  	init_txn_edge;
wire  	init_txn_pulse;


// I/O Connections assignments

//I/O Connections. Write Address (AW)
assign M_AXI_AWID	 = 'b0;
//The AXI address is a concatenation of the target base address + active offset range
assign M_AXI_AWADDR	 = C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
//Burst LENgth is number of transaction beats, minus 1
assign M_AXI_AWLEN	 = C_M_AXI_BURST_LEN - 1;
//Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
assign M_AXI_AWSIZE	 = clogb2((C_M_AXI_DATA_WIDTH/8)-1);
//INCR burst type is usually used, except for keyhole bursts
assign M_AXI_AWBURST	 = 2'b01;
assign M_AXI_AWLOCK	  = 1'b0;
//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
assign M_AXI_AWCACHE	 = 4'b0010;
assign M_AXI_AWPROT	  = 3'h0;
assign M_AXI_AWQOS	   = 4'h0;
assign M_AXI_AWUSER	  = 'b1;
assign M_AXI_AWVALID	 = axi_awvalid;
//Write Data(W)
assign M_AXI_WDATA	 = axi_wdata;
//All bursts are complete and aligned in this example
assign M_AXI_WSTRB	  = {(C_M_AXI_DATA_WIDTH/8){1'b1}};
assign M_AXI_WLAST	  = axi_wlast;
assign M_AXI_WUSER	  = 'b0;
assign M_AXI_WVALID	 = axi_wvalid;
//Write Response (B)
assign M_AXI_BREADY	 = axi_bready;
//Read Address (AR)
assign M_AXI_ARID	   = 'b0;
assign M_AXI_ARADDR	 = C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
//Burst LENgth is number of transaction beats, minus 1
assign M_AXI_ARLEN	 = C_M_AXI_BURST_LEN - 1;
//Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
assign M_AXI_ARSIZE	 = clogb2((C_M_AXI_DATA_WIDTH/8)-1);
//INCR burst type is usually used, except for keyhole bursts
assign M_AXI_ARBURST	 = 2'b01;
assign M_AXI_ARLOCK	  = 1'b0;
//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
assign M_AXI_ARCACHE	 = 4'b0010;
assign M_AXI_ARPROT	  = 3'h0;
assign M_AXI_ARQOS	   = 4'h0;
assign M_AXI_ARUSER	  = 'b1;
assign M_AXI_ARVALID	 = axi_arvalid;
//Read and Read Response (R)
assign M_AXI_RREADY	 = axi_rready;
//Example design I/O
assign TXN_DONE	 = compare_done;
//Burst size in bytes
assign burst_size_bytes	 = C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;

assign init_txn_pulse	 = (!init_txn_ff2) && init_txn_ff;
//Generate a pulse to initiate AXI transaction.
always @(posedge M_AXI_ACLK) begin
    // Initiates AXI transaction delay
    if (M_AXI_ARESETN == 0) begin
        init_txn_ff  <= 1'b0;
        init_txn_ff2 <= 1'b0;
        end else begin
        init_txn_ff  <= INIT_AXI_TXN;
        init_txn_ff2 <= init_txn_ff;
    end
end

always @(posedge M_AXI_ACLK) begin
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
            axi_awvalid <= 1'b0;
        end
        // If previously not valid , start next transaction
        else if (~axi_awvalid && start_single_burst_write) begin
        axi_awvalid <= 1'b1;
        end
    /* Once asserted, VALIDs cannot be deasserted, so axi_awvalid
    must wait until transaction is accepted */
    else if (M_AXI_AWREADY && axi_awvalid) begin
    axi_awvalid <= 1'b0;
    end else
    axi_awvalid <= axi_awvalid;
end


// Next address after AWREADY indicates previous address acceptance
always @(posedge M_AXI_ACLK) begin
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
        axi_awaddr <= 'b0;
        end else if (M_AXI_AWREADY && axi_awvalid) begin
        axi_awaddr <= axi_awaddr + burst_size_bytes;
        end else
        axi_awaddr <= axi_awaddr;
    end
    
    
    assign wnext = M_AXI_WREADY & axi_wvalid;   	//写数据持续期�??
    
    // WVALID logic, similar to the axi_awvalid always block above
    always @(posedge M_AXI_ACLK) begin
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
            axi_wvalid <= 1'b0;
        end
        // If previously not valid, start next transaction
        else if (~axi_wvalid && start_single_burst_write) begin
        axi_wvalid <= 1'b1;
    end
    /* If WREADY and too many writes, throttle WVALID
     Once asserted, VALIDs cannot be deasserted, so WVALID
     must wait until burst is complete with WLAST */
    else if (wnext && axi_wlast)
    axi_wvalid <= 1'b0;
    else
    axi_wvalid <= axi_wvalid;
end


//WLAST generation on the MSB of a counter underflow
// WVALID logic, similar to the axi_awvalid always block above
always @(posedge M_AXI_ACLK) begin
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
        axi_wlast <= 1'b0;
    end
    // axi_wlast is asserted when the write index
    // count reaches the penultimate count to synchronize
    // with the last write data when write_index is b1111
    // else if (&(write_index[C_TRANSACTIONS_NUM-1:1])&& ~write_index[0] && wnext)
    else if (((write_index == C_M_AXI_BURST_LEN-2 && C_M_AXI_BURST_LEN > = 2) && wnext) || (C_M_AXI_BURST_LEN == 1)) begin
    axi_wlast <= 1'b1;
end
// Deassrt axi_wlast when the last write data has been
// accepted by the slave with a valid response
else if (wnext)
axi_wlast <= 1'b0;
else if (axi_wlast && C_M_AXI_BURST_LEN == 1)
axi_wlast <= 1'b0;
else
axi_wlast <= axi_wlast;
end


/* Burst length counter. Uses extra counter register bit to indicate terminal
 count to reduce decode logic */
always @(posedge M_AXI_ACLK) begin
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 || start_single_burst_write == 1'b1) begin
        write_index <= 0;
        end else if (wnext && (write_index ! = C_M_AXI_BURST_LEN-1)) begin
        write_index <= write_index + 1;
        end else
        write_index <= write_index;
    end
    
    
    /* Write Data Generator
     Data pattern is only a simple incrementing count from 0 for each burst  */
    always @(posedge M_AXI_ACLK) begin
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
            axi_wdata <= 'b1;
            //else if (wnext && axi_wlast)
            //  axi_wdata <= 'b0;
        else if (wnext)
            axi_wdata <= axi_wdata + 1;
        else
            axi_wdata <= axi_wdata;
    end
    always @(posedge M_AXI_ACLK) begin
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
            axi_bready <= 1'b0;
        end
        // accept/acknowledge bresp with axi_bready by the master
        // when M_AXI_BVALID is asserted by slave
        else if (M_AXI_BVALID && ~axi_bready) begin
        axi_bready <= 1'b1;
    end
    // deassert after one clock cycle
    else if (axi_bready) begin
    axi_bready <= 1'b0;
end
// retain the previous value
else
axi_bready <= axi_bready;
end


//Flag any write response errors
assign write_resp_error = axi_bready & M_AXI_BVALID & M_AXI_BRESP[1];


always @(posedge M_AXI_ACLK) begin
    
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
        axi_arvalid <= 1'b0;
    end
    // If previously not valid , start next transaction
    else if (~axi_arvalid && start_single_burst_read) begin
    axi_arvalid <= 1'b1;
    end else if (M_AXI_ARREADY && axi_arvalid) begin
    axi_arvalid <= 1'b0;
    end else
    axi_arvalid <= axi_arvalid;
end


// Next address after ARREADY indicates previous address acceptance
always @(posedge M_AXI_ACLK) begin
    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
        axi_araddr <= 'b0;
        end else if (M_AXI_ARREADY && axi_arvalid) begin
        axi_araddr <= axi_araddr + burst_size_bytes;
        end else
        axi_araddr <= axi_araddr;
    end
    
    // Forward movement occurs when the channel is valid and ready
    assign rnext = M_AXI_RVALID && axi_rready;     		//读数据期�??
    
    
    // Burst length counter. Uses extra counter register bit to indicate
    // terminal count to reduce decode logic
    always @(posedge M_AXI_ACLK) begin
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1 || start_single_burst_read) begin
            read_index <= 0;
            end else if (rnext && (read_index ! = C_M_AXI_BURST_LEN-1)) begin
            read_index <= read_index + 1;
            end else
            read_index <= read_index;
        end
        
        
        /*
         The Read Data channel returns the results of the read request
         
         In this example the data checker is always able to accept
         more data, so no need to throttle the RREADY signal
         */
        always @(posedge M_AXI_ACLK) begin
            if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
                axi_rready <= 1'b0;
            end
            // accept/acknowledge rdata/rresp with axi_rready by the master
            // when M_AXI_RVALID is asserted by slave
            else if (M_AXI_RVALID) begin
            if (M_AXI_RLAST && axi_rready) begin
                axi_rready <= 1'b0;
                end else begin
                axi_rready <= 1'b1;
            end
        end
        // retain the previous value
    end
    
    //Check received read data against data generator
    always @(posedge M_AXI_ACLK) begin
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
            read_mismatch <= 1'b0;
        end
        //Only check data when RVALID is active
        else if (rnext && (M_AXI_RDATA ! = expected_rdata)) begin
        read_mismatch <= 1'b1;
        end else
        read_mismatch <= 1'b0;
    end
    
    //Flag any read response errors
    assign read_resp_error = axi_rready & M_AXI_RVALID & M_AXI_RRESP[1];
    //----------------------------------------
    //Example design read check data generator
    //-----------------------------------------
    //Generate expected read data to check against actual read data
    always @(posedge M_AXI_ACLK) begin
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)// || M_AXI_RLAST)
            expected_rdata <= 'b1;
        else if (M_AXI_RVALID && axi_rready)
            expected_rdata <= expected_rdata + 1;
        else
            expected_rdata <= expected_rdata;
    end
    //----------------------------------
    //Example design error register
    //----------------------------------
    //Register and hold any data mismatches, or read/write interface errors
    always @(posedge M_AXI_ACLK) begin
        if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
            error_reg <= 1'b0;
            end else if (read_mismatch || write_resp_error || read_resp_error) begin
            error_reg <= 1'b1;
            end else
            error_reg <= error_reg;
        end
        
        // write_burst_counter counter keeps track with the number of burst transaction initiated
        // against the number of burst transactions the master needs to initiate
        always @(posedge M_AXI_ACLK) begin
            if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
                write_burst_counter <= 'b0;
                end else if (M_AXI_AWREADY && axi_awvalid) begin
                if (write_burst_counter[C_NO_BURSTS_REQ] == 1'b0) begin
                    write_burst_counter                    <= write_burst_counter + 1'b1;
                    //write_burst_counter[C_NO_BURSTS_REQ] <= 1'b1;
                end
                end else
                write_burst_counter <= write_burst_counter;
            end
            
            // read_burst_counter counter keeps track with the number of burst transaction initiated
            // against the number of burst transactions the master needs to initiate
            always @(posedge M_AXI_ACLK) begin
                if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1) begin
                    read_burst_counter <= 'b0;
                    end else if (M_AXI_ARREADY && axi_arvalid) begin
                    if (read_burst_counter[C_NO_BURSTS_REQ] == 1'b0) begin
                        read_burst_counter                    <= read_burst_counter + 1'b1;
                        //read_burst_counter[C_NO_BURSTS_REQ] <= 1'b1;
                    end
                    end else
                    read_burst_counter <= read_burst_counter;
                end
                
                //implement master command interface state machine
                
                always @ (posedge M_AXI_ACLK) begin
                    if (M_AXI_ARESETN == 1'b0) begin
                        // reset condition
                        // All the signals are assigned default values under reset condition
                        mst_exec_state           <= IDLE;
                        start_single_burst_write <= 1'b0;
                        start_single_burst_read  <= 1'b0;
                        compare_done             <= 1'b0;
                        ERROR                    <= 1'b0;
                    end else begin
                        
                        // state transition
                        case (mst_exec_state)
                            
                            IDLE: begin
                            // This state is responsible to wait for user defined C_M_START_COUNT
                            // number of clock cycles.
                            if (init_txn_pulse == 1'b1) begin
                                mst_exec_state <= INIT_WRITE;
                                ERROR          <= 1'b0;
                                compare_done   <= 1'b0;
                                end else begin
                                    mst_exec_state <= IDLE;
                                end
                            end

                            INIT_WRITE: begin
                            // This state is responsible to issue start_single_write pulse to
                            // initiate a write transaction. Write transactions will be
                            // issued until burst_write_active signal is asserted.
                            // write controller
                            if (writes_done) begin
                                mst_exec_state <= INIT_READ;//
                                end else begin
                                    mst_exec_state <= INIT_WRITE;
                                    
                                    if (~axi_awvalid && ~start_single_burst_write && ~burst_write_active) begin
                                        start_single_burst_write <= 1'b1;
                                        end else begin
                                            start_single_burst_write <= 1'b0; //Negate to generate a pulse
                                        end
                                    end
                            end

                            INIT_READ: begin
                                // This state is responsible to issue start_single_read pulse to
                                // initiate a read transaction. Read transactions will be
                                // issued until burst_read_active signal is asserted.
                                // read controller
                                if (reads_done) begin
                                    mst_exec_state <= INIT_COMPARE;
                                end else begin
                                    mst_exec_state <= INIT_READ;
                                    
                                    if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read) begin
                                        start_single_burst_read <= 1'b1;
                                        end else begin
                                            start_single_burst_read <= 1'b0; //Negate to generate a pulse
                                        end
                                end
                            end

                            INIT_COMPARE: begin
                                // This state is responsible to issue the state of comparison
                                // of written data with the read data. If no error flags are set,
                                // compare_done signal will be asseted to indicate success.
                                //if (~error_reg) begin
                                    ERROR          <= error_reg;
                                    mst_exec_state <= IDLE;
                                    compare_done   <= 1'b1;
                                end
                                default : begin
                                    mst_exec_state <= IDLE;
                                end
                            default :begin
                                
                            end
                        endcase
                    end
                end //MASTER_EXECUTION_PROC
                
                // burst_write_active signal is asserted when there is a burst write transaction
                // is initiated by the assertion of start_single_burst_write. burst_write_active
                // signal remains asserted until the burst write is accepted by the slave
                always @(posedge M_AXI_ACLK) begin
                    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
                        burst_write_active <= 1'b0;
                    
                    //The burst_write_active is asserted when a write burst transaction is initiated
                    else if (start_single_burst_write)
                    burst_write_active <= 1'b1;
                    else if (M_AXI_BVALID && axi_bready)
                    burst_write_active <= 0;
                end
                
                // Check for last write completion.
                
                // This logic is to qualify the last write count with the final write
                // response. This demonstrates how to confirm that a write has been
                // committed.
                
                always @(posedge M_AXI_ACLK) begin
                    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
                        writes_done <= 1'b0;
                    
                    //The writes_done should be associated with a bready response
                    //else if (M_AXI_BVALID && axi_bready && (write_burst_counter == {(C_NO_BURSTS_REQ-1){1}}) && axi_wlast)
                    else if (M_AXI_BVALID && (write_burst_counter[C_NO_BURSTS_REQ]) && axi_bready)
                    writes_done <= 1'b1;
                    else
                    writes_done <= writes_done;
                end
                
                // burst_read_active signal is asserted when there is a burst write transaction
                // is initiated by the assertion of start_single_burst_write. start_single_burst_read
                // signal remains asserted until the burst read is accepted by the master
                always @(posedge M_AXI_ACLK) begin
                    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
                        burst_read_active <= 1'b0;
                    
                    //The burst_write_active is asserted when a write burst transaction is initiated
                    else if (start_single_burst_read)
                    burst_read_active <= 1'b1;
                    else if (M_AXI_RVALID && axi_rready && M_AXI_RLAST)
                    burst_read_active <= 0;
                end
                
                
                // Check for last read completion.
                
                // This logic is to qualify the last read count with the final read
                // response. This demonstrates how to confirm that a read has been
                // committed.
                
                always @(posedge M_AXI_ACLK) begin
                    if (M_AXI_ARESETN == 0 || init_txn_pulse == 1'b1)
                        reads_done <= 1'b0;
                    
                    //The reads_done should be associated with a rready response
                    //else if (M_AXI_BVALID && axi_bready && (write_burst_counter == {(C_NO_BURSTS_REQ-1){1}}) && axi_wlast)
                    else if (M_AXI_RVALID && axi_rready && (read_index == C_M_AXI_BURST_LEN-1) && (read_burst_counter[C_NO_BURSTS_REQ]))
                    reads_done <= 1'b1;
                    else
                    reads_done <= reads_done;
                end
                
                // Add user logic here
                
                // User logic ends
                
                endmodule
                
                
