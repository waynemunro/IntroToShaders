Shader "Unlit/SimpleShader"{
	Properties{

		_Color ("Color",Color) = (1,1,1,1)
		_Gloss ("Gloss", Float) = 1
		//_MainTex("Texture", 2D) = "white" {}
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AUTOLIGHT.cginc"
			//#include "UnityShaderVariables.cginc"

			struct VertexInput {
				float4 vertex : POSITION;
				//float4 colors : COLOR;
				float3 normal : NORMAL;
				//float4 tangent : TANGENT;
				float2 uv0 : TEXCOORD0;
				//float2 uv1 : TEXCOORD1;
			};

			struct VertexOutput {
				float2 uv0 : TEXCOORD0;
				float3 normal : TEXCOORD1; 
				float3 worldPos : TEXCOORD2;
				float4 clipSpacePos : SV_POSITION;				
			};
			
			float4 _Color;
			float _Gloss;

			// Vertex shader 
			VertexOutput vert(VertexInput v) {
				VertexOutput o;
				o.uv0 = v.uv0;
				o.normal = v.normal;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.clipSpacePos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(VertexOutput o) : SV_Target {

				//return float4(o.worldPos,0);
				
				float2 uv = o.uv0;
				float3 normal = normalize(o.normal);

				// Lighting

				// Direct diffuse light
				float3 lightColor = _LightColor0.rgb;
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float lightFalloff = max(0, dot(lightDir, normal));
				float3 directDiffuseLight = lightColor * lightFalloff;

				// ambient light
				float3 ambientLight = float3(0.1, 0.1, 0.1);

				// direct specular light
				float3 camPos = _WorldSpaceCameraPos;
				float3 fragToCam = camPos - o.worldPos;
				float3 viewDir = normalize(fragToCam);
				float3 viewReflect = reflect(-viewDir, normal);
				float specularFalloff = max (0,dot(viewReflect, lightDir));
				float specularFalloffModified = pow(specularFalloff, _Gloss);				
				float3 directSpecular = specularFalloffModified * lightColor;

				// composite light
				float3 diffuseLight = ambientLight + directDiffuseLight;
				float3 finalSurefaceColour = diffuseLight * _Color.rgb + directSpecular;

				return float4(finalSurefaceColour, 0);

			}
			ENDCG
		}
	}
}
