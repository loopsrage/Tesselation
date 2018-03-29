﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Tesselation/Triangle_Tesselation" {
    Properties {
        _TessEdge ("Edge Tess", Range(1,64)) = 2
		_MainTex("Texutre", 2D) = "White" {}
		_Transparency("Transparency", range(0,1)) = 0.6
		_Speed("Speed", float) = 1
		_Amplitude("Amplitude",float) = 1
		_SubWaveAmplitude("Sub Wave Amplitude",range(0,100)) = 1
		_Distance("Distance", float) = 1
		_SubWaveSpeed("Sub Wave Speed", float) = 0.3
		_Amount("Amount", float) = 1
		_Color("Color", color) = (0,0,0,0)
    }
    SubShader {
    	Pass {
			Tags {"Queue"="Transparent" "RenderType"="Transparent" }
			LOD 100

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
    		CGPROGRAM
    		#pragma target 5.0
     
    		#pragma vertex VS
    		#pragma fragment PS
    		#pragma hull HS
    		#pragma domain DS
    		
    		#pragma enable_d3d11_debug_symbols
     
    		//#include "UnityCG.cginc"
     
    		float _TessEdge;
			float _Transparency;
			sampler2D _MainTex;
			float _Speed;
			float _Amplitude;
			float _SubWaveAmplitude;
			float _Distance;
			float _SubWaveSpeed;
			float _Amount;
			float4 _Color;
    		struct VS_Input
    		{
        		float3 vertex : POSITION;
    		};
     
    		struct HS_Input
    		{
        		float4 pos   : POS;
    		};
     
    		struct HS_ConstantOutput
    		{
       			float TessFactor[3]    : SV_TessFactor;
        		float InsideTessFactor : SV_InsideTessFactor;
    		};
     
    		struct HS_ControlPointOutput
    		{
        		float3 pos    : POS;
    		};
     
    		struct DS_Output
    		{
        		float4 pos   : SV_Position;
				float3 normal : NORMAL;
				float4 WorldPos :POSITION1;
    		};
     
    		struct FS_Input
    		{
        		float4 pos   : SV_Position;
    		};
     
    		struct FS_Output
    		{		
        		fixed4 color      : SV_Target0;
    		};     
     
    		HS_Input VS( VS_Input Input )
    		{
        		HS_Input Output;
        		Output.pos = float4(Input.vertex, 1);
        		return Output;
    		}
    
    		HS_ConstantOutput HSConstant( InputPatch<HS_Input, 3> Input )
    		{
        		HS_ConstantOutput Output = (HS_ConstantOutput)0;
        		Output.TessFactor[0] = Output.TessFactor[1] = Output.TessFactor[2] = _TessEdge;
        		Output.InsideTessFactor = _TessEdge;    
        		return Output;
    		}

    		[domain("tri")]
    		[partitioning("integer")]
    		[outputtopology("triangle_cw")]
    		[patchconstantfunc("HSConstant")]
    		[outputcontrolpoints(3)]
    		HS_ControlPointOutput HS( InputPatch<HS_Input, 3> Input, uint uCPID : SV_OutputControlPointID )
    		{
        		HS_ControlPointOutput Output = (HS_ControlPointOutput)0;
        		Output.pos = Input[uCPID].pos.xyz;
        		return Output;
    		}
			float4 hash(float2 v){
				float4 h = dot(v,float2(127.1,311.7));
				return frac(sin(h)*43758.5453123);
			}
			float noise(float2 v){
				float2 i = floor(v);
				float2 f = frac(v);
				float2 u = f*f*(3.0-2.0*f);
				return -1.0+2.0*lerp(lerp(hash(i + float2(0,0)),
						hash(i + float2(1,0)), v.x),
					lerp(hash(i + float2(0,1)),
						hash(i + float2(1,1)), v.x),v.y);
			}
			float sea_octave(float2 uv, float choppy) {
				uv += noise(uv);        
				float2 wv = 1.0-abs(sin(uv));
				float2 swv = abs(cos(uv));    
				wv = lerp(wv,swv,wv);
				return pow(1.0-pow(wv.x * wv.y,0.65),choppy);
			}

			float4 MorphVertex(float4 v, float4 wp){
				v.y += sin(_Speed * _Time.y + -dot(v,v) * _Amplitude) * _Distance * _Amount;
				v += sin(_SubWaveSpeed * _Time.y + -dot(v,v) + sea_octave(dot(v,v),1) * _SubWaveAmplitude ) * 0.01;
				v /= saturate(mul(v,v));
				return v;
			}
    		[domain("tri")]
    		DS_Output DS( HS_ConstantOutput HSConstantData, 
    					const OutputPatch<HS_ControlPointOutput, 3> Input, 
    					float3 BarycentricCoords : SV_DomainLocation)
    		{
        		DS_Output Output = (DS_Output)0;
     
        		float fU = BarycentricCoords.x;
        		float fV = BarycentricCoords.y;
        		float fW = BarycentricCoords.z;
       
        		float3 pos = Input[0].pos * fU + Input[1].pos * fV + Input[2].pos * fW;
				float4 p = float4(pos,1);
				float4 WorldPos = mul(unity_ObjectToWorld,p);
				p = MorphVertex(p,WorldPos);
				Output.normal = p;//dot(p,p);
				Output.WorldPos = WorldPos;
        		Output.pos = UnityObjectToClipPos (p); 
           
        		return Output;
    		}
     
     
    		FS_Output PS( DS_Output I )
    		{
        		FS_Output Output;
				// tex2D(_MainTex,I.normal);
				I.normal = mul(UNITY_MATRIX_IT_MV, I.normal);
				Output.color = mul(_WorldSpaceCameraPos,_Color);
       			Output.color = tex2D(_MainTex,I.normal);
				Output.color.a = _Transparency;
       			return Output;
    		}
     
    		ENDCG
     
    		}
    	}
}