Shader "Custom/GetTexture" {
	Properties{
		_MainTex("MainTexture", 2D) = "white"{}
		_TexPos("Texture Pos", Vector) = (0.0, 0.0, 0.0, 0.0)

		_VertScale("VertScale", float) = 1.0

	}
	SubShader{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			fixed4 _TexPos;

			fixed _VertScale;

			struct appdata {
				fixed4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
			};
			struct v2f {
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			v2f vert(appdata v) {
				v2f o;

				v.vertex.xy *= _VertScale;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : COLOR {
				fixed2 cUV = i.uv;
				fixed4 rCol = tex2D(_MainTex, cUV);
				rCol.a *= step(_TexPos.x, cUV.x) * step(cUV.x, _TexPos.x + _TexPos.z) * step(_TexPos.y, cUV.y) * step(cUV.y, _TexPos.y + _TexPos.w);
				return rCol;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
