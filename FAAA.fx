/*============================================================================

		FAAA - Antialiasing shader for Reshade
				by G.Rebord
				
		based on NVIDIA FXAA 3.11 by TIMOTHY LOTTES,
		COPYRIGHT (C) 2010, 2011 NVIDIA CORPORATION.
		
------------------------------------------------------------------------------
TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THIS SOFTWARE IS PROVIDED
*AS IS* AND NVIDIA AND ITS SUPPLIERS DISCLAIM ALL WARRANTIES, EITHER EXPRESS
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL NVIDIA
OR ITS SUPPLIERS BE LIABLE FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR
CONSEQUENTIAL DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR
LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION,
OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR INABILITY TO USE
THIS SOFTWARE, EVEN IF NVIDIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.
============================================================================*/

namespace FXAA {
/*============================================================================
		SETTINGS
============================================================================*/
#ifndef FXAA_EDGE_THRESHOLD
	// Edge detection threshold. Higher values result in more edges being
	// detected and smoothed. Range: 1.0 to 9.0. Default: 5.0 (thorough)
	#define FXAA_EDGE_THRESHOLD 5.0
#endif
/*--------------------------------------------------------------------------*/
#ifndef FXAA_QUALITY
	// Antialiasing quality setting. Higher values result in higher quality
	// of antialiasing applied to detected edges. Default: 5 (high quality)
	// Range: From 1 (fastest) to 9 (highest quality).
    #define FXAA_QUALITY 5
#endif
/*--------------------------------------------------------------------------*/
#ifndef FXAA_SHOW_EDGES
	// Show detected edges. Note that how detected edges are processed varies.
	#define FXAA_SHOW_EDGES 0
#endif

/*============================================================================
		LUMA COMPUTATION
============================================================================*/
#define FXAA_COMPUTE_LUMA 1	 // 1: compute luma - 0: get luma from A channel.

/*============================================================================
		SETUP
============================================================================*/
texture BackBufferTex : COLOR;
sampler BackBuffer
{
	Texture = BackBufferTex;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	SRGBTexture = false;
};
static const float2 PixelSize = float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT);
static const float EdgeThreshold = (10.0 - FXAA_EDGE_THRESHOLD) * 0.0625;
/*--------------------------------------------------------------------------*/
#define tsp(p) 					float4(p, 0.0, 0.0)
#define SampleColor(p)				tex2Dlod(BackBuffer, tsp(p))
/*--------------------------------------------------------------------------*/
#if FXAA_COMPUTE_LUMA
	#define Edges			float3(0,1,0)
	#define GetLuma(c)		dot(c, float3(0.299, 0.587, 0.114))
	#define SampleLuma(p)		GetLuma(tex2Dlod(BackBuffer, tsp(p)).rgb)
#define SampleLumaOff(p, o)	GetLuma(tex2Dlodoffset(BackBuffer, tsp(p), o).rgb)
/*--------------------------------------------------------------------------*/
#else
	#define Edges				float4(0,1,0,lumaM)
	#define SampleLuma(p)			tex2Dlod(BackBuffer, tsp(p)).w
	#define SampleLumaOff(p, o)		tex2Dlodoffset(BackBuffer, tsp(p), o).w
	#if (__RENDERER__ == 0xb000 || __RENDERER__ == 0xb100)
		#define GatherLuma(p) 		tex2Dgather(BackBuffer, p, 3)
		#define GatherLumaOff(p, o) tex2Dgatheroffset(BackBuffer, p, o, 3)
		#define FXAA_GATHER 1
	#endif
#endif
/*--------------------------------------------------------------------------*/
#define OffS   int2( 0, 1)
#define OffE   int2( 1, 0)
#define OffN   int2( 0,-1)
#define OffW   int2(-1, 0)
#define OffSW  int2(-1, 1)
#define OffSE  int2( 1, 1)
#define OffNE  int2( 1,-1)
#define OffNW  int2(-1,-1)

/*============================================================================
	Settings - from FXAA3 QUALITY VERSION LOW DITHER SETTINGS
============================================================================*/
#if (FXAA_QUALITY == 1)
	#define FXAA_QUALITY__PI  4
	#define FXAA_QUALITY__P3  8.0
#endif
#if (FXAA_QUALITY == 2)
	#define FXAA_QUALITY__PI  5
	#define FXAA_QUALITY__P4  8.0
#endif
#if (FXAA_QUALITY == 3)
	#define FXAA_QUALITY__PI  6
	#define FXAA_QUALITY__P5  8.0
#endif
#if (FXAA_QUALITY == 4)
	#define FXAA_QUALITY__PI  7
	#define FXAA_QUALITY__P5  3.0
	#define FXAA_QUALITY__P6  8.0
#endif
#if (FXAA_QUALITY == 5)
	#define FXAA_QUALITY__PI  8
	#define FXAA_QUALITY__P6  4.0
	#define FXAA_QUALITY__P7  8.0
#endif
#if (FXAA_QUALITY == 6)
	#define FXAA_QUALITY__PI  9
	#define FXAA_QUALITY__P7  4.0
	#define FXAA_QUALITY__P8  8.0
