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
	float2 uv : TEXCOORD0;
};
struct HS_ControlPointOutput
{
    float3 pos    : POS;
};
struct DS_Output
{
    float4 pos   : SV_Position;
	float3 normal : NORMAL;
	float4 diff : COLOR0;
	float2 uv : TEXCOORD0;
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
	v += sin(_SubWaveSpeed * _Time.y + -mul(dot(v,v),dot(v,v)) + sea_octave(dot(v,v),3) * _SubWaveAmplitude ) * 0.003;
	v /= saturate(mul(v,unity_DeltaTime));
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
				
	float4 WorldPos = mul(_WorldSpaceCameraPos,p);
				
	p = MorphVertex(p,WorldPos);
				
	Output.normal = p;
	Output.WorldPos = WorldPos;
	Output.pos = UnityObjectToClipPos (p); 
	// Lighting
	half3 worldNormal = UnityObjectToWorldNormal(Output.normal);
	Output.uv = HSConstantData.uv;
	half nl =  normalize(_WorldSpaceLightPos0.xyz - worldNormal);
	Output.diff = nl * unity_AmbientSky;
	Output.diff.rgb += ShadeSH9(half4(worldNormal,_Transparency));
	// End Lighting
           
    return Output;
}
FS_Output PS( DS_Output I )
{
    FS_Output Output;
	float4 tex1 = tex2D(_MainTex,I.normal);
    Output.color = tex1 * I.diff;
	Output.color.a = _Transparency;
    return Output;
}