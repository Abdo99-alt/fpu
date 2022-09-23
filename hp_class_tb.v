module hp_class_tb();
	reg [15:0] f;
	wire signed [6:0] fExp;
	wire [10:0] fSig;
	wire snan , qnan , inf , zero , subnormal , normal;
	integer i , nSnan , nQnan , nInf , nZero , nSubnormal , nNormal;
initial begin
	f = 0;
	nSnan = 0; 
	nQnan = 0; 
	nInf = 0; 
	nZero = 0;
	nSubnormal = 0;
	nNormal = 0;
end
	
initial begin
	
	for(i  = 0; i < (1<<16) ; i = i+1) begin
		#10 assign f = i;
		if ((snan) == 1)
			nSnan = nSnan + 1;
		else if ((qnan) == 1)
			nQnan = nQnan + 1;
		else if ((inf) == 1)
			nInf = nInf +1;
		else if ((zero) == 1)
			nZero = nZero + 1;
		else if ((subnormal) == 1)				
			nSubnormal = nSubnormal + 1;
		else if ((normal) == 1)
			nNormal = nNormal + 1;
		else  begin
			$display ("ERROR : f = %x , class = %b" , f , {snan , qnan , inf , zero , subnormal , normal } );
			$stop;
		end	
	end
	
	begin
		$display ("number of Snans = %d" , nSnan);
		$display ("number of Qnans = %d" , nQnan);
		$display ("number of Infs = %d" , nInf);
		$display ("number of Zeros = %d" , nZero);
		$display ("number of Subnormals = %d" , nSubnormal);
		$display ("number of Normals = %d" , nNormal);
	end
	#10 $stop;
end
	 hp_class tb (f , snan , qnan , inf , zero , normal , subnormal , fExp , fSig);

endmodule
