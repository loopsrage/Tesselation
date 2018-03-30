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
			Tags {"LightMode"="ForwardBase"}
			LOD 100

			ZWrite Off
			Lighting On
			Blend SrcAlpha OneMinusSrcAlpha
    		CGPROGRAM
    		#pragma target 5.0
     
    		#pragma vertex VS
    		#pragma fragment PS
    		#pragma hull HS
    		#pragma domain DS
    		
    		#pragma enable_d3d11_debug_symbols

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
			#include "Tesselation.cginc"
     
    		ENDCG
     
    	}
		Pass {
			Tags {"Queue"="Transparent" "RenderType"="Transparent" }
			Tags {"LightMode"="ForwardAdd"}
			LOD 100

			ZWrite Off
			Lighting On
			Blend One One
    		CGPROGRAM
    		#pragma target 5.0
     
    		#pragma vertex VS
    		#pragma fragment PS
    		#pragma hull HS
    		#pragma domain DS
    		
    		#pragma enable_d3d11_debug_symbols

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
			#include "Tesselation.cginc"
     
    		ENDCG
     
    	}
    }
}