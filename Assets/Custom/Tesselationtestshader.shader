// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Tesselation/Triangle_Tesselation" {
    Properties {
        _TessEdge ("Edge Tess", Range(1,64)) = 2
		_MainTex("Texutre", 2D) = "White" {}
		_Transparency("Transparency", range(0,1)) = 0.6
		_Speed("Speed", float) = 1
		_Amplitude("Amplitude",float) = 1
		_Distance("Distance", float) = 1
		_Amount("Amount", float) = 1
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
			float _Distance;
			float _Amount;
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
			float4 MorphVertex(float4 v, float4 wp){
				v.y += sin(_Speed * _Time.y + -dot(v,v) * _Amplitude) * _Distance * _Amount;
				v.y += sin(dot(v.y,v.y) * dot(v.x,v.z) * dot(v.y,v.y));
				v.y += sin(-dot(wp,wp) * _Time.y) * 0.01 ;
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
				Output.normal = dot(p,p);
				Output.WorldPos = WorldPos;
        		Output.pos = UnityObjectToClipPos (p); 
           
        		return Output;
    		}
     
     
    		FS_Output PS( DS_Output I )
    		{
        		FS_Output Output;
				// tex2D(_MainTex,I.normal);
       			Output.color = tex2D(_MainTex,I.normal * 100);
				Output.color.a = _Transparency;
       			return Output;
    		}
     
    		ENDCG
     
    		}
    	}
}