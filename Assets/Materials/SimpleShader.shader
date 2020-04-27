Shader "Unlit/SimpleShader"{
	Properties{

		_Color ("Color",Color) = (1,1,1,1)
		_Gloss ("Gloss", Float) = 10
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

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
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

			float Posterize(float steps, float value){
				return floor(value * steps) / steps;
			}

			fixed4 frag(VertexOutput o) : SV_Target {				
				float2 uv = o.uv0;
				float3 normal = normalize(o.normal);

				// Lighting
				// Direct diffuse light
				float3 lightColor = _LightColor0.rgb;
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float lightFalloff = max(0, dot(lightDir, normal));

				lightFalloff = Posterize(3,lightFalloff);

				float3 directDiffuseLight = lightColor * lightFalloff;

				// ambient light
				float3 ambientLight = float3(0.1, 0.1, 0.1);
				// direct specular light
				float3 camPos = _WorldSpaceCameraPos;
				float3 fragToCam = camPos - o.worldPos;
				float3 viewDir = normalize(fragToCam);
				float3 viewReflect = reflect(-viewDir, normal);

				float specularFalloff = max(0,dot(viewReflect, lightDir));
				specularFalloff = pow(specularFalloff , max (1,_Gloss));

				specularFalloff = Posterize(3, specularFalloff);

				float3 directSpecular = (specularFalloff * lightColor, specularFalloff) ;

				// composite light
				float3 diffuseLight = ambientLight + directDiffuseLight ;
				float3 finalSurefaceColour = diffuseLight * _Color.rgb + directSpecular;

				return float4(finalSurefaceColour, 0);
			}
			ENDCG
		}
	}
}
