module read_bmp (
    input [9:0] h_addr,
    input [8:0] v_addr,
    output [23:0] vga_data
);
	localparam height = 480;
	localparam width = 640;
	localparam bfoffset = 54;
	localparam total_size = height * width * 3 + bfoffset;
	
	//integer iIndex=0
	reg [7:0] rBmpData [total_size];
	// reg [7:0] rData;
	//integer iBmpWidth,iBmpHight,iDataStartIndex,iBmpSize;
	
	initial begin
		
		//integer iBmpFileId,iCode;
		//iBmpFileId = $fopen("resource/picture.bmp","rb");
		//iCode = $fread(rBmpData,iBmpFileId);
		//$fclose(iBmpFileId);
		$readmemh("./resource/picture.bmp_hex.txt", rBmpData);
		// iBmpWidth = {rBmpData[21],rBmpData[20],rBmpData[19],rBmpData[18]};
		// iBmpHight = {rBmpData[25],rBmpData[24],rBmpData[23],rBmpData[22]};
		// iDataStartIndex = {rBmpData[13],rBmpData[12],rBmpData[11],rBmpData[10]};
		// iBmpSize = {rBmpData[5],rBmpData[4],rBmpData[3],rBmpData[2]};


		// for (int i = iBmpHight-1; i>=0; i=i-1) begin
		// //for (int i = 0; i<iBmpHight; i=i+1) begin
		// 	for (int j = 0; j< iBmpWidth; j=j+1) begin
		// 		iIndex = i * iBmpWidth * 3 + j*3 + iDataStartIndex;
		// 		$fwrite(iOutFileId,"%x",rBmpData[iIndex+2]);//R
		// 		$fwrite(iOutFileId,"%x",rBmpData[iIndex+1]);//G
		// 		$fwrite(iOutFileId,"%x\n",rBmpData[iIndex+0]);//B
		// 	end
		// end
	end

	assign vga_data[23:16] = rBmpData[{h_addr * 3 + (479 - v_addr) * 640 * 3  + 54 + 9'd2}];//R
	assign vga_data[15:8]  = rBmpData[{h_addr * 3 + (479 - v_addr) * 640 * 3  + 54 + 9'd1}];//G
	assign vga_data[7:0]   = rBmpData[{h_addr * 3 + (479 - v_addr) * 640 * 3  + 54 + 9'd0}];//B
endmodule //read_bmp