#endif
#if (FXAA_QUALITY == 7)
	#define FXAA_QUALITY__PI  10
	#define FXAA_QUALITY__P8  4.0
	#define FXAA_QUALITY__P9  8.0
#endif
#if (FXAA_QUALITY == 8)
	#define FXAA_QUALITY__PI  11
	#define FXAA_QUALITY__P9  4.0
	#define FXAA_QUALITY__P10 8.0
#endif
#if (FXAA_QUALITY == 9)
	#define FXAA_QUALITY__PI  12
    #define FXAA_QUALITY__P1  1.0
    #define FXAA_QUALITY__P2  1.0
    #define FXAA_QUALITY__P3  1.0
    #define FXAA_QUALITY__P4  1.0
    #define FXAA_QUALITY__P5  1.5
#endif
/*--------------------------------------------------------------------------*/
#define FXAA_QUALITY__P0  1.0
#define FXAA_QUALITY__P11 8.0
/*--------------------------------------------------------------------------*/
#if !defined FXAA_QUALITY__PI
	#define  FXAA_QUALITY__PI  12
#endif
#if !defined FXAA_QUALITY__P1  
	#define  FXAA_QUALITY__P1  1.5 
#endif
#if !defined FXAA_QUALITY__P2  
	#define  FXAA_QUALITY__P2  2.0 
#endif
#if !defined FXAA_QUALITY__P3  
	#define  FXAA_QUALITY__P3  2.0 
#endif
#if !defined FXAA_QUALITY__P4  
	#define  FXAA_QUALITY__P4  2.0 
#endif
#if !defined FXAA_QUALITY__P5  
	#define  FXAA_QUALITY__P5  2.0 
#endif
#if !defined FXAA_QUALITY__P6  
	#define  FXAA_QUALITY__P6  2.0 
#endif
#if !defined FXAA_QUALITY__P7  
	#define  FXAA_QUALITY__P7  2.0 
#endif
#if !defined FXAA_QUALITY__P8  
	#define  FXAA_QUALITY__P8  2.0 
#endif
#if !defined FXAA_QUALITY__P9  
	#define  FXAA_QUALITY__P9  2.0 
#endif
#if !defined FXAA_QUALITY__P10  
	#define  FXAA_QUALITY__P10  4.0 
#endif
/*--------------------------------------------------------------------------*/
static const float OffMult[12] = { FXAA_QUALITY__P0, FXAA_QUALITY__P1,
	FXAA_QUALITY__P2, FXAA_QUALITY__P3, FXAA_QUALITY__P4, FXAA_QUALITY__P5,
	FXAA_QUALITY__P6, FXAA_QUALITY__P7, FXAA_QUALITY__P8, FXAA_QUALITY__P9,
	FXAA_QUALITY__P10, FXAA_QUALITY__P11 };
	
