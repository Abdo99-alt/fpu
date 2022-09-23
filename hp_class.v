///////////////////////////////Module 1/////////////////////////////////////
///////This module to categorize the floating point number////////
module hp_class(f , snan , qnan , inf , zero , normal , subnormal , fExp , fSig);
input [15:0] f;
output zero ,  subnormal  , snan , qnan , normal ,inf;
output reg signed  [6:0] fExp;
output reg [10:0] fSig;
reg [10:0] mask = ~0;			
reg [3:0] sa;			//sa holds the required shift amount to normalize a subnormal
integer i;				


//internal signals to get the status of exponent and signficant
wire expones , sigzeros , expzeros;

assign expones = & f[14:10];
assign expzeros = ~(| f[14:10]);
assign sigzeros = ~(| f[9:0]);

assign qnan = & f[14:9];							//1024 posssible encodings
assign snan = & f[14:10]  & ~f[9] & ~sigzeros ;		//1022 posssible encodings
assign zero = ~| f[14:0];                                        		//2 posssible encodings
assign subnormal = ~sigzeros & expzeros;  			//2046 posssible encodings
assign normal = ~(expones & expzeros); 				//61440 posssible encodings
assign inf = expones & sigzeros;					//2 posssible encodings

//exclusive statements to accout for subnormal * normal multiplication
always @(*) begin
	fExp = f[14:10];
	fSig = {1'b1 , f[9:0]};
	sa = 0;
	if (normal == 1) begin
		fExp = f[14:10] - 15;
		fSig = {1'b1 , f[9:0]};
	end
	else if (subnormal == 1) begin				//Normalizing subnormals to be handled like normals
		for (i = 8 ; i > 0 ;i =  i >> 1)
			if (fSig & (mask << 11 - i) == 0) begin
				fSig = fSig << i;
				sa = sa | i;
			end
		
		fExp = -14 - sa;
	end
end

endmodule 
