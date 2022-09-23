////////////////////////////////////Module 2/////////////////////////////////////////
//This module is to preform the multiplication on 16-bit floating point numbers//
///Interfaces with hp_class module///
// hp_mul -->hp_class//
//IEEE 754 standard :
//snan * snan --> propagate value
//Qnan * Qnan --> product is Qnan
//Inf * Inf [normal] [subnoraml] = Inf
//Inf * zero = Qnan
//Subnormal * Subormal = 0
//------------------------------------------------------------------------------------//
module hp_mul(input [15:0] a , b ,
			output reg Snan , Qnan , Inf , Zero , Normal , Subnormal ,
			output [15:0] p);
		
reg [15:0] ptmp;		//Internal register to hold the product
reg psign;
wire signed [6:0] aExp , bExp;	//7-bits to accomodate for smallest possible subnormal (e-24) * smallest possible normal(e-14)
//reg [4:0] pExp;
reg signed [6:0]  t1Exp , t2Exp , pExp; //temporal storage for product exponent							
wire [10:0] aSig , bSig;
reg [10:0] pSig ;
wire [21:0] rawSig;		//holds the product of aSig , bSig
reg [10:0] tSig;			//temporal storage for truncated significant

wire aSnan , aQnan , aInf , aZero , aNormal , aSubnormal ;
wire bSnan , bQnan , bInf , bZero , bNormal , bSubnormal ;

hp_class a_calss(a ,  aSnan , aQnan ,   aInf , aZero , aNormal , aSubnormal , aExp , aSig);
hp_class b_calss (b , bSnan , bQnan , bInf , bZero , bNormal , bSubnormal , bExp , bSig);
//---------------------------------------------------------------------------------------//
//***************************************************************************************//
assign rawSig = aSig * bSig;
always @(*) begin
	ptmp = {1'b0 , {5{1'b1}} , 1'b0 , {9{1'b1}}};			//Initialized to snan (why???)
	psign = a[15] ^ b[15];						//product sign is the xor of a ,b
	
	{Snan , Qnan , Inf , Zero , Normal , Subnormal } = 6'b0;
	if ((aSnan | bSnan) == 1) begin
		ptmp = (aSnan == 1) ? a : b;
		Snan = 1;
	end
	else if ((aQnan | bQnan) == 1) begin
		ptmp = aQnan == 1 ? a : b;
		Qnan = 1;
	end
	else if ((aInf | bInf) == 1) begin
		if ((aZero | bZero) == 1) begin
			ptmp = {psign , {6{1'b1}} , 9'h2a};
			Qnan = 1;
		end
		else begin
			ptmp = {psign , {5{1'b1}} ,{10{1'b0}}};
			Inf = 1;
		end
	end
	else if ((aZero | bZero)== 1 || (aSubnormal & bSubnormal) == 1) begin
		ptmp = {psign , {15{1'b0}}};
		Zero = 1;
	end
	else begin
		t1Exp = aExp + bExp;
		if(rawSig[21] == 1) begin			//product needs to be normalized
			t2Exp = t1Exp + 1;
			tSig = rawSig[21:11];		//significant is truncated to 10 bits--Don't forget the implied 1
		end
		else begin						//product is normalized
			t2Exp = t1Exp;
			tSig = rawSig[20:10];
		end
		
		if (t2Exp < -24) begin			//Even smaller than a Subormal product
			ptmp = {psign , {15{1'b0}}};	//rounded to Zero
			Zero = 1;
		end
		else if (t2Exp < -14)	begin			//Subnormal product 
			pSig = tSig >> (-14 - t2Exp);		
			ptmp = {psign , {5{1'b0}} , pSig[9:0]};	
			Subnormal = 1;
		end
		else if (t2Exp > 15) begin				//Infinity product
			ptmp = {psign , {5{1'b1}} , 10'b0};
			Inf = 1;
		end
		else begin							//Normal product
			pExp = t2Exp + 15;	
			pSig = tSig;
			ptmp = {psign , pExp[4:0] , pSig[9:0]};
			Normal = 1;
		end
	end
end
assign p = ptmp;
endmodule