/*============================================================================
	SHADERS
============================================================================*/
void FXAAVS(in uint id : SV_VertexID,
	out float4 pos : SV_Position, out float2 txc : TEXCOORD){
	txc.x = (id == 2) ? 2.0 : 0.0;
	txc.y = (id == 1) ? 2.0 : 0.0;
	pos = float4(txc * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}
/*==========================================================================*/
#if FXAA_COMPUTE_LUMA
	float3 FXAAPS
#else
	float4 FXAAPS
#endif
(float4 pos : SV_Position, noperspective float2 txc : TEXCOORD) : SV_Target
{
/*--------------------------------------------------------------------------*/
#if FXAA_GATHER
	float4 lumaDP = GatherLuma(txc);
	float4 lumaDN = GatherLumaOff(txc, OffNW);
	#define lumaSE lumaDP.y
	#define lumaNW lumaDN.w
#else
	float lumaSE = SampleLumaOff(txc, OffSE);
	float lumaNW = SampleLumaOff(txc, OffNW);
#endif
/*--------------------------------------------------------------------------*/
	float lumaSW = SampleLumaOff(txc, OffSW);
	float lumaNE = SampleLumaOff(txc, OffNE);
/*----------------------------------------------------------------------------
	Edge detection. This does much better than a head-on luma delta.
----------------------------------------------------------------------------*/
	float gradientSWNE = lumaSW - lumaNE;
	float gradientSENW = lumaSE - lumaNW;
	float2 dirM;
	dirM.x = abs(gradientSWNE + gradientSENW);
	dirM.y = abs(gradientSWNE - gradientSENW);
/*--------------------------------------------------------------------------*/
	float lumaMax = max(max(lumaSW, lumaSE), max(lumaNE, lumaNW));
	float localLumaFactor = lumaMax * 0.5 + 0.5;
	float localThres = EdgeThreshold * localLumaFactor;
	bool lowDelta = abs(dirM.x - dirM.y) < localThres;
/*--------------------------------------------------------------------------*/
#if FXAA_SHOW_EDGES
	if(lowDelta) return SampleLuma(txc) * 0.9;
	else return Edges;
#else
	if(lowDelta) discard;
#endif
/*============================================================================
	Start!
----------------------------------------------------------------------------*/
	bool horzSpan = dirM.x > dirM.y;
/*--------------------------------------------------------------------------*/
#if FXAA_GATHER
	float lumaM = lumaDP.w;
	float lumaN = lumaDN.z;
	float lumaS = lumaDP.x;
	if(!horzSpan) lumaN = lumaDN.x;
	if(!horzSpan) lumaS = lumaDP.z;
/*--------------------------------------------------------------------------*/
#else
	float lumaM = SampleLuma(txc);
	float lumaN, lumaS;
	if( horzSpan) lumaN = SampleLumaOff(txc, OffN);
	if( horzSpan) lumaS = SampleLumaOff(txc, OffS);
	if(!horzSpan) lumaN = SampleLumaOff(txc, OffW);
	if(!horzSpan) lumaS = SampleLumaOff(txc, OffE);
#endif
/*--------------------------------------------------------------------------*/
	float gradientN = lumaN - lumaM;
	float gradientS = lumaS - lumaM;
/*--------------------------------------------------------------------------*/
	bool pairN = abs(gradientN) > abs(gradientS);
/*--------------------------------------------------------------------------*/
	float gradient = abs(gradientN);
	if(!pairN) gradient = abs(gradientS);
	float gradientScaled = gradient * 0.25;
/*--------------------------------------------------------------------------*/
	float lumaNN = lumaN + lumaM;
	if(!pairN) lumaNN = lumaS + lumaM;
	float lumaMN = lumaNN * 0.5;
/*--------------------------------------------------------------------------*/
	float lengthSign = PixelSize.y;
	if(!horzSpan) lengthSign = PixelSize.x;
	if( pairN) lengthSign = -lengthSign;
/*--------------------------------------------------------------------------*/
    float2 posN = txc;
	if(!horzSpan) posN.x += lengthSign * 0.5;
	if( horzSpan) posN.y += lengthSign * 0.5;
	float2 posP = posN;
	float2 offNP = PixelSize;
	if(!horzSpan) offNP.x = 0;
	if( horzSpan) offNP.y = 0;
/*--------------------------------------------------------------------------*/
	int i = 0;
	posP += offNP * OffMult[i];
	posN -= offNP * OffMult[i];
	float lumaEndP = SampleLuma(posP);
	float lumaEndN = SampleLuma(posN);
	lumaEndP -= lumaMN;
	lumaEndN -= lumaMN;
	bool doneP = abs(lumaEndP) > gradientScaled;
	bool doneN = abs(lumaEndN) > gradientScaled;
/*----------------------------------------------------------------------------
 Changing the smallest thing below can cause severe performance degradation.
 Test any changes thoroughly!
----------------------------------------------------------------------------*/
	while(++i < FXAA_QUALITY__PI) {
		if(!doneP) {
			posP += offNP * OffMult[i];
			lumaEndP  = SampleLuma(posP);
			lumaEndP -= lumaMN;
			doneP = abs(lumaEndP) > gradientScaled;
		}
		if(!doneN) {
			posN -= offNP * OffMult[i];
			lumaEndN  = SampleLuma(posN);
			lumaEndN -= lumaMN;
			doneN = abs(lumaEndN) > gradientScaled;
		}	
		if(doneN && doneP) break;
	}
/*--------------------------------------------------------------------------*/
	float2 posM = txc;
	float dstN = posM.x - posN.x;
	float dstP = posP.x - posM.x;
	if(!horzSpan) dstN = posM.y - posN.y;
	if(!horzSpan) dstP = posP.y - posM.y;
/*--------------------------------------------------------------------------*/
	bool dstNLTdstP = dstN < dstP;
	bool lumaMLTZero = lumaM - lumaMN < 0;
	bool mSpanLTZero = dstNLTdstP ? lumaEndN < 0 : lumaEndP < 0;
	bool goodSpan = mSpanLTZero != lumaMLTZero;
/*--------------------------------------------------------------------------*/
	float dst = dstNLTdstP ? dstN : dstP;
	float spanLength = dstP + dstN;
	float pixelOffset = (-dst / spanLength) + 0.5;
/*--------------------------------------------------------------------------*/
	bool pixelOffsetLTZero = pixelOffset < 0;
	if(pixelOffsetLTZero || !goodSpan) discard;
/*--------------------------------------------------------------------------*/
	if(!horzSpan) posM.x += pixelOffset * lengthSign;
	if( horzSpan) posM.y += pixelOffset * lengthSign;
/*--------------------------------------------------------------------------*/
	return SampleColor(posM)
#if FXAA_COMPUTE_LUMA
	.rgb;
#else
	;
#endif
}
/*==========================================================================*/
technique FXAA
<
	ui_tooltip = 	"Welcome to FXAA!\n"
			"Settings:\n"
			"---------\n"
			"FXAA_EDGE_THRESHOLD : Edge detection level.\n"
			"    High is thorough, low is sparse.\n"
			"    Range: [1.0;9.0] Default: 5.0 (thorough)\n"
			"FXAA_QUALITY : AA quality level.\n"
			"    Range: [1;9] Default: 5 (high quality)\n";
>
{
	pass {
		VertexShader = FXAAVS;
		PixelShader  = FXAAPS;
	}
}
/*==========================================================================*/
}
